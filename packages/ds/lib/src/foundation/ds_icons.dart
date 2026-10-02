import 'package:flutter/widgets.dart';

/// One concept in every weight a design system draws it in.
///
/// Size picks the weight: navigation and tabs use [regular], inline glyphs
/// (buttons, chips, chevrons) [bold], the selected tab [fill], action tiles
/// the two-layer duotone ([duotoneBack] at 20% under [duotoneFront]).
@immutable
class DsIcon {
  const DsIcon({
    required this.regular,
    IconData? bold,
    IconData? fill,
    IconData? duotoneBack,
    IconData? duotoneFront,
  }) : bold = bold ?? regular,
       fill = fill ?? regular,
       duotoneBack = duotoneBack ?? fill ?? regular,
       duotoneFront = duotoneFront ?? regular;

  final IconData regular;
  final IconData bold;
  final IconData fill;
  final IconData duotoneBack;
  final IconData duotoneFront;
}

/// The icon contract: every glyph components and the app use, by meaning.
/// A design system maps each to its own icon set.
@immutable
class DsIconSet {
  const DsIconSet({
    required this.home,
    required this.cards,
    required this.activity,
    required this.profile,
    required this.search,
    required this.bell,
    required this.eye,
    required this.eyeOff,
    required this.chevronRight,
    required this.back,
    required this.check,
    required this.close,
    required this.plus,
    required this.send,
    required this.topUp,
    required this.scan,
    required this.bill,
    required this.lock,
    required this.warning,
    required this.more,
    required this.contactless,
    required this.logout,
    required this.trendUp,
    required this.language,
    required this.coffee,
    required this.food,
    required this.transport,
    required this.shopping,
    required this.utilities,
    required this.house,
    required this.health,
    required this.income,
    required this.gift,
  });

  // Navigation.
  final DsIcon home;
  final DsIcon cards;
  final DsIcon activity;
  final DsIcon profile;

  // Chrome and controls.
  final DsIcon search;
  final DsIcon bell;
  final DsIcon eye;
  final DsIcon eyeOff;
  final DsIcon chevronRight;
  final DsIcon back;
  final DsIcon check;
  final DsIcon close;
  final DsIcon plus;
  final DsIcon more;
  final DsIcon warning;
  final DsIcon lock;
  final DsIcon logout;
  final DsIcon language;
  final DsIcon trendUp;

  // Actions.
  final DsIcon send;
  final DsIcon topUp;
  final DsIcon scan;
  final DsIcon bill;
  final DsIcon contactless;

  // Category fallbacks (20px and below, monochrome contexts).
  final DsIcon coffee;
  final DsIcon food;
  final DsIcon transport;
  final DsIcon shopping;
  final DsIcon utilities;
  final DsIcon house;
  final DsIcon health;
  final DsIcon income;
  final DsIcon gift;
}
