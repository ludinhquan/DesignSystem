import 'package:ds_components/ds_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Test helpers that provide the design-system theme.
extension PumpApp on WidgetTester {
  /// Pumps [child] inside a `material_ui` [MaterialApp] themed with the
  /// design system, optionally with a custom text scale.
  Future<void> pumpApp(Widget child, {ThemeData? theme, double textScale = 1}) {
    return pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light(),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }
}

/// Wraps [child] in a `material_ui` [Theme] + background [Material].
///
/// Needed for alchemist goldens, whose own app shell is built on
/// `package:flutter/material.dart` and therefore cannot provide a theme that
/// `material_ui` widgets see.
Widget themed(ThemeData theme, Widget child) {
  return Theme(
    data: theme,
    child: Builder(
      builder: (context) => Material(
        color: context.colors.background,
        child: Padding(
          padding: EdgeInsetsDirectional.all(context.spacing.md),
          child: child,
        ),
      ),
    ),
  );
}
