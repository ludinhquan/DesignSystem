import 'package:flutter/widgets.dart';

import 'ds_colors.dart';

/// Microsoft Fluent Emoji 3D (MIT), bundled in packages/ds. Only for
/// category tiles, empty states, success moments and onboarding; never in
/// bars, buttons, inputs or next to an amount.
enum DsEmoji {
  hotBeverage('hot_beverage', DsField.red),
  steamingBowl('steaming_bowl', DsField.red),
  bubbleTea('bubble_tea', DsField.red),
  motorScooter('motor_scooter', DsField.blue),
  shoppingBags('shopping_bags', DsField.yellow),
  lightBulb('light_bulb', DsField.purple),
  receipt('receipt', DsField.purple),
  house('house', DsField.purple),
  pill('pill', DsField.green),
  moneyBag('money_bag', DsField.green),
  wrappedGift('wrapped_gift', DsField.yellow),

  /// Empty state ("Chưa có giao dịch"). 256px.
  emptyNest('empty_nest', null),

  /// Success or a goal reached. 256px.
  checkMarkButton('check_mark_button', null);

  const DsEmoji(this.file, this.field);

  final String file;

  /// The category tint it sits on (null for moments).
  final DsField? field;

  ImageProvider get image =>
      AssetImage('assets/emoji3d/$file.webp', package: 'ds');
}
