import 'package:material_ui/material_ui.dart';

import '../foundation/ds_system.dart';
import 'ds_tokens.dart';

/// Builds material_ui [ThemeData] from a [DsSystem]: the semantic colours
/// mapped onto [ColorScheme], the interface roles onto [TextTheme], and the
/// full contract attached as [DsTokens].
///
/// Material widgets used directly (text selection, scroll glow, dialogs)
/// then match the system; Ds* components read [DsTokens] only.
abstract final class DsTheme {
  static ThemeData light(DsSystem system, {TargetPlatform? platform}) =>
      build(DsTokens(system, Brightness.light, platform: platform));

  static ThemeData dark(DsSystem system, {TargetPlatform? platform}) =>
      build(DsTokens(system, Brightness.dark, platform: platform));

  static ThemeData build(DsTokens ds) {
    final c = ds.colors;
    final t = ds.text;
    final scheme = ColorScheme(
      brightness: ds.brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.text1,
      secondary: c.accentText,
      onSecondary: c.canvas,
      error: c.negative,
      onError: c.canvas,
      errorContainer: c.negativeSoft,
      onErrorContainer: c.negative,
      surface: c.canvas,
      onSurface: c.text1,
      onSurfaceVariant: c.text2,
      surfaceContainerLowest: c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface2,
      surfaceContainerHigh: c.surface3,
      surfaceContainerHighest: c.surface3,
      outline: c.text3,
      outlineVariant: c.separator,
      inverseSurface: c.text1,
      onInverseSurface: c.canvas,
      scrim: c.scrim,
      shadow: const Color(0xFF000000),
    );
    TextStyle on(TextStyle s, Color color) => s.copyWith(color: color);
    final textTheme = TextTheme(
      displayLarge: on(t.displayEntry, c.text1),
      displayMedium: on(t.displayHero, c.text1),
      displaySmall: on(t.titleScreen, c.text1),
      headlineMedium: on(t.displayCard, c.text1),
      headlineSmall: on(t.titleSection, c.text1),
      titleLarge: on(t.headline, c.text1),
      titleMedium: on(t.rowTitle, c.text1),
      titleSmall: on(t.label, c.text2),
      bodyLarge: on(t.body, c.text1),
      bodyMedium: on(t.callout, c.text1),
      bodySmall: on(t.footnote, c.text2),
      labelLarge: on(t.button, c.text1),
      labelMedium: on(t.label, c.text2),
      labelSmall: on(t.caption, c.text2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: ds.brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.canvas,
      dividerColor: c.separator,
      // Pebble has no ink ripples: pressed things scale or fill instead.
      splashFactory: NoSplash.splashFactory,
      highlightColor: const Color(0x00000000),
      iconTheme: IconThemeData(color: c.text1, size: ds.size.iconNav),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accentText,
        selectionColor: c.accentSoft,
        selectionHandleColor: c.accentText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        foregroundColor: c.text1,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: on(t.headline, c.text1),
      ),
      extensions: [ds],
    );
  }
}
