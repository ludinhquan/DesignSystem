import 'package:go_router/go_router.dart';

import 'ui/profile_screen.dart';

abstract final class ProfilePaths {
  static const profile = '/profile';
}

final profileRoutes = <RouteBase>[
  GoRoute(path: ProfilePaths.profile, builder: (_, _) => const ProfileScreen()),
];
