// Tier 2: semantic tokens. Names say what a value is FOR.
//
// Light/dark and per-brand differences live only at this tier (and in the
// ColorScheme built by DsTheme). Components read these, never primitives.

import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import 'primitives.dart';

/// Spacing by intent.
@immutable
class DsSpacing {
  const DsSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// The default spacing set, shared by all brands.
  static const standard = DsSpacing(
    xxs: DsSpaceScale.s1,
    xs: DsSpaceScale.s2,
    sm: DsSpaceScale.s3,
    md: DsSpaceScale.s4,
    lg: DsSpaceScale.s6,
    xl: DsSpaceScale.s8,
  );

  final double xxs, xs, sm, md, lg, xl;

  DsSpacing lerp(DsSpacing other, double t) => DsSpacing(
    xxs: lerpDouble(xxs, other.xxs, t)!,
    xs: lerpDouble(xs, other.xs, t)!,
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
  );
}

/// Corner radii by intent. Derived from a brand's base radius.
@immutable
class DsRadii {
  const DsRadii({
    required this.sm,
    required this.md,
    required this.lg,
    required this.full,
  });

  /// [base] is the brand's control radius; cards get a bit more, chips less.
  factory DsRadii.fromBase(double base) =>
      DsRadii(sm: base / 2, md: base, lg: base * 1.5, full: DsRadiusScale.full);

  /// Radii for the default base radius.
  static final standard = DsRadii.fromBase(DsRadiusScale.r3);

  /// Small elements: chips, badges.
  final double sm;

  /// Controls: buttons, text fields.
  final double md;

  /// Containers: cards, sheets.
  final double lg;

  /// Pills and circles.
  final double full;

  DsRadii lerp(DsRadii other, double t) => DsRadii(
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    full: lerpDouble(full, other.full, t)!,
  );
}

/// Fixed sizes that never change per brand or theme.
abstract final class DsSize {
  /// Minimum interactive area (WCAG / Material guidance).
  static const minTapTarget = DsSpaceScale.s12;

  static const controlSm = DsSpaceScale.s8;
  static const controlMd = DsSpaceScale.s10;
  static const controlLg = DsSpaceScale.s12;

  static const iconSm = DsSpaceScale.s4;
  static const iconMd = DsSpaceScale.s5;
  static const iconLg = DsSpaceScale.s6;

  static const borderThin = 1.0;
  static const focusRing = 2.0;
  static const spinnerStroke = 2.0;
}

/// Opacity of state layers and disabled content (Material 3 values).
abstract final class DsOpacity {
  static const disabledContent = 0.38;
  static const disabledContainer = 0.12;
  static const hover = 0.08;
  static const focus = 0.10;
  static const pressed = 0.10;
}

/// Extra semantic colors (beyond ColorScheme) for light mode.
abstract final class DsLightColors {
  static const success = DsPalette.green700;
  static const onSuccess = DsPalette.white;
  static const warning = DsPalette.amber700;
  static const onWarning = DsPalette.white;
  static const textMuted = DsPalette.neutral500;
  static const border = DsPalette.neutral200;
}

/// Extra semantic colors (beyond ColorScheme) for dark mode.
abstract final class DsDarkColors {
  static const success = DsPalette.green300;
  static const onSuccess = DsPalette.green900;
  static const warning = DsPalette.amber300;
  static const onWarning = DsPalette.amber900;
  static const textMuted = DsPalette.neutral400;
  static const border = DsPalette.neutral700;
}
