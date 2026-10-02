import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/brand.dart';
import '../../../l10n/l10n.dart';
import '../../auth/data/session_controller.dart';
import 'language_switch.dart';
import 'tap_count_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    // Logged out: the router is about to redirect to /login.
    if (session == null) return const Scaffold(body: DsLoading());

    final l10n = context.l10n;
    final ds = context.ds;
    final text = Theme.of(context).textTheme;
    final appName = ref.watch(brandProvider).appName;
    final taps = ref.watch(tapCountProvider);
    final gap = SizedBox(height: ds.spacing.md);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: EdgeInsetsDirectional.all(ds.spacing.lg),
        children: [
          Text(
            l10n.homeWelcome(appName, session.name),
            style: text.headlineSmall,
          ),
          Text(
            session.email,
            style: text.bodyMedium?.copyWith(color: ds.textMuted),
          ),
          gap,
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeTapCount(taps), style: text.titleMedium),
                SizedBox(height: ds.spacing.sm),
                DsButton(
                  label: l10n.homeTap,
                  icon: Icons.add,
                  onPressed: ref.read(tapCountProvider.notifier).increment,
                ),
              ],
            ),
          ),
          gap,
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeLanguage, style: text.titleMedium),
                SizedBox(height: ds.spacing.sm),
                const LanguageSwitch(),
              ],
            ),
          ),
          gap,
          DsButton(
            label: l10n.logout,
            icon: Icons.logout,
            variant: DsButtonVariant.secondary,
            onPressed: ref.read(sessionProvider.notifier).logout,
          ),
        ],
      ),
    );
  }
}
