import 'package:go_router/go_router.dart';

import 'ui/activity_screen.dart';
import 'ui/cards_screen.dart';
import 'ui/home_screen.dart';
import 'ui/pay_screen.dart';

abstract final class WalletPaths {
  static const home = '/';
  static const cards = '/cards';
  static const activity = '/activity';
  static String pay(String accountId) => '/pay/$accountId';
}

/// Tab roots, one list per tab (the shell builds a branch from each).
final walletHomeRoutes = <RouteBase>[
  GoRoute(path: WalletPaths.home, builder: (_, _) => const HomeScreen()),
];
final walletCardsRoutes = <RouteBase>[
  GoRoute(path: WalletPaths.cards, builder: (_, _) => const CardsScreen()),
];
final walletActivityRoutes = <RouteBase>[
  GoRoute(
    path: WalletPaths.activity,
    builder: (_, _) => const ActivityScreen(),
  ),
];

/// Pushed above the tab bar.
final walletRoutes = <RouteBase>[
  GoRoute(
    path: '/pay/:accountId',
    builder: (_, state) =>
        PayScreen(accountId: state.pathParameters['accountId']!),
  ),
];
