import 'package:ds/ds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/wallet_controller.dart';
import 'transaction_row.dart';

enum _Filter { all, spent, received }

/// Every transaction, filtered by direction.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ds = context.ds;
    final gutter = ds.spacing.gutterFor(MediaQuery.sizeOf(context).width);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (ref.watch(walletProvider)) {
          AsyncData(:final value) => ListView(
            padding: EdgeInsetsDirectional.only(bottom: ds.size.tabbarFade),
            children: [
              DsNavigationBar.large(title: l10n.activityTitle),
              SizedBox(height: ds.spacing.s4),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
                child: DsSegmentedControl<_Filter>(
                  semanticLabel: l10n.activityTitle,
                  value: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                  segments: [
                    DsSegment(_Filter.all, l10n.filterAll),
                    DsSegment(_Filter.spent, l10n.filterSpent),
                    DsSegment(_Filter.received, l10n.filterReceived),
                  ],
                ),
              ),
              SizedBox(height: ds.spacing.s4),
              DsListSection.plain(
                empty: DsEmptyState(
                  title: l10n.activityEmptyTitle,
                  message: l10n.activityEmptyMessage,
                ),
                children: [
                  for (final t in value.transactions)
                    if (switch (_filter) {
                      _Filter.all => true,
                      _Filter.spent => t.amount < 0,
                      _Filter.received => t.amount > 0,
                    })
                      TransactionRow(t, wallet: value),
                ],
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
