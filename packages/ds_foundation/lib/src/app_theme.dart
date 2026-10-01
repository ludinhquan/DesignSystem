import 'package:material_ui/material_ui.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'generated/app_colors.g.dart';

/// Builds [ThemeData] from the design tokens.
///
/// Tokens that Material understands are mapped onto [ColorScheme] and
/// [TextTheme] so stock Material widgets look right; everything else is
/// attached as a [ThemeExtension] ([AppColors], [AppSpacing], [AppRadius],
/// [AppTypography]).
abstract final class AppTheme {
  /// The light theme.
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  /// The dark theme.
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    const spacing = AppSpacing.standard;
    const radius = AppRadius.standard;
    const typography = AppTypography.standard;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      error: colors.danger,
      onError: colors.onDanger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerLowest: colors.surfaceSunken,
      surfaceContainerHighest: colors.surfaceRaised,
      outline: colors.borderStrong,
      outlineVariant: colors.borderDefault,
    );

    final textTheme = TextTheme(
      displayMedium: typography.display,
      headlineMedium: typography.headline,
      titleLarge: typography.title,
      titleMedium: typography.title,
      bodyLarge: typography.body,
      bodyMedium: typography.bodySmall,
      bodySmall: typography.caption,
      labelLarge: typography.label,
      labelMedium: typography.caption,
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.borderDefault,
      disabledColor: colors.disabledForeground,
      hoverColor: colors.stateHover,
      focusColor: colors.stateFocus,
      highlightColor: colors.statePressed,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[
        colors,
        spacing,
        radius,
        typography,
      ],
    );
  }
}
