import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/clock.dart';
import '../../../l10n/l10n.dart';
import '../../auth/data/session_controller.dart';
import '../data/models.dart';
import '../data/wallet_controller.dart';
import '../wallet_routes.dart';
import 'money_sheets.dart';
import 'transaction_row.dart';
import 'wallet_style.dart';

/// Home, top to bottom: header (no large title: the balance is the
/// headline), eyebrow with the eye toggle and delta chip, the hero total,
/// the card stack, four quick actions, recent activity.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const Scaffold(body: DsLoading());
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (ref.watch(walletProvider)) {
          AsyncData(:final value) => _Home(wallet: value, name: session.name),
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

class _Home extends ConsumerWidget {
  const _Home({required this.wallet, required this.name});

  final Wallet wallet;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ds = context.ds;
    final c = ds.colors;
    final now = ref.watch(clockProvider)();
    final hidden = ref.watch(balanceHiddenProvider);
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    final delta = wallet.monthDelta(now);
    final greeting = now.hour < 12
        ? l10n.greetingMorning
        : now.hour < 18
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;
    final first = wallet.accounts.isEmpty ? null : wallet.accounts.first;

    void money(MoneyFlow flow) {
      if (first != null) showMoneySheet(context, flow, first);
    }

    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: ds.size.tabbarFade),
      children: [
        DsNavigationBar.home(
          initials: initials(name),
          greeting: greeting,
          name: name,
          actions: [
            DsIconButton(
              icon: ds.icons.search,
              label: l10n.search,
              onPressed: () => context.go(WalletPaths.activity),
            ),
            DsIconButton(
              icon: ds.icons.bell,
              label: l10n.notifications,
              onPressed: () => showDsSheet<void>(
                context: context,
                builder: (_) => DsSheet(
                  title: l10n.notifications,
                  child: DsEmptyState(
                    emoji: DsEmoji.checkMarkButton,
                    title: l10n.notificationsEmptyTitle,
                    message: l10n.notificationsEmptyMessage,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ds.spacing.s5),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: Row(
            children: [
              Text(
                l10n.homeTotalBalance,
                style: ds.text.label.copyWith(color: c.text2),
              ),
              DsIconButton(
                key: const Key('home.eye'),
                icon: hidden ? ds.icons.eye : ds.icons.eyeOff,
                label: hidden ? l10n.homeShowBalance : l10n.homeHideBalance,
                variant: DsIconButtonVariant.plain,
                onPressed: ref.read(balanceHiddenProvider.notifier).toggle,
              ),
              if (delta != 0)
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: DsChip(
                      label: l10n.homeDelta(
                        DsMoneyFormat.format(delta, sign: true),
                      ),
                      icon: delta > 0 ? ds.icons.trendUp : null,
                      // Spending is never red: a fall is a neutral chip.
                      tone: delta > 0
                          ? DsChipTone.positive
                          : DsChipTone.neutral,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: ds.spacing.s1),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: DsMoney(
              wallet.total,
              size: DsMoneySize.hero,
              hidden: hidden,
              roll: true,
            ),
          ),
        ),
        SizedBox(height: ds.spacing.s6),
        if (wallet.accounts.isNotEmpty)
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
            child: Center(
              child: DsCardStack(
                cards: [for (final a in wallet.accounts) a.card],
                hidden: hidden,
                onOpen: (id) => context.push(WalletPaths.pay(id)),
              ),
            ),
          ),
        SizedBox(height: ds.spacing.s5),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DsIconTile.glyph(
                  field: DsField.red,
                  icon: ds.icons.send,
                  label: l10n.actionTransfer,
                  onTap: () => money(MoneyFlow.transfer),
                ),
              ),
              Expanded(
                child: DsIconTile.glyph(
                  field: DsField.green,
                  icon: ds.icons.topUp,
                  label: l10n.actionTopUp,
                  onTap: () => money(MoneyFlow.topUp),
                ),
              ),
              Expanded(
                child: DsIconTile.glyph(
                  field: DsField.blue,
                  icon: ds.icons.scan,
                  label: l10n.actionScan,
                  onTap: () => showComingSoon(context, l10n.actionScan),
                ),
              ),
              Expanded(
                child: DsIconTile.glyph(
                  field: DsField.purple,
                  icon: ds.icons.bill,
                  label: l10n.actionBills,
                  onTap: () => showComingSoon(context, l10n.actionBills),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ds.spacing.s8),
        DsListSection.plain(
          header: l10n.activityTitle,
          actionLabel: l10n.seeAll,
          onAction: () => context.go(WalletPaths.activity),
          empty: DsEmptyState(
            title: l10n.activityEmptyTitle,
            message: l10n.activityEmptyMessage,
          ),
          children: [
            for (final t in wallet.transactions.take(5))
              TransactionRow(t, wallet: wallet),
          ],
        ),
      ],
    );
  }
}
