// GENERATED – do not edit.
// Source: tokens/semantic.json
// Regenerate with: dart run tool/gen_tokens.dart

import 'package:flutter/widgets.dart';

import 'primitives.g.dart';

/// Semantic (tier 2) `space` tokens from `tokens/semantic.json`.
abstract final class SpaceTokens {
  /// `space.none`
  static const double none = PrimitiveSpace.space0;

  /// `space.xxs`
  static const double xxs = PrimitiveSpace.space1;

  /// `space.xs`
  static const double xs = PrimitiveSpace.space2;

  /// `space.sm`
  static const double sm = PrimitiveSpace.space3;

  /// `space.md`
  static const double md = PrimitiveSpace.space4;

  /// `space.lg`
  static const double lg = PrimitiveSpace.space6;

  /// `space.xl`
  static const double xl = PrimitiveSpace.space8;

  /// `space.xxl`
  static const double xxl = PrimitiveSpace.space12;
}

/// Semantic (tier 2) `radius` tokens from `tokens/semantic.json`.
abstract final class RadiusTokens {
  /// `radius.none`
  static const double none = PrimitiveRadius.radius0;

  /// `radius.sm`
  static const double sm = PrimitiveRadius.radius1;

  /// `radius.md`
  static const double md = PrimitiveRadius.radius2;

  /// `radius.lg`
  static const double lg = PrimitiveRadius.radius3;

  /// `radius.xl`
  static const double xl = PrimitiveRadius.radius4;

  /// `radius.pill`
  static const double pill = PrimitiveRadius.full;
}

/// Semantic (tier 2) `size` tokens from `tokens/semantic.json`.
abstract final class SizeTokens {
  /// `size.minTapTarget`
  ///
  /// Minimum interactive area (WCAG 2.5.8 / Material guideline: 48x48).
  static const double minTapTarget = PrimitiveSpace.space12;

  /// `size.iconSm`
  static const double iconSm = PrimitiveSpace.space4;

  /// `size.iconMd`
  static const double iconMd = PrimitiveSpace.space5;

  /// `size.iconLg`
  static const double iconLg = PrimitiveSpace.space6;
}

/// Semantic (tier 2) `typography` tokens from `tokens/semantic.json`.
abstract final class TypographyTokens {
  /// `typography.display`
  static const TextStyle display = TextStyle(
    fontSize: PrimitiveFontSize.xxxl,
    fontWeight: PrimitiveFontWeight.bold,
    height: PrimitiveLineHeight.tight,
    letterSpacing: PrimitiveLetterSpacing.tight,
  );

  /// `typography.headline`
  static const TextStyle headline = TextStyle(
    fontSize: PrimitiveFontSize.xxl,
    fontWeight: PrimitiveFontWeight.semibold,
    height: PrimitiveLineHeight.tight,
    letterSpacing: PrimitiveLetterSpacing.normal,
  );

  /// `typography.title`
  static const TextStyle title = TextStyle(
    fontSize: PrimitiveFontSize.xl,
    fontWeight: PrimitiveFontWeight.semibold,
    height: PrimitiveLineHeight.snug,
    letterSpacing: PrimitiveLetterSpacing.normal,
  );

  /// `typography.body`
  static const TextStyle body = TextStyle(
    fontSize: PrimitiveFontSize.md,
    fontWeight: PrimitiveFontWeight.regular,
    height: PrimitiveLineHeight.normal,
    letterSpacing: PrimitiveLetterSpacing.normal,
  );

  /// `typography.bodySmall`
  static const TextStyle bodySmall = TextStyle(
    fontSize: PrimitiveFontSize.sm,
    fontWeight: PrimitiveFontWeight.regular,
    height: PrimitiveLineHeight.normal,
    letterSpacing: PrimitiveLetterSpacing.normal,
  );

  /// `typography.label`
  static const TextStyle label = TextStyle(
    fontSize: PrimitiveFontSize.sm,
    fontWeight: PrimitiveFontWeight.medium,
    height: PrimitiveLineHeight.snug,
    letterSpacing: PrimitiveLetterSpacing.wide,
  );

  /// `typography.caption`
  static const TextStyle caption = TextStyle(
    fontSize: PrimitiveFontSize.xs,
    fontWeight: PrimitiveFontWeight.regular,
    height: PrimitiveLineHeight.snug,
    letterSpacing: PrimitiveLetterSpacing.wide,
  );
}
