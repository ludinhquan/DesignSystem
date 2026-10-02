import 'package:go_router/go_router.dart';

import 'ui/login_screen.dart';
import 'ui/splash_screen.dart';

abstract final class AuthPaths {
  static const login = '/login';

  /// Shown while the stored session is restored at startup.
  static const splash = '/splash';

  /// `/login?from=<path>`: after login the router returns to `from`.
  static String loginFrom(String? from) => Uri(
    path: login,
    queryParameters: from == null ? null : {'from': from},
  ).toString();

  /// `/splash?from=<path>`, so a deep link survives the startup restore.
  static String splashFrom(String? from) => Uri(
    path: splash,
    queryParameters: from == null ? null : {'from': from},
  ).toString();
}

final authRoutes = <RouteBase>[
  GoRoute(path: AuthPaths.splash, builder: (_, _) => const SplashScreen()),
  GoRoute(path: AuthPaths.login, builder: (_, _) => const LoginScreen()),
];
