import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Every design system the package ships. Goldens and contract tests run
/// over all of them, so adding a system gets it checked for free.
final systems = <String, DsSystem>{'pebble': pebble, 'classic': classic};

/// Wraps golden content in a material_ui [Theme], material_ui's English
/// [MaterialLocalizations] and the English [DsLocalizations].
///
/// alchemist builds its shell on the in-SDK Material library, whose theme and
/// localizations are different types that material_ui widgets cannot see.
Widget themed(ThemeData theme, Widget child) => Theme(
  data: theme,
  child: Builder(
    builder: (context) => Localizations.override(
      context: context,
      delegates: const [
        DsLocalizations.englishDelegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: Material(
        color: context.ds.colors.canvas,
        child: Padding(
          padding: EdgeInsetsDirectional.all(context.ds.spacing.s5),
          child: child,
        ),
      ),
    ),
  ),
);

extension PumpDs on WidgetTester {
  /// Pumps [child] in a material_ui app themed with [system].
  Future<void> pumpDs(
    Widget child, {
    DsSystem? system,
    bool dark = false,
    List<LocalizationsDelegate<Object?>> localizationsDelegates = const [
      DsLocalizations.englishDelegate,
    ],
  }) => pumpWidget(
    MaterialApp(
      theme: dark
          ? DsTheme.dark(system ?? pebble)
          : DsTheme.light(system ?? pebble),
      localizationsDelegates: localizationsDelegates,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}
