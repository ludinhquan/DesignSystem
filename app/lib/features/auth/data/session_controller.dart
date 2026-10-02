import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics.dart';
import '../../../core/http.dart';
import 'auth_repository.dart';
import 'session.dart';

/// The single source of auth state: `AsyncData(null)` is logged out.
///
/// It lives in `data/` so other features (and the router) can depend on it.
///
/// **Rule:** every per-user provider does `ref.watch(sessionProvider)`, so a
/// logout (or a different user logging in) rebuilds it from scratch.
final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<Session?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// The person chose to log out (as opposed to a session that expired).
  /// The router then sends them to plain `/login`, not back to where they
  /// were: the next person to sign in should start at home.
  bool loggedOutByUser = false;

  @override
  Future<Session?> build() async {
    final sub = ref
        .watch(sessionExpiryProvider)
        .stream
        .listen((_) => unawaited(logout(byUser: false)));
    ref.onDispose(sub.cancel);
    try {
      return await _repo.restore();
    } on AppException {
      // Offline at startup, or a broken token: start logged out.
      return null;
    }
  }

  /// Throws [AppException]; the state is unchanged on failure, so the router
  /// does not move while the login screen shows the error.
  Future<void> login({required String email, required String password}) async {
    final session = await _repo.login(email: email, password: password);
    loggedOutByUser = false;
    ref.read(analyticsProvider)
      ..identify(session.userId)
      ..track(Events.login);
    state = AsyncData(session);
  }

  /// Clears tokens and analytics identity, then sets `AsyncData(null)`.
  /// The state is cleared even if clearing storage fails. [byUser] is false
  /// when the server ended the session.
  Future<void> logout({bool byUser = true}) async {
    loggedOutByUser = byUser;
    try {
      await _repo.logout();
    } finally {
      ref.read(analyticsProvider)
        ..track(Events.logout)
        ..reset();
      state = const AsyncData(null);
    }
  }
}
