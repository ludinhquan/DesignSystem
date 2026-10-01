import 'package:material_ui/material_ui.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'generated/app_colors.g.dart';

/// Shorthand accessors for the design-system theme extensions.
///
/// ```dart
/// Text('Saved', style: context.typography.body.copyWith(
///   color: context.colors.success,
/// ));
/// ```
extension AppThemeContext on BuildContext {
  /// Semantic colours of the nearest [Theme].
  AppColors get colors => _extension<AppColors>();

  /// Spacing scale of the nearest [Theme].
  AppSpacing get spacing => _extension<AppSpacing>();

  /// Corner radii of the nearest [Theme].
  AppRadius get radius => _extension<AppRadius>();

  /// Type scale of the nearest [Theme].
  AppTypography get typography => _extension<AppTypography>();

  T _extension<T extends ThemeExtension<T>>() {
    final value = Theme.of(this).extension<T>();
    if (value == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No $T found in the current Theme.'),
        ErrorHint(
          'Provide AppTheme.light() / AppTheme.dark() through the '
          'package:material_ui MaterialApp or Theme widget. A Theme from '
          'package:flutter/material.dart is a different type and is not '
          'visible here.',
        ),
      ]);
    }
    return value;
  }
}
