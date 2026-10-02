import 'package:flutter/foundation.dart';

/// Spacing on a 4pt base, plus the screen gutter.
@immutable
class DsSpacing {
  const DsSpacing({
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s8,
    required this.s12,
    required this.gutter,
  });

  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s8;
  final double s12;

  /// Horizontal screen margin (16 below 390pt wide; components get it from
  /// [DsSpacing.gutterFor]).
  final double gutter;

  double gutterFor(double screenWidth) => screenWidth < 390 ? s4 : gutter;
}

/// Corner radii. Nested shapes are concentric: inner = outer − inset.
@immutable
class DsRadii {
  const DsRadii({
    required this.xs,
    required this.glyph,
    required this.tileSm,
    required this.tileLg,
    required this.tile,
    required this.card,
    required this.sheet,
    required this.sheetBottom,
    required this.full,
  });

  final double xs;

  /// Settings glyph tiles.
  final double glyph;

  /// 40–44px tiles.
  final double tileSm;

  /// 60px tiles.
  final double tileLg;

  /// Fields and panels.
  final double tile;

  /// Account cards, cards, grouped lists.
  final double card;
  final double sheet;
  final double sheetBottom;

  /// Pills: buttons, chips, toggles, tab bar.
  final double full;
}

/// Component dimensions.
@immutable
class DsSizes {
  const DsSizes({
    required this.hitTarget,
    required this.controlSm,
    required this.controlMd,
    required this.controlLg,
    required this.fieldHeight,
    required this.rowContent,
    required this.rowMin,
    required this.avatar,
    required this.avatarLg,
    required this.glyphTile,
    required this.iconInline,
    required this.iconNav,
    required this.iconTab,
    required this.tabPill,
    required this.tileRow,
    required this.tileSm,
    required this.tileLg,
    required this.emojiRow,
    required this.emojiTile,
    required this.emojiMoment,
    required this.emojiOnboarding,
    required this.cardAspect,
    required this.cardMax,
    required this.stackPeek,
    required this.tabbarFade,
  });

  /// Minimum tap target for anything tappable.
  final double hitTarget;
  final double controlSm;
  final double controlMd;
  final double controlLg;
  final double fieldHeight;
  final double rowContent;
  final double rowMin;
  final double avatar;
  final double avatarLg;
  final double glyphTile;
  final double iconInline;
  final double iconNav;
  final double iconTab;
  final double tabPill;
  final double tileRow;
  final double tileSm;
  final double tileLg;
  final double emojiRow;
  final double emojiTile;
  final double emojiMoment;
  final double emojiOnboarding;

  /// Width ÷ height of a card (ID-1: 1.586).
  final double cardAspect;
  final double cardMax;

  /// How much of each card behind shows in a stack.
  final double stackPeek;

  /// Bottom inset that clears the floating tab bar.
  final double tabbarFade;
}

/// Material strengths.
@immutable
class DsOpacities {
  const DsOpacities({
    required this.grain,
    required this.specular,
    required this.shift,
    required this.disabled,
  });

  /// Noise over object faces (0 = none).
  final double grain;

  /// Peak of the specular highlight (0 = none).
  final double specular;

  /// How far the monthly face shift moves an end stop.
  final double shift;
  final double disabled;
}
