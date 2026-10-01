// GENERATED – do not edit.
// Source: tokens/semantic.light.json, tokens/semantic.dark.json
// Regenerate with: dart run tool/gen_tokens.dart

import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Themed `color` tokens exposed as a [ThemeExtension].
///
/// Read it with `context.colors` (see `context_extensions.dart`).
/// Built from [ColorTokens]; supports [copyWith] and [lerp]
/// so theme switches animate.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a `color` theme extension.
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.stateHover,
    required this.statePressed,
    required this.stateFocus,
  });

  /// Creates the extension from a generated [ColorTokens] mode.
  AppColors.fromTokens(ColorTokens tokens)
    : background = tokens.background,
      surface = tokens.surface,
      surfaceRaised = tokens.surfaceRaised,
      surfaceSunken = tokens.surfaceSunken,
      primary = tokens.primary,
      onPrimary = tokens.onPrimary,
      primaryContainer = tokens.primaryContainer,
      onPrimaryContainer = tokens.onPrimaryContainer,
      secondary = tokens.secondary,
      onSecondary = tokens.onSecondary,
      textPrimary = tokens.textPrimary,
      textSecondary = tokens.textSecondary,
      textDisabled = tokens.textDisabled,
      borderDefault = tokens.borderDefault,
      borderStrong = tokens.borderStrong,
      borderFocus = tokens.borderFocus,
      success = tokens.success,
      onSuccess = tokens.onSuccess,
      warning = tokens.warning,
      onWarning = tokens.onWarning,
      danger = tokens.danger,
      onDanger = tokens.onDanger,
      disabledBackground = tokens.disabledBackground,
      disabledForeground = tokens.disabledForeground,
      stateHover = tokens.stateHover,
      statePressed = tokens.statePressed,
      stateFocus = tokens.stateFocus;

  /// `light` mode.
  static final AppColors light = AppColors.fromTokens(ColorTokens.light);

  /// `dark` mode.
  static final AppColors dark = AppColors.fromTokens(ColorTokens.dark);

  /// `color.background`
  ///
  /// App/page background behind all surfaces.
  final Color background;

  /// `color.surface`
  final Color surface;

  /// `color.surfaceRaised`
  ///
  /// Cards, sheets and other elevated containers.
  final Color surfaceRaised;

  /// `color.surfaceSunken`
  final Color surfaceSunken;

  /// `color.primary`
  final Color primary;

  /// `color.onPrimary`
  final Color onPrimary;

  /// `color.primaryContainer`
  final Color primaryContainer;

  /// `color.onPrimaryContainer`
  final Color onPrimaryContainer;

  /// `color.secondary`
  final Color secondary;

  /// `color.onSecondary`
  final Color onSecondary;

  /// `color.text.primary`
  final Color textPrimary;

  /// `color.text.secondary`
  ///
  /// Supporting text; must keep >= 4.5:1 contrast on surface.
  final Color textSecondary;

  /// `color.text.disabled`
  final Color textDisabled;

  /// `color.border.default`
  final Color borderDefault;

  /// `color.border.strong`
  final Color borderStrong;

  /// `color.border.focus`
  ///
  /// Focus ring colour for keyboard navigation.
  final Color borderFocus;

  /// `color.success`
  final Color success;

  /// `color.onSuccess`
  final Color onSuccess;

  /// `color.warning`
  final Color warning;

  /// `color.onWarning`
  final Color onWarning;

  /// `color.danger`
  final Color danger;

  /// `color.onDanger`
  final Color onDanger;

  /// `color.disabled.background`
  final Color disabledBackground;

  /// `color.disabled.foreground`
  final Color disabledForeground;

  /// `color.state.hover`
  ///
  /// Overlay painted on interactive elements while hovered.
  final Color stateHover;

  /// `color.state.pressed`
  ///
  /// Overlay painted on interactive elements while pressed.
  final Color statePressed;

  /// `color.state.focus`
  final Color stateFocus;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? stateHover,
    Color? statePressed,
    Color? stateFocus,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      stateHover: stateHover ?? this.stateHover,
      statePressed: statePressed ?? this.statePressed,
      stateFocus: stateFocus ?? this.stateFocus,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      disabledBackground: Color.lerp(
        disabledBackground,
        other.disabledBackground,
        t,
      )!,
      disabledForeground: Color.lerp(
        disabledForeground,
        other.disabledForeground,
        t,
      )!,
      stateHover: Color.lerp(stateHover, other.stateHover, t)!,
      statePressed: Color.lerp(statePressed, other.statePressed, t)!,
      stateFocus: Color.lerp(stateFocus, other.stateFocus, t)!,
    );
  }
}
