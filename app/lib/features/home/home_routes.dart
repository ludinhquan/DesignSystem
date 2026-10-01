import 'package:go_router/go_router.dart';

import 'ui/home_screen.dart';

abstract final class HomePaths {
  static const home = '/';
}

final homeRoutes = <RouteBase>[
  GoRoute(path: HomePaths.home, builder: (_, _) => const HomeScreen()),
];
