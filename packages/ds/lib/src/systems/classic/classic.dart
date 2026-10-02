import 'package:material_ui/material_ui.dart';

import '../../foundation/ds_icons.dart';
import '../../foundation/ds_motion.dart';
import '../../foundation/ds_system.dart';
import '../../foundation/ds_type.dart';
import 'classic_tokens.g.dart';

/// Classic: the original calm blue system, on the same contract as Pebble.
/// Platform faces, circular corners, no bounce, Material icons, flat
/// objects (no grain or specular; see its tokens.json).
const classic = DsSystem(
  tokens: classicTokens,
  fonts: DsFonts(display: DsFontFamily.platform),
  corners: DsCorners.circular,
  haptics: false,
  motion: DsMotion(
    snappy: DsSpring(Duration(milliseconds: 250)),
    smooth: DsSpring(Duration(milliseconds: 350)),
    object: DsSpring(Duration(milliseconds: 350)),
    roll: DsSpring(Duration(milliseconds: 400)),
    pressScaleButton: 0.98,
    pressScaleTile: 0.96,
    pressScaleCard: 0.98,
  ),
  icons: _material,
);

/// Material Icons: outlined for regular and bold, filled for fill; the
/// duotone pair is filled under outlined.
const _material = DsIconSet(
  home: DsIcon(
    regular: Icons.home_outlined,
    fill: Icons.home,
    duotoneBack: Icons.home,
    duotoneFront: Icons.home_outlined,
  ),
  cards: DsIcon(
    regular: Icons.credit_card_outlined,
    fill: Icons.credit_card,
    duotoneBack: Icons.credit_card,
    duotoneFront: Icons.credit_card_outlined,
  ),
  activity: DsIcon(
    regular: Icons.receipt_long_outlined,
    fill: Icons.receipt_long,
    duotoneBack: Icons.receipt_long,
    duotoneFront: Icons.receipt_long_outlined,
  ),
  profile: DsIcon(
    regular: Icons.person_outline,
    fill: Icons.person,
    duotoneBack: Icons.person,
    duotoneFront: Icons.person_outline,
  ),
  search: DsIcon(
    regular: Icons.search,
    fill: Icons.search,
    duotoneBack: Icons.search,
    duotoneFront: Icons.search,
  ),
  bell: DsIcon(
    regular: Icons.notifications_none,
    fill: Icons.notifications,
    duotoneBack: Icons.notifications,
    duotoneFront: Icons.notifications_none,
  ),
  eye: DsIcon(
    regular: Icons.visibility_outlined,
    fill: Icons.visibility,
    duotoneBack: Icons.visibility,
    duotoneFront: Icons.visibility_outlined,
  ),
  eyeOff: DsIcon(
    regular: Icons.visibility_off_outlined,
    fill: Icons.visibility_off,
    duotoneBack: Icons.visibility_off,
    duotoneFront: Icons.visibility_off_outlined,
  ),
  chevronRight: DsIcon(
    regular: Icons.chevron_right,
    fill: Icons.chevron_right,
    duotoneBack: Icons.chevron_right,
    duotoneFront: Icons.chevron_right,
  ),
  back: DsIcon(
    regular: Icons.arrow_back,
    fill: Icons.arrow_back,
    duotoneBack: Icons.arrow_back,
    duotoneFront: Icons.arrow_back,
  ),
  check: DsIcon(
    regular: Icons.check,
    fill: Icons.check,
    duotoneBack: Icons.check,
    duotoneFront: Icons.check,
  ),
  close: DsIcon(
    regular: Icons.close,
    fill: Icons.close,
    duotoneBack: Icons.close,
    duotoneFront: Icons.close,
  ),
  plus: DsIcon(
    regular: Icons.add,
    fill: Icons.add,
    duotoneBack: Icons.add,
    duotoneFront: Icons.add,
  ),
  send: DsIcon(
    regular: Icons.send_outlined,
    fill: Icons.send,
    duotoneBack: Icons.send,
    duotoneFront: Icons.send_outlined,
  ),
  topUp: DsIcon(
    regular: Icons.south,
    fill: Icons.south,
    duotoneBack: Icons.south,
    duotoneFront: Icons.south,
  ),
  scan: DsIcon(
    regular: Icons.qr_code_scanner,
    fill: Icons.qr_code_scanner,
    duotoneBack: Icons.qr_code_scanner,
    duotoneFront: Icons.qr_code_scanner,
  ),
  bill: DsIcon(
    regular: Icons.receipt_outlined,
    fill: Icons.receipt,
    duotoneBack: Icons.receipt,
    duotoneFront: Icons.receipt_outlined,
  ),
  lock: DsIcon(
    regular: Icons.lock_outline,
    fill: Icons.lock,
    duotoneBack: Icons.lock,
    duotoneFront: Icons.lock_outline,
  ),
  warning: DsIcon(
    regular: Icons.error_outline,
    fill: Icons.error,
    duotoneBack: Icons.error,
    duotoneFront: Icons.error_outline,
  ),
  more: DsIcon(
    regular: Icons.more_horiz,
    fill: Icons.more_horiz,
    duotoneBack: Icons.more_horiz,
    duotoneFront: Icons.more_horiz,
  ),
  contactless: DsIcon(
    regular: Icons.contactless_outlined,
    fill: Icons.contactless,
    duotoneBack: Icons.contactless,
    duotoneFront: Icons.contactless_outlined,
  ),
  logout: DsIcon(
    regular: Icons.logout,
    fill: Icons.logout,
    duotoneBack: Icons.logout,
    duotoneFront: Icons.logout,
  ),
  trendUp: DsIcon(
    regular: Icons.north_east,
    fill: Icons.north_east,
    duotoneBack: Icons.north_east,
    duotoneFront: Icons.north_east,
  ),
  language: DsIcon(
    regular: Icons.translate,
    fill: Icons.translate,
    duotoneBack: Icons.translate,
    duotoneFront: Icons.translate,
  ),
  coffee: DsIcon(
    regular: Icons.local_cafe_outlined,
    fill: Icons.local_cafe,
    duotoneBack: Icons.local_cafe,
    duotoneFront: Icons.local_cafe_outlined,
  ),
  food: DsIcon(
    regular: Icons.ramen_dining_outlined,
    fill: Icons.ramen_dining,
    duotoneBack: Icons.ramen_dining,
    duotoneFront: Icons.ramen_dining_outlined,
  ),
  transport: DsIcon(
    regular: Icons.two_wheeler_outlined,
    fill: Icons.two_wheeler,
    duotoneBack: Icons.two_wheeler,
    duotoneFront: Icons.two_wheeler_outlined,
  ),
  shopping: DsIcon(
    regular: Icons.shopping_bag_outlined,
    fill: Icons.shopping_bag,
    duotoneBack: Icons.shopping_bag,
    duotoneFront: Icons.shopping_bag_outlined,
  ),
  utilities: DsIcon(
    regular: Icons.bolt_outlined,
    fill: Icons.bolt,
    duotoneBack: Icons.bolt,
    duotoneFront: Icons.bolt_outlined,
  ),
  house: DsIcon(
    regular: Icons.house_outlined,
    fill: Icons.house,
    duotoneBack: Icons.house,
    duotoneFront: Icons.house_outlined,
  ),
  health: DsIcon(
    regular: Icons.medication_outlined,
    fill: Icons.medication,
    duotoneBack: Icons.medication,
    duotoneFront: Icons.medication_outlined,
  ),
  income: DsIcon(
    regular: Icons.payments_outlined,
    fill: Icons.payments,
    duotoneBack: Icons.payments,
    duotoneFront: Icons.payments_outlined,
  ),
  gift: DsIcon(
    regular: Icons.card_giftcard_outlined,
    fill: Icons.card_giftcard,
    duotoneBack: Icons.card_giftcard,
    duotoneFront: Icons.card_giftcard_outlined,
  ),
);
