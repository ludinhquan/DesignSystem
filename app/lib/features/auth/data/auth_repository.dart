import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/env.dart';
import '../../../core/http.dart';
import '../../../core/storage.dart';
import 'session.dart';

/// Login, logout and restore. Tokens live in [TokenStore] (secure storage).
/// Throws [AppException].
abstract interface class AuthRepository {
  /// Throws [UnauthorizedException] when the credentials are rejected.
  Future<Session> login({required String email, required String password});

  /// Clears local tokens. Never throws: logging out always works offline.
  Future<void> logout();

  /// The session from stored tokens, or `null` when there are none.
  Future<Session?> restore();
}

/// The fake is used until a backend exists (`API_URL` empty).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokens = ref.watch(tokenStoreProvider);
  return Env.hasBackend
      ? HttpAuthRepository(ref.watch(dioProvider), tokens)
      : FakeAuthRepository(tokens);
});

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final res = await guardHttp(
      () => _dio.post<Map<String, Object?>>(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(extra: {AuthInterceptor.public: true}),
      ),
    );
    return switch (res.data) {
      {
        'access_token': final String access,
        'refresh_token': final String refresh,
        'user': final Map<String, Object?> user,
      } =>
        await _save(AuthTokens(access: access, refresh: refresh), user),
      final body => throw UnknownException(FormatException('Bad login: $body')),
    };
  }

  Future<Session> _save(AuthTokens tokens, Map<String, Object?> user) async {
    await _tokens.write(tokens);
    return Session.fromJson(user);
  }

  @override
  Future<void> logout() async {
    final tokens = await _tokens.read();
    await _tokens.clear();
    if (tokens == null) return;
    // Best effort: the local logout already happened.
    try {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refresh_token': tokens.refresh},
        options: Options(extra: {AuthInterceptor.public: true}),
      );
    } on DioException catch (_) {}
  }

  @override
  Future<Session?> restore() async {
    if (await _tokens.read() == null) return null;
    try {
      final res = await guardHttp(() => _dio.get<Map<String, Object?>>('/me'));
      return Session.fromJson(res.data ?? const {});
    } on UnauthorizedException {
      await _tokens.clear();
      return null;
    }
  }
}

/// In-memory backend. Any email works; the password `wrong` is rejected.
/// Tokens still go through [TokenStore], so restore works across restarts.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(
    this._tokens, {
    this.delay = const Duration(milliseconds: 600),
  });

  final TokenStore _tokens;
  final Duration delay;

  static const rejectedPassword = 'wrong';
  static const _prefix = 'fake-access:';

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (password == rejectedPassword) throw const UnauthorizedException();
    await _tokens.write(
      AuthTokens(access: '$_prefix$email', refresh: 'fake-refresh'),
    );
    return _session(email);
  }

  @override
  Future<void> logout() => _tokens.clear();

  @override
  Future<Session?> restore() async {
    final tokens = await _tokens.read();
    if (tokens == null || !tokens.access.startsWith(_prefix)) return null;
    return _session(tokens.access.substring(_prefix.length));
  }

  /// "lan@example.com" → Lan.
  static Session _session(String email) {
    final local = email.split('@').first;
    final name = local.isEmpty
        ? local
        : local[0].toUpperCase() + local.substring(1);
    return Session(userId: 'fake-$email', email: email, name: name);
  }
}
