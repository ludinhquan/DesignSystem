import 'package:material_ui/material_ui.dart';

import '../tokens/primitives.dart';
import 'ds_brand.dart';
import 'ds_tokens.dart';

/// Builds [ThemeData] from a [DsBrand]: ColorScheme + TextTheme + [DsTokens].
abstract final class DsTheme {
  static ThemeData light([DsBrand brand = const DsBrand()]) =>
      _build(brand, Brightness.light);

  static ThemeData dark([DsBrand brand = const DsBrand()]) =>
      _build(brand, Brightness.dark);

  static ThemeData _build(DsBrand brand, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    var scheme = ColorScheme.fromSeed(
      seedColor: brand.primary,
      brightness: brightness,
    );
    // In light mode the brand color is used as-is, so it matches marketing.
    if (isLight) scheme = scheme.copyWith(primary: brand.primary);

    final tokens = isLight
        ? DsTokens.light(baseRadius: brand.radius)
        : DsTokens.dark(baseRadius: brand.radius);
    final textTheme = _textTheme(brand.fontFamily)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: brand.fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: tokens.border,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
    );
  }

  static TextTheme _textTheme(String? fontFamily) {
    TextStyle style(double size, FontWeight weight, [double height = 1.4]) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: height,
        );
    return TextTheme(
      displaySmall: style(DsFontSize.xxl, FontWeight.w700, 1.2),
      headlineSmall: style(DsFontSize.xl, FontWeight.w700, 1.25),
      titleLarge: style(DsFontSize.lg, FontWeight.w600, 1.3),
      titleMedium: style(DsFontSize.md, FontWeight.w600),
      bodyLarge: style(DsFontSize.md, FontWeight.w400),
      bodyMedium: style(DsFontSize.sm, FontWeight.w400),
      bodySmall: style(DsFontSize.xs, FontWeight.w400),
      labelLarge: style(DsFontSize.sm, FontWeight.w600, 1.2),
      labelMedium: style(DsFontSize.xs, FontWeight.w600, 1.2),
    );
  }
}
