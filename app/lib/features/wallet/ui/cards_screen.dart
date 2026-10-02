import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/wallet_controller.dart';
import '../wallet_routes.dart';
import 'wallet_style.dart';

/// Every account as a full card. Tap one to pay with it.
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ds = context.ds;
    final hidden = ref.watch(balanceHiddenProvider);
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (ref.watch(walletProvider)) {
          AsyncData(:final value) => ListView(
            padding: EdgeInsetsDirectional.only(bottom: ds.size.tabbarFade),
            children: [
              DsNavigationBar.large(title: l10n.cardsTitle),
              SizedBox(height: ds.spacing.s5),
              for (final a in value.accounts)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    gutter,
                    0,
                    gutter,
                    ds.spacing.s5,
                  ),
                  child: Center(
                    child: DsAccountCard(
                      data: a.card,
                      hidden: hidden,
                      roll: true,
                      onTap: () => context.push(WalletPaths.pay(a.id)),
                    ),
                  ),
                ),
            ],
          ),
          AsyncError(:final error) => DsErrorView(
            message: l10n.errorMessage(error),
            onRetry: () => ref.invalidate(walletProvider),
          ),
          _ => const DsLoading(),
        },
      ),
    );
  }
}
