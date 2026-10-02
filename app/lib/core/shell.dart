import 'package:ds/ds.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';

/// The root screens behind the floating tab bar. Each tab keeps its own
/// navigation stack; there is no content slide between tabs.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final l10n = context.l10n;
    return Stack(
      children: [
        Positioned.fill(child: shell),
        const Positioned(left: 0, right: 0, bottom: 0, child: DsTabBarFade()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DsTabBar(
            index: shell.currentIndex,
            onChanged: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            items: [
              DsTabItem(icon: ds.icons.home, label: l10n.tabHome),
              DsTabItem(icon: ds.icons.cards, label: l10n.tabCards),
              DsTabItem(icon: ds.icons.activity, label: l10n.tabActivity),
              DsTabItem(icon: ds.icons.profile, label: l10n.tabProfile),
            ],
          ),
        ),
      ],
    );
  }
}
