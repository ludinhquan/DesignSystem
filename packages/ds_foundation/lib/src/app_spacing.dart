import 'dart:ui' show lerpDouble;

import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Semantic spacing scale as a [ThemeExtension].
///
/// Values come from [SpaceTokens]. A brand or density variant can override
/// them with [copyWith] without touching any component.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Creates a spacing scale.
  const AppSpacing({
    required this.none,
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// The default spacing scale generated from `tokens/semantic.json`.
  static const AppSpacing standard = AppSpacing(
    none: SpaceTokens.none,
    xxs: SpaceTokens.xxs,
    xs: SpaceTokens.xs,
    sm: SpaceTokens.sm,
    md: SpaceTokens.md,
    lg: SpaceTokens.lg,
    xl: SpaceTokens.xl,
    xxl: SpaceTokens.xxl,
  );

  /// No spacing.
  final double none;

  /// 2x-small spacing.
  final double xxs;

  /// Extra-small spacing.
  final double xs;

  /// Small spacing.
  final double sm;

  /// Medium spacing (default gap / padding).
  final double md;

  /// Large spacing.
  final double lg;

  /// Extra-large spacing.
  final double xl;

  /// 2x-large spacing.
  final double xxl;

  @override
  AppSpacing copyWith({
    double? none,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      none: none ?? this.none,
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppSpacing lerp(covariant ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      none: lerpDouble(none, other.none, t)!,
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
    );
  }
}
