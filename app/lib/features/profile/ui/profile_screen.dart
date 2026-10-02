import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../../auth/data/session_controller.dart';
import '../../wallet/data/wallet_controller.dart';

/// The person, their settings (language, hidden balances) and logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const Scaffold(body: DsLoading());
    final l10n = context.l10n;
    final ds = context.ds;
    final hidden = ref.watch(balanceHiddenProvider);
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    final words = session.name.split(RegExp(r'\s+'));
    final initials = words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsetsDirectional.only(bottom: ds.size.tabbarFade),
          children: [
            DsNavigationBar.large(title: l10n.profileTitle),
            SizedBox(height: ds.spacing.s5),
            DsListSection.grouped(
              children: [
                DsListItem.settings(
                  leading: DsMonogram(initials, field: DsField.graphite),
                  title: session.name,
                  subtitle: session.email,
                ),
              ],
            ),
            SizedBox(height: ds.spacing.s8),
            DsListSection.grouped(
              header: l10n.profileSettings,
              footer: l10n.settingsHideBalanceFooter,
              children: [
                DsListItem.settings(
                  key: const Key('profile.language'),
                  title: l10n.settingsLanguage,
                  glyph: ds.icons.language,
                  value: l10n.languageName,
                  accessory: DsAccessory.chevron,
                  onTap: () => _pickLanguage(context, ref),
                ),
                DsListItem.settings(
                  title: l10n.settingsHideBalance,
                  glyph: ds.icons.eyeOff,
                  trailing: DsToggle(
                    key: const Key('profile.hide'),
                    value: hidden,
                    semanticLabel: l10n.settingsHideBalance,
                    onChanged: ref.read(balanceHiddenProvider.notifier).set,
                  ),
                ),
              ],
            ),
            SizedBox(height: ds.spacing.s8),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
              child: DsButton(
                key: const Key('profile.logout'),
                label: l10n.logout,
                icon: ds.icons.logout,
                variant: DsButtonVariant.destructive,
                size: DsButtonSize.lg,
                block: true,
                onPressed: ref.read(sessionProvider.notifier).logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickLanguage(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    return showDsSheet<void>(
      context: context,
      builder: (sheetContext) => DsSheet(
        title: sheetContext.l10n.settingsLanguage,
        child: DsListSection.grouped(
          children: [
            for (final locale in AppLocalizations.supportedLocales)
              DsListItem.settings(
                title: lookupAppLocalizations(locale).languageName,
                accessory: locale.languageCode == current
                    ? DsAccessory.check
                    : DsAccessory.none,
                onTap: () {
                  DsHaptics.selection(sheetContext);
                  ref.read(localeProvider.notifier).set(locale);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
