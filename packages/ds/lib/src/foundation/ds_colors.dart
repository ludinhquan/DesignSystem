import 'package:flutter/widgets.dart';

import 'ds_shadows.dart';

/// The six object colour slots that paint accounts, cards and action tiles.
///
/// Slots are named by hue so any design system can fill them with its own
/// version of that hue (Pebble: marigold, tomato, sky, mint, lilac, graphite).
/// [yellow] is the accent slot and the default for a first account.
enum DsField {
  yellow,
  red,
  blue,
  green,
  purple,
  graphite;

  /// The order new accounts take a field in: the first unused one wins.
  static const assignmentOrder = [yellow, green, blue, purple, red, graphite];
}

/// Everything needed to paint one object in a [DsField].
@immutable
class DsFieldColors {
  const DsFieldColors({
    required this.face,
    required this.end,
    required this.ink,
    required this.ink2,
    required this.shadow,
    this.tint,
  });

  /// Gradient start (top left) and end (bottom right, a few % darker).
  final Color face;
  final Color end;

  /// Primary text on the face; holds 4.5:1 on both stops.
  final Color ink;

  /// Secondary text on the face (institution, last digits, currency).
  final Color ink2;

  /// Pastel behind a category emoji. `null` when the system has none for
  /// this field (Pebble's graphite).
  final Color? tint;

  /// The object's resting shadow (tinted with its hue in light mode).
  final DsShadow shadow;

  DsFieldColors lerp(DsFieldColors other, double t) => DsFieldColors(
    face: Color.lerp(face, other.face, t)!,
    end: Color.lerp(end, other.end, t)!,
    ink: Color.lerp(ink, other.ink, t)!,
    ink2: Color.lerp(ink2, other.ink2, t)!,
    tint: Color.lerp(tint, other.tint, t),
    shadow: t < 0.5 ? shadow : other.shadow,
  );
}

/// The semantic colour contract. Every design system fills every field, in
/// both brightnesses; components read nothing else.
@immutable
class DsColors {
  const DsColors({
    required this.canvas,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.thumb,
    required this.knob,
    required this.fillSubtle,
    required this.fillStrong,
    required this.separator,
    required this.glass,
    required this.scrim,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentPressed,
    required this.onAccent,
    required this.accentText,
    required this.accentSoft,
    required this.focusRing,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.yellow,
    required this.red,
    required this.blue,
    required this.green,
    required this.purple,
    required this.graphite,
  });

  /// Screen ground. Never a gradient, grain or shadow.
  final Color canvas;

  /// Calm chrome: lists, fields, secondary buttons.
  final Color surface;

  /// Sheets.
  final Color surface2;

  /// Groups and fields inside a sheet.
  final Color surface3;

  /// Segmented-control thumb.
  final Color thumb;

  /// Toggle knob.
  final Color knob;

  final Color fillSubtle;
  final Color fillStrong;
  final Color separator;

  /// Floating chrome over content (tab bar), drawn over a blur.
  final Color glass;
  final Color scrim;

  /// Titles, body, amounts.
  final Color text1;

  /// Subtitles, labels, values.
  final Color text2;

  /// Chevrons, placeholders, disabled labels. Never body-size information.
  final Color text3;

  final Color accent;
  final Color accentPressed;
  final Color onAccent;

  /// Links and checks on neutral grounds.
  final Color accentText;
  final Color accentSoft;
  final Color focusRing;
  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;

  final DsFieldColors yellow;
  final DsFieldColors red;
  final DsFieldColors blue;
  final DsFieldColors green;
  final DsFieldColors purple;
  final DsFieldColors graphite;

  DsFieldColors field(DsField f) => switch (f) {
    DsField.yellow => yellow,
    DsField.red => red,
    DsField.blue => blue,
    DsField.green => green,
    DsField.purple => purple,
    DsField.graphite => graphite,
  };

  DsColors lerp(DsColors o, double t) {
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return DsColors(
      canvas: c(canvas, o.canvas),
      surface: c(surface, o.surface),
      surface2: c(surface2, o.surface2),
      surface3: c(surface3, o.surface3),
      thumb: c(thumb, o.thumb),
      knob: c(knob, o.knob),
      fillSubtle: c(fillSubtle, o.fillSubtle),
      fillStrong: c(fillStrong, o.fillStrong),
      separator: c(separator, o.separator),
      glass: c(glass, o.glass),
      scrim: c(scrim, o.scrim),
      text1: c(text1, o.text1),
      text2: c(text2, o.text2),
      text3: c(text3, o.text3),
      accent: c(accent, o.accent),
      accentPressed: c(accentPressed, o.accentPressed),
      onAccent: c(onAccent, o.onAccent),
      accentText: c(accentText, o.accentText),
      accentSoft: c(accentSoft, o.accentSoft),
      focusRing: c(focusRing, o.focusRing),
      positive: c(positive, o.positive),
      positiveSoft: c(positiveSoft, o.positiveSoft),
      negative: c(negative, o.negative),
      negativeSoft: c(negativeSoft, o.negativeSoft),
      yellow: yellow.lerp(o.yellow, t),
      red: red.lerp(o.red, t),
      blue: blue.lerp(o.blue, t),
      green: green.lerp(o.green, t),
      purple: purple.lerp(o.purple, t),
      graphite: graphite.lerp(o.graphite, t),
    );
  }
}
