import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/brand.dart';
import '../../../l10n/l10n.dart';
import 'language_switch.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ds = context.ds;
    final text = Theme.of(context).textTheme;
    final appName = ref.watch(brandProvider).appName;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: EdgeInsetsDirectional.all(ds.spacing.lg),
        children: [
          Text(l10n.homeWelcome(appName), style: text.headlineSmall),
          SizedBox(height: ds.spacing.md),
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
        ],
      ),
    );
  }
}
