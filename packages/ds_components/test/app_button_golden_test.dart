@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:ds_components/ds_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// Golden matrix: theme (light/dark) x text scale (1.0/2.0).
///
/// Regenerate with:
///   flutter test --update-goldens --tags golden
/// (or `melos run test:update-goldens`) and review the PNG diff.
void main() {
  const themes = <String, ThemeData Function()>{
    'light': AppTheme.light,
    'dark': AppTheme.dark,
  };
  const textScales = [1.0, 2.0];

  for (final theme in themes.entries) {
    for (final scale in textScales) {
      goldenTest(
        'AppButton renders correctly (${theme.key}, ${scale}x text)',
        fileName: 'app_button_${theme.key}_${scale.toInt()}x',
        textScaleFactor: scale,
        // The loading spinner never settles: advance it a fixed, deterministic
        // amount instead of pumpAndSettle.
        pumpBeforeTest: pumpNTimes(2, const Duration(milliseconds: 250)),
        builder: () => themed(theme.value(), _matrix()),
      );
    }
  }
}

Widget _matrix() {
  void noop() {}
  return GoldenTestGroup(
    columns: 3,
    children: [
      for (final variant in AppButtonVariant.values) ...[
        GoldenTestScenario(
          name: '${variant.name} enabled',
          child: AppButton(label: 'Label', variant: variant, onPressed: noop),
        ),
        GoldenTestScenario(
          name: '${variant.name} disabled',
          child: AppButton(label: 'Label', variant: variant, onPressed: null),
        ),
        GoldenTestScenario(
          name: '${variant.name} loading',
          child: AppButton(
            label: 'Label',
            variant: variant,
            isLoading: true,
            onPressed: noop,
          ),
        ),
      ],
      for (final size in AppButtonSize.values)
        GoldenTestScenario(
          name: 'size ${size.name}',
          child: AppButton(
            label: 'Label',
            size: size,
            icon: Icons.add,
            onPressed: noop,
          ),
        ),
    ],
  );
}
