// Widget previews: `flutter widget-preview start` in packages/ds.

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/ds_theme.dart';
import '../theme/ds_tokens.dart';
import 'ds_button.dart';

/// Light theme wrapper. The previewer's own shell is built on the in-SDK
/// Material library, so the material_ui [Theme] is provided here.
Widget dsLightPreview(Widget child) => _wrap(DsTheme.light(), child);

/// Dark theme wrapper.
Widget dsDarkPreview(Widget child) => _wrap(DsTheme.dark(), child);

Widget _wrap(ThemeData theme, Widget child) => Theme(
  data: theme,
  child: Builder(
    builder: (context) => Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsetsDirectional.all(context.ds.spacing.md),
        child: Center(child: child),
      ),
    ),
  ),
);

@Preview(group: 'DsButton', name: 'Light', wrapper: dsLightPreview)
@Preview(
  group: 'DsButton',
  name: 'Dark',
  wrapper: dsDarkPreview,
  brightness: Brightness.dark,
)
Widget dsButtonPreview() => Builder(
  builder: (context) => Wrap(
    spacing: context.ds.spacing.sm,
    runSpacing: context.ds.spacing.sm,
    children: [
      DsButton(label: 'Primary', onPressed: () {}),
      DsButton(
        label: 'Secondary',
        variant: DsButtonVariant.secondary,
        onPressed: () {},
      ),
      DsButton(
        label: 'Ghost',
        variant: DsButtonVariant.ghost,
        onPressed: () {},
      ),
      const DsButton(label: 'Disabled', onPressed: null),
      DsButton(label: 'Loading', loading: true, onPressed: () {}),
    ],
  ),
);
