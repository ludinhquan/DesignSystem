import 'dart:convert';
import 'dart:typed_data';

import 'package:app/core/http.dart';
import 'package:app/core/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake server: answers every request with [handle].
class FakeServer implements HttpClientAdapter {
  FakeServer(this.handle);

  final Future<ResponseBody> Function(RequestOptions request) handle;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handle(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenStore tokens;
  late int expired;

  /// A Dio wired like `dioProvider`, talking to [server].
  Dio client(FakeServer server) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = server;
    final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = server;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokens: tokens,
        onSessionExpired: () => expired++,
      ),
    );
    return dio;
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokens = TokenStore(const FlutterSecureStorage());
    await tokens.write(const AuthTokens(access: 'A1', refresh: 'R1'));
    expired = 0;
  });

  test('adds the bearer token, except on public requests', () async {
    final server = FakeServer((_) async => json(200, {}));
    final dio = client(server);

    await dio.get<void>('/me');
    await dio.post<void>(
      '/auth/login',
      options: Options(extra: {AuthInterceptor.public: true}),
    );

    expect(server.requests[0].headers['Authorization'], 'Bearer A1');
    expect(server.requests[1].headers.containsKey('Authorization'), isFalse);
  });

  test(
    'concurrent 401s share one refresh, then replay with the new token',
    () async {
      var refreshes = 0;
      final server = FakeServer((r) async {
        if (r.path == AuthInterceptor.refreshPath) {
          refreshes++;
          expect(r.data, {'refresh_token': 'R1'});
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return json(200, {'access_token': 'A2', 'refresh_token': 'R2'});
        }
        return r.headers['Authorization'] == 'Bearer A2'
            ? json(200, {'path': r.path})
            : json(401, {});
      });
      final dio = client(server);

      final results = await Future.wait([
        for (final p in ['/a', '/b', '/c']) dio.get<Map<String, Object?>>(p),
      ]);

      expect([for (final r in results) r.data?['path']], ['/a', '/b', '/c']);
      expect(refreshes, 1);
      expect((await tokens.read())?.access, 'A2');
      expect(expired, 0);
    },
  );

  test('a rejected refresh expires the session once per refresh', () async {
    final server = FakeServer((r) async => json(401, {}));
    final dio = client(server);

    await expectLater(
      guardHttp(() => dio.get<void>('/me')),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(expired, 1);
  });

  test(
    'an unreachable refresh keeps the session and reports offline',
    () async {
      final server = FakeServer((r) async {
        if (r.path == AuthInterceptor.refreshPath) {
          throw DioException.connectionError(
            requestOptions: r,
            reason: 'offline',
          );
        }
        return json(401, {});
      });
      final dio = client(server);

      await expectLater(
        guardHttp(() => dio.get<void>('/me')),
        throwsA(isA<NetworkException>()),
      );
      expect(expired, 0);
      expect((await tokens.read())?.access, 'A1');
    },
  );

  group('AppException.fromDio', () {
    Future<AppException> failWith(ResponseBody Function() reply) async {
      final dio = client(FakeServer((_) async => reply()));
      try {
        await guardHttp(() => dio.get<void>('/x'));
      } on AppException catch (e) {
        return e;
      }
      fail('expected an AppException');
    }

    test('5xx -> ServerException', () async {
      expect(
        await failWith(() => json(503, {})),
        isA<ServerException>().having((e) => e.statusCode, 'status', 503),
      );
    });

    test('other 4xx -> RequestException with the backend code', () async {
      expect(
        await failWith(() => json(422, {'code': 'email_taken'})),
        isA<RequestException>()
            .having((e) => e.statusCode, 'status', 422)
            .having((e) => e.code, 'code', 'email_taken'),
      );
    });

    test('timeouts and connection errors -> NetworkException', () {
      final options = RequestOptions(path: '/x');
      for (final e in [
        DioException.connectionTimeout(
          timeout: Duration.zero,
          requestOptions: options,
        ),
        DioException.receiveTimeout(
          timeout: Duration.zero,
          requestOptions: options,
        ),
        DioException.connectionError(requestOptions: options, reason: ''),
      ]) {
        expect(AppException.fromDio(e), isA<NetworkException>());
      }
    });
  });

  group('retryPolicy (the only retry layer)', () {
    test('retries transient failures 3 times with backoff', () {
      expect(
        [for (var i = 0; i < 4; i++) retryPolicy(i, const NetworkException())],
        [
          const Duration(milliseconds: 500),
          const Duration(seconds: 1),
          const Duration(seconds: 2),
          null,
        ],
      );
      expect(retryPolicy(0, const ServerException(500)), isNotNull);
    });

    test('never retries non-transient failures', () {
      expect(retryPolicy(0, const UnauthorizedException()), isNull);
      expect(retryPolicy(0, const RequestException(422)), isNull);
      expect(retryPolicy(0, StateError('bug')), isNull);
    });
  });
}
