import 'package:ds/ds.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/models.dart';

/// Where wallet data meets the design system: colours, emoji and names.

extension AccountColorDs on AccountColor {
  DsField get field => switch (this) {
    AccountColor.yellow => DsField.yellow,
    AccountColor.red => DsField.red,
    AccountColor.blue => DsField.blue,
    AccountColor.green => DsField.green,
    AccountColor.purple => DsField.purple,
    AccountColor.graphite => DsField.graphite,
  };
}

extension AccountDs on Account {
  DsCardData get card => DsCardData(
    id: id,
    field: color.field,
    name: name,
    balance: balance,
    institution: institution,
    last4: last4,
  );
}

extension CategoryDs on Category {
  /// One emoji per category (its tint comes with it).
  DsEmoji get emoji => switch (this) {
    Category.coffee => DsEmoji.hotBeverage,
    Category.food => DsEmoji.steamingBowl,
    Category.transport => DsEmoji.motorScooter,
    Category.shopping => DsEmoji.shoppingBags,
    Category.bills => DsEmoji.receipt,
    Category.utilities => DsEmoji.lightBulb,
    Category.health => DsEmoji.pill,
    Category.income || Category.topUp => DsEmoji.moneyBag,
    Category.gift => DsEmoji.wrappedGift,
    Category.transfer => DsEmoji.moneyBag,
  };

  String label(AppLocalizations l10n) => switch (this) {
    Category.coffee => l10n.catCoffee,
    Category.food => l10n.catFood,
    Category.transport => l10n.catTransport,
    Category.shopping => l10n.catShopping,
    Category.bills => l10n.catBills,
    Category.utilities => l10n.catUtilities,
    Category.health => l10n.catHealth,
    Category.income => l10n.catIncome,
    Category.gift => l10n.catGift,
    Category.transfer => l10n.catTransfer,
    Category.topUp => l10n.catTopUp,
  };
}

/// "08:42" today, "Hôm qua" yesterday, "30/09" before.
String rowTime(DateTime at, DateTime now, AppLocalizations l10n) {
  String two(int v) => v.toString().padLeft(2, '0');
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '${two(at.hour)}:${two(at.minute)}';
  if (diff == 1) return l10n.yesterday;
  return '${two(at.day)}/${two(at.month)}';
}

/// Initials of a person's name ("Hoà Chu" → "HC").
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
}
