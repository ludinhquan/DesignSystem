import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import 'storage.dart';

/// Every failure a repository throws. The UI switches on the subtype and
/// shows a localized message; it never shows `toString()`.
sealed class AppException implements Exception {
  const AppException();

  /// The one place Dio errors are mapped.
  factory AppException.fromDio(DioException e) {
    if (e.error case final AppException inner) return inner;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
        401 => const UnauthorizedException(),
        final int code when code >= 500 => ServerException(code),
        final int code => RequestException(code, _errorCode(e.response?.data)),
        null => UnknownException(e, e.stackTrace),
      },
      DioExceptionType.transformTimeout ||
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.unknown => UnknownException(e, e.stackTrace),
    };
  }

  static String? _errorCode(Object? body) => switch (body) {
    {'code': final String code} => code,
    _ => null,
  };
}

/// No connection or a timeout. Transient: providers retry it.
final class NetworkException extends AppException {
  const NetworkException();

  @override
  String toString() => 'NetworkException';
}

/// 401 that a token refresh could not fix, or rejected credentials at login.
final class UnauthorizedException extends AppException {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}

/// 5xx. Transient: providers retry it.
final class ServerException extends AppException {
  const ServerException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode)';
}

/// Any other 4xx. [code] is the backend's machine-readable error code, if any.
final class RequestException extends AppException {
  const RequestException(this.statusCode, [this.code]);

  final int statusCode;
  final String? code;

  @override
  String toString() => 'RequestException($statusCode, $code)';
}

/// Anything unexpected. Keeps the original error and stack for crash reports.
final class UnknownException extends AppException {
  const UnknownException(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'UnknownException($error)';
}

/// Awaits a Dio call and rethrows a [DioException] as an [AppException],
/// keeping the stack trace. Repositories wrap every call in it.
Future<T> guardHttp<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e, s) {
    Error.throwWithStackTrace(AppException.fromDio(e), s);
  }
}

/// Retry policy for the whole app, passed to `ProviderScope(retry: ...)`.
///
/// **Only Riverpod retries.** There is no Dio retry interceptor, so a failing
/// request runs at most 1 + 3 times. Only transient failures are retried, and
/// only for providers (reads); user actions such as login are never retried.
/// The single replay after a token refresh in [AuthInterceptor] is not a
/// retry of a failure: it is the same request with a new token.
Duration? retryPolicy(int retryCount, Object error) {
  if (retryCount >= 3) return null;
  return switch (error) {
    NetworkException() ||
    ServerException() => const Duration(milliseconds: 500) * (1 << retryCount),
    _ => null,
  };
}

/// Fires when the server rejects the refresh token. The session controller
/// listens and logs out, so `core/` never imports a feature.
class SessionExpiry {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

final sessionExpiryProvider = Provider<SessionExpiry>((ref) {
  final expiry = SessionExpiry();
  ref.onDispose(expiry.dispose);
  return expiry;
});

/// Adds the bearer token, and on a 401 refreshes the token once and replays
/// the request.
///
/// Concurrent 401s share one refresh (the [_refreshing] future is the lock).
/// A request that was sent with an old token while another request refreshed
/// is replayed without a second refresh.
///
/// Only a refresh the server *rejects* (4xx) logs out. If the refresh cannot
/// reach the server or gets a 5xx, the session is kept and the request fails
/// with that error (`NetworkException` / `ServerException`).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._refreshDio,
    required this._tokens,
    required this._onSessionExpired,
  });

  /// Set `Options(extra: {AuthInterceptor.public: true})` on requests that
  /// must not carry or refresh a token (login, refresh).
  static const public = 'auth.public';
  static const refreshPath = '/auth/refresh';
  static const _replayed = 'auth.replayed';

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStore _tokens;
  final void Function() _onSessionExpired;

  Future<_Refresh>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[public] != true) {
      final tokens = await _tokens.read();
      if (tokens != null) options.headers['Authorization'] = _bearer(tokens);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra[public] == true ||
        options.extra[_replayed] == true) {
      return handler.next(err);
    }

    final current = await _tokens.read();
    final sentWithOldToken =
        current != null && options.headers['Authorization'] != _bearer(current);
    final result = sentWithOldToken
        ? const _Refreshed()
        : await (_refreshing ??= _refresh().whenComplete(
            () => _refreshing = null,
          ));

    switch (result) {
      case _Rejected():
        _onSessionExpired();
        handler.next(err);
      case _Failed(:final error):
        // Keep the session: the server is unreachable, not refusing the user.
        handler.next(err.copyWith(error: error));
      case _Refreshed():
        try {
          options.extra[_replayed] = true;
          handler.resolve(await _dio.fetch<Object?>(options));
        } on DioException catch (e) {
          handler.next(e);
        }
    }
  }

  Future<_Refresh> _refresh() async {
    final tokens = await _tokens.read();
    if (tokens == null) return const _Rejected();
    try {
      final res = await _refreshDio.post<Map<String, Object?>>(
        refreshPath,
        data: {'refresh_token': tokens.refresh},
        options: Options(extra: {public: true}),
      );
      switch (res.data) {
        case {'access_token': final String a, 'refresh_token': final String r}:
          await _tokens.write(AuthTokens(access: a, refresh: r));
          return const _Refreshed();
        default:
          return const _Rejected();
      }
    } on DioException catch (e) {
      return switch (AppException.fromDio(e)) {
        final error && (NetworkException() || ServerException()) => _Failed(
          error,
        ),
        _ => const _Rejected(),
      };
    }
  }

  static String _bearer(AuthTokens tokens) => 'Bearer ${tokens.access}';
}

/// Outcome of one token refresh.
sealed class _Refresh {
  const _Refresh();
}

final class _Refreshed extends _Refresh {
  const _Refreshed();
}

/// The server refused the refresh token: the session is over.
final class _Rejected extends _Refresh {
  const _Rejected();
}

/// The refresh did not get an answer about the token (offline, 5xx).
final class _Failed extends _Refresh {
  const _Failed(this.error);

  final AppException error;
}

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: Env.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    contentType: Headers.jsonContentType,
  );
  final dio = Dio(options);
  final refreshDio = Dio(options);
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: refreshDio,
      tokens: ref.watch(tokenStoreProvider),
      onSessionExpired: ref.watch(sessionExpiryProvider).notify,
    ),
  );
  ref.onDispose(() {
    dio.close();
    refreshDio.close();
  });
  return dio;
});
