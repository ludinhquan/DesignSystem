import 'package:flutter/widgets.dart';

/// Which voice a type role uses.
enum DsFontRole {
  /// Amounts and display headlines.
  display,

  /// All interface text.
  sans,

  /// Chips (quick-add, delta).
  rounded,
}

/// One type role as the tokens define it (sizes in logical pixels).
@immutable
class DsTypeSpec {
  const DsTypeSpec({
    required this.role,
    required this.size,
    required this.lineHeight,
    required this.weight,
    this.tracking = 0,
    this.opticalSize,
    this.tabular = false,
  });

  final DsFontRole role;
  final double size;
  final double lineHeight;

  /// 100–900; may fall between FontWeight steps on a variable font.
  final double weight;
  final double tracking;

  /// `opsz` axis value for variable display faces.
  final double? opticalSize;

  /// Tabular figures (amounts, chips).
  final bool tabular;
}

/// The type-role contract.
@immutable
class DsTypeScale {
  const DsTypeScale({
    required this.displayHero,
    required this.displayEntry,
    required this.titleScreen,
    required this.displayCard,
    required this.titleSection,
    required this.amountRow,
    required this.monogram,
    required this.headline,
    required this.body,
    required this.button,
    required this.rowTitle,
    required this.callout,
    required this.subhead,
    required this.buttonSm,
    required this.footnote,
    required this.label,
    required this.caption,
    required this.tileLabel,
    required this.tabLabel,
    required this.chip,
  });

  // Display voice.
  final DsTypeSpec displayHero;
  final DsTypeSpec displayEntry;
  final DsTypeSpec titleScreen;
  final DsTypeSpec displayCard;
  final DsTypeSpec titleSection;
  final DsTypeSpec amountRow;
  final DsTypeSpec monogram;

  // Interface voice.
  final DsTypeSpec headline;
  final DsTypeSpec body;
  final DsTypeSpec button;
  final DsTypeSpec rowTitle;
  final DsTypeSpec callout;
  final DsTypeSpec subhead;
  final DsTypeSpec buttonSm;
  final DsTypeSpec footnote;
  final DsTypeSpec label;
  final DsTypeSpec caption;
  final DsTypeSpec tileLabel;
  final DsTypeSpec tabLabel;

  // Rounded voice.
  final DsTypeSpec chip;
}

/// How a system renders one voice: family, package and variable axes.
@immutable
class DsFontFamily {
  const DsFontFamily({
    this.family,
    this.package,
    this.variable = false,
    this.width,
    this.tracking,
  });

  /// The platform face.
  static const platform = DsFontFamily();

  /// `null` = the platform's UI face.
  final String? family;
  final String? package;

  /// Variable font: weight and optical size are sent as axes.
  final bool variable;

  /// `wdth` axis per role (variable fonts only).
  final double? Function(DsTypeSpec spec)? width;

  /// Overrides the token tracking (e.g. Inter needs tighter than SF Pro).
  final double Function(DsTypeSpec spec)? tracking;
}

/// The faces of a system per voice, with an optional Android override for
/// the interface voice.
@immutable
class DsFonts {
  const DsFonts({
    required this.display,
    this.sans = DsFontFamily.platform,
    this.sansAndroid,
    this.rounded = DsFontFamily.platform,
  });

  final DsFontFamily display;
  final DsFontFamily sans;
  final DsFontFamily? sansAndroid;
  final DsFontFamily rounded;

  DsFontFamily of(DsFontRole role, TargetPlatform platform) => switch (role) {
    DsFontRole.display => display,
    DsFontRole.rounded => rounded,
    DsFontRole.sans =>
      platform == TargetPlatform.android ? (sansAndroid ?? sans) : sans,
  };

  /// Resolves [spec] into a [TextStyle] (no colour: components add it).
  TextStyle resolve(DsTypeSpec spec, TargetPlatform platform) {
    final face = of(spec.role, platform);
    return TextStyle(
      fontFamily: face.family,
      package: face.package,
      fontSize: spec.size,
      height: spec.lineHeight / spec.size,
      fontWeight: _weight(spec.weight),
      letterSpacing: face.tracking?.call(spec) ?? spec.tracking,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: spec.tabular ? const [FontFeature.tabularFigures()] : null,
      fontVariations: face.variable
          ? [
              FontVariation('wght', spec.weight),
              FontVariation('opsz', spec.opticalSize ?? spec.size),
              if (face.width?.call(spec) case final double w)
                FontVariation('wdth', w),
            ]
          : null,
    );
  }

  static FontWeight _weight(double w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];
}

/// Every role resolved to a [TextStyle] for one platform. Read it with
/// `context.ds.type`.
@immutable
class DsTypography {
  DsTypography(DsTypeScale s, DsFonts fonts, TargetPlatform platform)
    : displayHero = fonts.resolve(s.displayHero, platform),
      displayEntry = fonts.resolve(s.displayEntry, platform),
      titleScreen = fonts.resolve(s.titleScreen, platform),
      displayCard = fonts.resolve(s.displayCard, platform),
      titleSection = fonts.resolve(s.titleSection, platform),
      amountRow = fonts.resolve(s.amountRow, platform),
      monogram = fonts.resolve(s.monogram, platform),
      headline = fonts.resolve(s.headline, platform),
      body = fonts.resolve(s.body, platform),
      button = fonts.resolve(s.button, platform),
      rowTitle = fonts.resolve(s.rowTitle, platform),
      callout = fonts.resolve(s.callout, platform),
      subhead = fonts.resolve(s.subhead, platform),
      buttonSm = fonts.resolve(s.buttonSm, platform),
      footnote = fonts.resolve(s.footnote, platform),
      label = fonts.resolve(s.label, platform),
      caption = fonts.resolve(s.caption, platform),
      tileLabel = fonts.resolve(s.tileLabel, platform),
      tabLabel = fonts.resolve(s.tabLabel, platform),
      chip = fonts.resolve(s.chip, platform);

  final TextStyle displayHero;
  final TextStyle displayEntry;
  final TextStyle titleScreen;
  final TextStyle displayCard;
  final TextStyle titleSection;
  final TextStyle amountRow;
  final TextStyle monogram;
  final TextStyle headline;
  final TextStyle body;
  final TextStyle button;
  final TextStyle rowTitle;
  final TextStyle callout;
  final TextStyle subhead;
  final TextStyle buttonSm;
  final TextStyle footnote;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle tileLabel;
  final TextStyle tabLabel;
  final TextStyle chip;

  /// [style] with the display face's weight changed (variable fonts need the
  /// `wght` axis, not only [FontWeight]).
  static TextStyle withWeight(TextStyle style, double weight) => style.copyWith(
    fontWeight: DsFonts._weight(weight),
    fontVariations: style.fontVariations == null
        ? null
        : [
            for (final v in style.fontVariations!)
              v.axis == 'wght' ? FontVariation('wght', weight) : v,
          ],
  );
}
