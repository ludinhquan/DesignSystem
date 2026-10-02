import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_routes.dart';
import '../features/auth/data/session.dart';
import '../features/auth/data/session_controller.dart';
import '../features/home/home_routes.dart';

/// Assembles every feature's routes and guards them with the session.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<AsyncValue<Session?>>(
    ref.read(sessionProvider),
  );
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    initialLocation: HomePaths.home,
    refreshListenable: session,
    redirect: (_, state) => authRedirect(session.value, state.uri),
    routes: [...authRoutes, ...homeRoutes],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});

/// Where to send the user, or `null` to stay. Pure, so it is unit-tested.
///
/// * Session still restoring: `/splash?from=<location>`.
/// * Logged out: `/login?from=<location>` (no `from` for home).
/// * Logged in on `/login` or `/splash`: back to `from`, else home.
String? authRedirect(AsyncValue<Session?> session, Uri location) {
  final path = location.path;
  final from = location.queryParameters['from'];
  final atAuthPage = path == AuthPaths.login || path == AuthPaths.splash;

  if (!session.hasValue && !session.hasError) {
    return path == AuthPaths.splash
        ? null
        : AuthPaths.splashFrom(atAuthPage ? from : _target(location));
  }

  // A failed restore counts as logged out.
  if (session.value == null) {
    if (path == AuthPaths.login) return null;
    return AuthPaths.loginFrom(atAuthPage ? from : _target(location));
  }

  if (atAuthPage) return _safe(from) ?? HomePaths.home;
  return null;
}

/// The location to come back to, or `null` for home.
String? _target(Uri location) {
  final target = location.toString();
  return target == HomePaths.home ? null : target;
}

/// Only same-app paths, never an auth page or another host (`//evil.com`).
String? _safe(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  final path = Uri.parse(from).path;
  if (path == AuthPaths.login || path == AuthPaths.splash) return null;
  return from;
}
