import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../foundation/ds_icons.dart';
import '../../foundation/ds_motion.dart';
import '../../foundation/ds_system.dart';
import '../../foundation/ds_type.dart';
import 'pebble_tokens.g.dart';

/// Pebble: tactile objects in warm daylight. Values come from
/// `systems/pebble/tokens.json`; this file holds what tokens cannot say.
final pebble = DsSystem(
  tokens: pebbleTokens,
  fonts: const DsFonts(
    display: DsFontFamily(
      family: 'BricolageGrotesque',
      package: 'ds',
      variable: true,
      width: _bricolageWidth,
    ),
    // SF Pro on iOS (the platform face); Inter on Android with tighter
    // tracking, since SF Pro's values are too loose for it.
    sansAndroid: DsFontFamily(
      family: 'Inter',
      package: 'ds',
      variable: true,
      tracking: _interTracking,
    ),
  ),
  motion: const DsMotion(
    snappy: DsSpring(Duration(milliseconds: 350), bounce: 0.15),
    smooth: DsSpring(Duration(milliseconds: 450)),
    object: DsSpring(Duration(milliseconds: 500), bounce: 0.2),
    roll: DsSpring(Duration(milliseconds: 600), bounce: 0.15),
  ),
  icons: _phosphor,
);

/// Bricolage runs narrow (wdth 88–92): wider for headline sizes.
double? _bricolageWidth(DsTypeSpec s) => switch (s.size) {
  >= 32 => 90,
  >= 24 => 88,
  _ => 92,
};

double _interTracking(DsTypeSpec s) => switch (s.size) {
  >= 32 => -0.7,
  >= 22 => -0.35,
  >= 20 => -0.3,
  >= 17 => -0.2,
  >= 16 => -0.15,
  >= 15 => -0.1,
  >= 13 => 0,
  _ => 0.1,
};

DsIcon _p(
  IconData regular,
  IconData bold,
  IconData fill,
  PhosphorDuotoneIconData duo,
) => DsIcon(
  regular: regular,
  bold: bold,
  fill: fill,
  duotoneBack: duo.primary,
  duotoneFront: duo.secondary,
);

/// Phosphor (MIT): Regular for chrome, Bold inline, Fill in the selected
/// tab, Duotone in action tiles.
final _phosphor = DsIconSet(
  home: _p(
    PhosphorIconsRegular.house,
    PhosphorIconsBold.house,
    PhosphorIconsFill.house,
    PhosphorIconsDuotone.house,
  ),
  cards: _p(
    PhosphorIconsRegular.creditCard,
    PhosphorIconsBold.creditCard,
    PhosphorIconsFill.creditCard,
    PhosphorIconsDuotone.creditCard,
  ),
  activity: _p(
    PhosphorIconsRegular.listBullets,
    PhosphorIconsBold.listBullets,
    PhosphorIconsFill.listBullets,
    PhosphorIconsDuotone.listBullets,
  ),
  profile: _p(
    PhosphorIconsRegular.user,
    PhosphorIconsBold.user,
    PhosphorIconsFill.user,
    PhosphorIconsDuotone.user,
  ),
  search: _p(
    PhosphorIconsRegular.magnifyingGlass,
    PhosphorIconsBold.magnifyingGlass,
    PhosphorIconsFill.magnifyingGlass,
    PhosphorIconsDuotone.magnifyingGlass,
  ),
  bell: _p(
    PhosphorIconsRegular.bell,
    PhosphorIconsBold.bell,
    PhosphorIconsFill.bell,
    PhosphorIconsDuotone.bell,
  ),
  eye: _p(
    PhosphorIconsRegular.eye,
    PhosphorIconsBold.eye,
    PhosphorIconsFill.eye,
    PhosphorIconsDuotone.eye,
  ),
  eyeOff: _p(
    PhosphorIconsRegular.eyeSlash,
    PhosphorIconsBold.eyeSlash,
    PhosphorIconsFill.eyeSlash,
    PhosphorIconsDuotone.eyeSlash,
  ),
  chevronRight: _p(
    PhosphorIconsRegular.caretRight,
    PhosphorIconsBold.caretRight,
    PhosphorIconsFill.caretRight,
    PhosphorIconsDuotone.caretRight,
  ),
  back: _p(
    PhosphorIconsRegular.caretLeft,
    PhosphorIconsBold.caretLeft,
    PhosphorIconsFill.caretLeft,
    PhosphorIconsDuotone.caretLeft,
  ),
  check: _p(
    PhosphorIconsRegular.check,
    PhosphorIconsBold.check,
    PhosphorIconsFill.check,
    PhosphorIconsDuotone.check,
  ),
  close: _p(
    PhosphorIconsRegular.x,
    PhosphorIconsBold.x,
    PhosphorIconsFill.x,
    PhosphorIconsDuotone.x,
  ),
  plus: _p(
    PhosphorIconsRegular.plus,
    PhosphorIconsBold.plus,
    PhosphorIconsFill.plus,
    PhosphorIconsDuotone.plus,
  ),
  send: _p(
    PhosphorIconsRegular.paperPlaneTilt,
    PhosphorIconsBold.paperPlaneTilt,
    PhosphorIconsFill.paperPlaneTilt,
    PhosphorIconsDuotone.paperPlaneTilt,
  ),
  topUp: _p(
    PhosphorIconsRegular.arrowDown,
    PhosphorIconsBold.arrowDown,
    PhosphorIconsFill.arrowDown,
    PhosphorIconsDuotone.arrowDown,
  ),
  scan: _p(
    PhosphorIconsRegular.qrCode,
    PhosphorIconsBold.qrCode,
    PhosphorIconsFill.qrCode,
    PhosphorIconsDuotone.qrCode,
  ),
  bill: _p(
    PhosphorIconsRegular.receipt,
    PhosphorIconsBold.receipt,
    PhosphorIconsFill.receipt,
    PhosphorIconsDuotone.receipt,
  ),
  lock: _p(
    PhosphorIconsRegular.lock,
    PhosphorIconsBold.lock,
    PhosphorIconsFill.lock,
    PhosphorIconsDuotone.lock,
  ),
  warning: _p(
    PhosphorIconsRegular.warningCircle,
    PhosphorIconsBold.warningCircle,
    PhosphorIconsFill.warningCircle,
    PhosphorIconsDuotone.warningCircle,
  ),
  more: _p(
    PhosphorIconsRegular.dotsThree,
    PhosphorIconsBold.dotsThree,
    PhosphorIconsFill.dotsThree,
    PhosphorIconsDuotone.dotsThree,
  ),
  contactless: _p(
    PhosphorIconsRegular.contactlessPayment,
    PhosphorIconsBold.contactlessPayment,
    PhosphorIconsFill.contactlessPayment,
    PhosphorIconsDuotone.contactlessPayment,
  ),
  logout: _p(
    PhosphorIconsRegular.signOut,
    PhosphorIconsBold.signOut,
    PhosphorIconsFill.signOut,
    PhosphorIconsDuotone.signOut,
  ),
  trendUp: _p(
    PhosphorIconsRegular.arrowUpRight,
    PhosphorIconsBold.arrowUpRight,
    PhosphorIconsFill.arrowUpRight,
    PhosphorIconsDuotone.arrowUpRight,
  ),
  language: _p(
    PhosphorIconsRegular.translate,
    PhosphorIconsBold.translate,
    PhosphorIconsFill.translate,
    PhosphorIconsDuotone.translate,
  ),
  coffee: _p(
    PhosphorIconsRegular.coffee,
    PhosphorIconsBold.coffee,
    PhosphorIconsFill.coffee,
    PhosphorIconsDuotone.coffee,
  ),
  food: _p(
    PhosphorIconsRegular.bowlFood,
    PhosphorIconsBold.bowlFood,
    PhosphorIconsFill.bowlFood,
    PhosphorIconsDuotone.bowlFood,
  ),
  transport: _p(
    PhosphorIconsRegular.scooter,
    PhosphorIconsBold.scooter,
    PhosphorIconsFill.scooter,
    PhosphorIconsDuotone.scooter,
  ),
  shopping: _p(
    PhosphorIconsRegular.shoppingBag,
    PhosphorIconsBold.shoppingBag,
    PhosphorIconsFill.shoppingBag,
    PhosphorIconsDuotone.shoppingBag,
  ),
  utilities: _p(
    PhosphorIconsRegular.lightning,
    PhosphorIconsBold.lightning,
    PhosphorIconsFill.lightning,
    PhosphorIconsDuotone.lightning,
  ),
  house: _p(
    PhosphorIconsRegular.house,
    PhosphorIconsBold.house,
    PhosphorIconsFill.house,
    PhosphorIconsDuotone.house,
  ),
  health: _p(
    PhosphorIconsRegular.pill,
    PhosphorIconsBold.pill,
    PhosphorIconsFill.pill,
    PhosphorIconsDuotone.pill,
  ),
  income: _p(
    PhosphorIconsRegular.handCoins,
    PhosphorIconsBold.handCoins,
    PhosphorIconsFill.handCoins,
    PhosphorIconsDuotone.handCoins,
  ),
  gift: _p(
    PhosphorIconsRegular.gift,
    PhosphorIconsBold.gift,
    PhosphorIconsFill.gift,
    PhosphorIconsDuotone.gift,
  ),
);
