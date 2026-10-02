import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/models.dart';
import '../data/wallet_controller.dart';
import 'wallet_style.dart';

enum MoneyFlow { transfer, topUp }

/// Opens the transfer or top-up sheet for [account].
Future<void> showMoneySheet(
  BuildContext context,
  MoneyFlow flow,
  Account account,
) => showDsSheet<void>(
  context: context,
  builder: (_) => _MoneySheet(flow: flow, account: account),
);

class _MoneySheet extends ConsumerStatefulWidget {
  const _MoneySheet({required this.flow, required this.account});

  final MoneyFlow flow;
  final Account account;

  @override
  ConsumerState<_MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends ConsumerState<_MoneySheet> {
  final _recipient = TextEditingController();
  int _amount = 0;
  bool _busy = false;
  String? _recipientError;
  Object? _error;

  bool get _transfer => widget.flow == MoneyFlow.transfer;

  @override
  void dispose() {
    _recipient.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_transfer && _recipient.text.trim().isEmpty) {
      DsHaptics.error(context);
      setState(() => _recipientError = context.l10n.transferRecipientRequired);
      return;
    }
    DsHaptics.confirm(context);
    setState(() {
      _busy = true;
      _error = null;
      _recipientError = null;
    });
    final wallet = ref.read(walletProvider.notifier);
    try {
      if (_transfer) {
        await wallet.transfer(
          accountId: widget.account.id,
          recipient: _recipient.text.trim(),
          amount: _amount,
        );
      } else {
        await wallet.topUp(accountId: widget.account.id, amount: _amount);
      }
      if (!mounted) return;
      DsHaptics.success(context);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ds = context.ds;
    final over = _transfer && _amount > widget.account.balance;
    final money = DsMoneyFormat.format(_amount);
    return DsSheet(
      title: _transfer ? l10n.actionTransfer : l10n.actionTopUp,
      footer: DsButton(
        key: const Key('sheet.confirm'),
        label: _busy
            ? l10n.transferSending
            : _transfer
            ? l10n.transferSend(money)
            : l10n.topUpConfirm(money),
        variant: DsButtonVariant.prominent,
        size: DsButtonSize.lg,
        block: true,
        loading: _busy,
        // Over the balance or zero: warn and disable; never block typing.
        onPressed: _amount == 0 || over ? null : _confirm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_transfer) ...[
            DsTextField(
              label: l10n.transferRecipient,
              controller: _recipient,
              placeholder: l10n.transferRecipientPlaceholder,
              error: _recipientError,
              textInputAction: TextInputAction.next,
              inputKey: const Key('sheet.recipient'),
            ),
            SizedBox(height: ds.spacing.s4),
          ],
          DsAmountField(
            value: _amount,
            onChanged: (v) => setState(() => _amount = v),
            label: l10n.amountLabel,
            available: _transfer ? widget.account.balance : null,
            sourceField: widget.account.color.field,
            sourceName: _transfer ? widget.account.name : l10n.topUpSource,
            autofocus: !_transfer,
            inputKey: const Key('sheet.amount'),
          ),
          if (_error != null) ...[
            SizedBox(height: ds.spacing.s3),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.errorMessage(_error!),
                style: ds.text.footnote.copyWith(color: ds.colors.negative),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A sheet for an action that is not built yet.
Future<void> showComingSoon(BuildContext context, String feature) {
  final l10n = context.l10n;
  return showDsSheet<void>(
    context: context,
    builder: (context) => DsSheet(
      title: feature,
      child: DsEmptyState(
        emoji: DsEmoji.wrappedGift,
        title: l10n.comingSoonTitle,
        message: l10n.comingSoonMessage(feature),
      ),
    ),
  );
}
