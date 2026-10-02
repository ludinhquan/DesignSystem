import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/clock.dart';
import '../../../l10n/l10n.dart';
import '../data/models.dart';
import '../data/wallet_controller.dart';
import 'wallet_style.dart';

/// A content row for one transaction: category emoji (or initials for a
/// person), "Category · time", the paying account's dot, the signed amount.
class TransactionRow extends ConsumerWidget {
  const TransactionRow(this.t, {required this.wallet, super.key});

  final Transaction t;
  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final fresh = ref.read(walletProvider.notifier).fresh.contains(t.id);
    return DsListItem.content(
      key: ValueKey(t.id),
      title: t.title,
      subtitle: l10n.rowSubtitle(
        t.category.label(l10n),
        rowTime(t.at, now, l10n),
      ),
      emoji: t.person ? null : t.category.emoji,
      monogram: t.person ? initials(t.title) : null,
      account: wallet.account(t.accountId)?.color.field,
      amount: t.amount,
      // A new inflow flashes once.
      flash: fresh && t.amount > 0,
    );
  }
}
