import 'package:ds_tokens/ds_tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Semantic type scale as a [ThemeExtension].
///
/// Styles carry size, weight, line height and letter spacing only; colour is
/// applied by the component from `context.colors`.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Creates a type scale.
  const AppTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
  });

  /// The default type scale generated from `tokens/semantic.json`.
  static const AppTypography standard = AppTypography(
    display: TypographyTokens.display,
    headline: TypographyTokens.headline,
    title: TypographyTokens.title,
    body: TypographyTokens.body,
    bodySmall: TypographyTokens.bodySmall,
    label: TypographyTokens.label,
    caption: TypographyTokens.caption,
  );

  /// Hero / marketing text.
  final TextStyle display;

  /// Screen titles.
  final TextStyle headline;

  /// Section and card titles.
  final TextStyle title;

  /// Default body text.
  final TextStyle body;

  /// Secondary body text.
  final TextStyle bodySmall;

  /// Buttons, tabs and other interactive labels.
  final TextStyle label;

  /// Captions and helper text.
  final TextStyle caption;

  @override
  AppTypography copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return AppTypography(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
