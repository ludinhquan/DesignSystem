import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/wallet_controller.dart';
import '../wallet_routes.dart';
import 'wallet_style.dart';

/// In-store payment with one account: the card waits on canvas, and a
/// successful payment plays Tap to pay once. With no NFC terminal in this
/// demo, the confirm button stands in for the reader.
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({required this.accountId, super.key});

  final String accountId;

  static const demoMerchant = 'Highlands Coffee';
  static const demoAmount = 65000;

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  DsPayStatus _status = DsPayStatus.ready;
  bool _busy = false;
  Object? _error;

  Future<void> _pay() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(walletProvider.notifier)
          .pay(
            accountId: widget.accountId,
            merchant: PayScreen.demoMerchant,
            amount: PayScreen.demoAmount,
          );
      if (mounted) setState(() => _status = DsPayStatus.success);
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
    final account = ref.watch(walletProvider).value?.account(widget.accountId);
    void back() =>
        context.canPop() ? context.pop() : context.go(WalletPaths.cards);
    if (account == null) {
      return Scaffold(
        appBar: DsNavigationBar.inline(title: l10n.payTitle, onBack: back),
        body: const DsLoading(),
      );
    }
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    return Scaffold(
      appBar: DsNavigationBar.inline(title: l10n.payTitle, onBack: back),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: Column(
            children: [
              const Spacer(),
              DsTapToPay(
                // The live balance: after success it already includes the
                // payment, while the amount rolls in below.
                card: account.card,
                status: _status,
                amount: PayScreen.demoAmount,
                readyLabel: l10n.payReady,
                successLabel: l10n.paySuccess,
                merchant: PayScreen.demoMerchant,
              ),
              if (_error != null)
                Text(
                  l10n.errorMessage(_error!),
                  style: ds.text.footnote.copyWith(color: ds.colors.negative),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              if (_status == DsPayStatus.ready)
                DsButton(
                  key: const Key('pay.confirm'),
                  label: l10n.payTry(
                    DsMoneyFormat.format(PayScreen.demoAmount),
                  ),
                  icon: ds.icons.contactless,
                  variant: DsButtonVariant.prominent,
                  size: DsButtonSize.lg,
                  block: true,
                  loading: _busy,
                  onPressed: _pay,
                )
              else
                DsButton(
                  key: const Key('pay.back'),
                  label: l10n.payBack,
                  size: DsButtonSize.lg,
                  block: true,
                  onPressed: back,
                ),
              SizedBox(height: ds.spacing.s4),
            ],
          ),
        ),
      ),
    );
  }
}
