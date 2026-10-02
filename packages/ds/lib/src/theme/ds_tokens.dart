import 'package:material_ui/material_ui.dart';

import '../tokens/semantic.dart';

/// The one design-system [ThemeExtension]: everything that does not fit in
/// [ColorScheme] or [TextTheme].
///
/// Read it with `context.ds`.
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  const DsTokens({
    required this.spacing,
    required this.radius,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.textMuted,
    required this.border,
  });

  /// Light-mode tokens with radii derived from [baseRadius].
  factory DsTokens.light({required double baseRadius}) => DsTokens(
    spacing: DsSpacing.standard,
    radius: DsRadii.fromBase(baseRadius),
    success: DsLightColors.success,
    onSuccess: DsLightColors.onSuccess,
    warning: DsLightColors.warning,
    onWarning: DsLightColors.onWarning,
    textMuted: DsLightColors.textMuted,
    border: DsLightColors.border,
  );

  /// Dark-mode tokens with radii derived from [baseRadius].
  factory DsTokens.dark({required double baseRadius}) => DsTokens(
    spacing: DsSpacing.standard,
    radius: DsRadii.fromBase(baseRadius),
    success: DsDarkColors.success,
    onSuccess: DsDarkColors.onSuccess,
    warning: DsDarkColors.warning,
    onWarning: DsDarkColors.onWarning,
    textMuted: DsDarkColors.textMuted,
    border: DsDarkColors.border,
  );

  final DsSpacing spacing;
  final DsRadii radius;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  /// Secondary text: captions, hints, metadata.
  final Color textMuted;

  /// Hairline borders and dividers.
  final Color border;

  @override
  DsTokens copyWith({
    DsSpacing? spacing,
    DsRadii? radius,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? textMuted,
    Color? border,
  }) => DsTokens(
    spacing: spacing ?? this.spacing,
    radius: radius ?? this.radius,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
  );

  @override
  DsTokens lerp(DsTokens? other, double t) {
    if (other == null) return this;
    return DsTokens(
      spacing: spacing.lerp(other.spacing, t),
      radius: radius.lerp(other.radius, t),
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// `context.ds.spacing.md`, `context.ds.textMuted`, ...
extension DsContext on BuildContext {
  DsTokens get ds =>
      Theme.of(this).extension<DsTokens>() ??
      DsTokens.light(baseRadius: DsRadii.standard.md);
}
