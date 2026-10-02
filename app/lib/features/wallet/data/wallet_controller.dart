import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/session_controller.dart';
import 'models.dart';
import 'wallet_repository.dart';

/// The signed-in person's accounts and activity. Per-user: it watches the
/// session, so logout clears it and a new login loads that user's wallet.
final walletProvider = AsyncNotifierProvider<WalletController, Wallet>(
  WalletController.new,
);

class WalletController extends AsyncNotifier<Wallet> {
  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  /// Ids of transactions added in this session, so the list can flash them.
  final fresh = <String>{};

  @override
  Future<Wallet> build() async {
    final session = ref.watch(sessionProvider).value;
    fresh.clear();
    if (session == null) return Wallet.empty;
    return _repo.load(session);
  }

  /// Throws `AppException`; the wallet is unchanged on failure.
  Future<Transaction> transfer({
    required String accountId,
    required String recipient,
    required int amount,
  }) => _apply(
    _repo.transfer(accountId: accountId, recipient: recipient, amount: amount),
  );

  Future<Transaction> topUp({required String accountId, required int amount}) =>
      _apply(_repo.topUp(accountId: accountId, amount: amount));

  Future<Transaction> pay({
    required String accountId,
    required String merchant,
    required int amount,
  }) => _apply(
    _repo.pay(accountId: accountId, merchant: merchant, amount: amount),
  );

  Future<Transaction> _apply(Future<Transaction> call) async {
    final t = await call;
    final w = state.value ?? Wallet.empty;
    fresh.add(t.id);
    state = AsyncData(
      Wallet(
        accounts: [
          for (final a in w.accounts)
            a.id == t.accountId ? a.withBalance(a.balance + t.amount) : a,
        ],
        transactions: [t, ...w.transactions],
      ),
    );
    return t;
  }
}

/// Balances shown as dots. Per-user, so it resets on logout.
final balanceHiddenProvider = NotifierProvider<BalanceHidden, bool>(
  BalanceHidden.new,
);

class BalanceHidden extends Notifier<bool> {
  @override
  bool build() {
    ref.watch(sessionProvider);
    return false;
  }

  void toggle() => state = !state;

  // A setter would read oddly at call sites (`notifier.set(true)`).
  // ignore: use_setters_to_change_properties
  void set(bool hidden) => state = hidden;
}
