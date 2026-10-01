import 'dart:ui' show lerpDouble;

import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Semantic corner radii as a [ThemeExtension].
@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  /// Creates a radius scale.
  const AppRadius({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.pill,
  });

  /// The default radius scale generated from `tokens/semantic.json`.
  static const AppRadius standard = AppRadius(
    none: RadiusTokens.none,
    sm: RadiusTokens.sm,
    md: RadiusTokens.md,
    lg: RadiusTokens.lg,
    xl: RadiusTokens.xl,
    pill: RadiusTokens.pill,
  );

  /// Square corners.
  final double none;

  /// Small radius (chips, tags).
  final double sm;

  /// Medium radius (buttons, inputs).
  final double md;

  /// Large radius (cards).
  final double lg;

  /// Extra-large radius (sheets, dialogs).
  final double xl;

  /// Fully rounded ends.
  final double pill;

  @override
  AppRadius copyWith({
    double? none,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
  }) {
    return AppRadius(
      none: none ?? this.none,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      pill: pill ?? this.pill,
    );
  }

  @override
  AppRadius lerp(covariant ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      none: lerpDouble(none, other.none, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
    );
  }
}
