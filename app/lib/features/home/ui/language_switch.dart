import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';

/// One segment per supported locale, each labeled in its own language.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        for (final locale in AppLocalizations.supportedLocales)
          ButtonSegment(
            value: locale.languageCode,
            label: Text(lookupAppLocalizations(locale).languageName),
          ),
      ],
      selected: {current},
      onSelectionChanged: (selection) =>
          ref.read(localeProvider.notifier).set(Locale(selection.single)),
    );
  }
}
