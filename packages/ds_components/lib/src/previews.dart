// Flutter Widget Previews (`flutter widget-preview start`).
//
// Each preview is rendered in light, dark and light at 2x text so the
// author sees the golden-test matrix while iterating.

import 'package:ds_foundation/ds_foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

import 'button/app_button.dart';
import 'card/app_card.dart';

/// Wraps a preview in the light design-system theme.
Widget lightThemeWrapper(Widget child) => _wrap(AppTheme.light(), child);

/// Wraps a preview in the dark design-system theme.
Widget darkThemeWrapper(Widget child) => _wrap(AppTheme.dark(), child);

Widget _wrap(ThemeData theme, Widget child) {
  // The previewer's own app shell uses package:flutter/material.dart, so the
  // material_ui Theme must be provided explicitly here.
  return Theme(
    data: theme,
    child: Builder(
      builder: (context) => Material(
        color: context.colors.background,
        child: Padding(
          padding: EdgeInsetsDirectional.all(context.spacing.md),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

/// [AppButton] variants and states.
@Preview(group: 'AppButton', name: 'Light', wrapper: lightThemeWrapper)
@Preview(
  group: 'AppButton',
  name: 'Dark',
  wrapper: darkThemeWrapper,
  brightness: Brightness.dark,
)
@Preview(
  group: 'AppButton',
  name: 'Light, 2x text',
  wrapper: lightThemeWrapper,
  textScaleFactor: 2,
)
Widget appButtonPreview() {
  return Builder(
    builder: (context) => Wrap(
      spacing: context.spacing.sm,
      runSpacing: context.spacing.sm,
      children: [
        AppButton.primary(label: 'Primary', onPressed: () {}),
        AppButton.secondary(label: 'Secondary', onPressed: () {}),
        AppButton.ghost(label: 'Ghost', onPressed: () {}),
        const AppButton.primary(label: 'Disabled', onPressed: null),
        AppButton.primary(label: 'Loading', isLoading: true, onPressed: () {}),
      ],
    ),
  );
}

/// [AppCard] static and interactive.
@Preview(group: 'AppCard', name: 'Light', wrapper: lightThemeWrapper)
@Preview(
  group: 'AppCard',
  name: 'Dark',
  wrapper: darkThemeWrapper,
  brightness: Brightness.dark,
)
Widget appCardPreview() {
  return Builder(
    builder: (context) => AppCard(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card title', style: context.typography.title),
          SizedBox(height: context.spacing.xs),
          const Text('Cards use surfaceRaised, borderDefault and radius.lg.'),
        ],
      ),
    ),
  );
}
