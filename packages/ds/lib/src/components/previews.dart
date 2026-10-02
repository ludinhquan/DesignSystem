// Widget previews: `flutter widget-preview start` in packages/ds.

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/ds_colors.dart';
import '../l10n/ds_localizations.dart';
import '../systems/classic/classic.dart';
import '../systems/pebble/pebble.dart';
import '../theme/ds_theme.dart';
import '../theme/ds_tokens.dart';
import 'ds_account_card.dart';
import 'ds_button.dart';

/// The previewer's shell is built on the in-SDK Material library, so the
/// material_ui [Theme] and the English [DsLocalizations] are provided here.
Widget pebbleLight(Widget child) => _wrap(DsTheme.light(pebble), child);
Widget pebbleDark(Widget child) => _wrap(DsTheme.dark(pebble), child);
Widget classicLight(Widget child) => _wrap(DsTheme.light(classic), child);

Widget _wrap(ThemeData theme, Widget child) => Theme(
  data: theme,
  child: Builder(
    builder: (context) => Localizations.override(
      context: context,
      delegates: const [DsLocalizations.englishDelegate],
      child: ColoredBox(
        color: context.ds.colors.canvas,
        child: Padding(
          padding: EdgeInsetsDirectional.all(context.ds.spacing.s5),
          child: Center(child: child),
        ),
      ),
    ),
  ),
);

@Preview(group: 'Button', name: 'Pebble light', wrapper: pebbleLight)
@Preview(
  group: 'Button',
  name: 'Pebble dark',
  wrapper: pebbleDark,
  brightness: Brightness.dark,
)
@Preview(group: 'Button', name: 'Classic light', wrapper: classicLight)
Widget buttonPreview() => Builder(
  builder: (context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final v in DsButtonVariant.values)
        DsButton(label: v.name, variant: v, onPressed: () {}),
      DsButton(label: 'Loading', loading: true, onPressed: () {}),
    ],
  ),
);

@Preview(group: 'AccountCard', name: 'Pebble light', wrapper: pebbleLight)
@Preview(group: 'AccountCard', name: 'Classic light', wrapper: classicLight)
Widget cardPreview() => const DsAccountCard(
  data: DsCardData(
    id: 'daily',
    field: DsField.yellow,
    institution: 'Techcombank',
    name: 'Chi tiêu hằng ngày',
    balance: 12450000,
    last4: '4821',
  ),
);
