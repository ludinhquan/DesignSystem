// GENERATED – do not edit.
// Source: tokens/semantic.light.json, tokens/semantic.dark.json
// Regenerate with: dart run tool/gen_tokens.dart

import 'package:flutter/widgets.dart';

import 'primitives.g.dart';

/// Semantic (tier 2) themed `color` tokens. One instance per mode: [light], [dark].
///
/// Source: `tokens/semantic.light.json`, `tokens/semantic.dark.json`.
final class ColorTokens {
  /// Creates a set of `color` tokens.
  const ColorTokens({
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

  /// `light` mode values.
  static const ColorTokens light = ColorTokens(
    background: PrimitiveColor.slate50,
    surface: PrimitiveColor.white,
    surfaceRaised: PrimitiveColor.white,
    surfaceSunken: PrimitiveColor.slate100,
    primary: PrimitiveColor.blue600,
    onPrimary: PrimitiveColor.white,
    primaryContainer: PrimitiveColor.blue100,
    onPrimaryContainer: PrimitiveColor.blue900,
    secondary: PrimitiveColor.slate700,
    onSecondary: PrimitiveColor.white,
    textPrimary: PrimitiveColor.slate900,
    textSecondary: PrimitiveColor.slate600,
    textDisabled: PrimitiveColor.slate400,
    borderDefault: PrimitiveColor.slate200,
    borderStrong: PrimitiveColor.slate300,
    borderFocus: PrimitiveColor.blue600,
    success: PrimitiveColor.green700,
    onSuccess: PrimitiveColor.white,
    warning: PrimitiveColor.amber700,
    onWarning: PrimitiveColor.white,
    danger: PrimitiveColor.red600,
    onDanger: PrimitiveColor.white,
    disabledBackground: PrimitiveColor.slate100,
    disabledForeground: PrimitiveColor.slate400,
    stateHover: PrimitiveColor.alphaBlack8,
    statePressed: PrimitiveColor.alphaBlack12,
    stateFocus: PrimitiveColor.alphaBlack12,
  );

  /// `dark` mode values.
  static const ColorTokens dark = ColorTokens(
    background: PrimitiveColor.slate950,
    surface: PrimitiveColor.slate900,
    surfaceRaised: PrimitiveColor.slate800,
    surfaceSunken: PrimitiveColor.slate950,
    primary: PrimitiveColor.blue400,
    onPrimary: PrimitiveColor.slate950,
    primaryContainer: PrimitiveColor.blue900,
    onPrimaryContainer: PrimitiveColor.blue100,
    secondary: PrimitiveColor.slate300,
    onSecondary: PrimitiveColor.slate900,
    textPrimary: PrimitiveColor.slate50,
    textSecondary: PrimitiveColor.slate400,
    textDisabled: PrimitiveColor.slate600,
    borderDefault: PrimitiveColor.slate700,
    borderStrong: PrimitiveColor.slate600,
    borderFocus: PrimitiveColor.blue400,
    success: PrimitiveColor.green300,
    onSuccess: PrimitiveColor.green900,
    warning: PrimitiveColor.amber300,
    onWarning: PrimitiveColor.amber900,
    danger: PrimitiveColor.red300,
    onDanger: PrimitiveColor.red900,
    disabledBackground: PrimitiveColor.slate800,
    disabledForeground: PrimitiveColor.slate500,
    stateHover: PrimitiveColor.alphaWhite8,
    statePressed: PrimitiveColor.alphaWhite12,
    stateFocus: PrimitiveColor.alphaWhite12,
  );

  /// All modes, keyed by name.
  static const Map<String, ColorTokens> modes = {'light': light, 'dark': dark};

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
}
