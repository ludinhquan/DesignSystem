import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps golden content in a material_ui [Theme].
///
/// alchemist builds its shell on the in-SDK Material library, whose theme is
/// a different type that material_ui widgets cannot see.
Widget themed(ThemeData theme, Widget child) => Theme(
  data: theme,
  child: Material(
    color: theme.colorScheme.surface,
    child: Padding(
      padding: EdgeInsetsDirectional.all(DsSpacing.standard.md),
      child: child,
    ),
  ),
);

extension PumpDs on WidgetTester {
  /// Pumps [child] in a material_ui app with the default DS theme.
  Future<void> pumpDs(Widget child, {ThemeData? theme}) => pumpWidget(
    MaterialApp(
      theme: theme ?? DsTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
