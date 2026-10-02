import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/env.dart';
import '../../../core/clock.dart';
import '../../../core/http.dart';
import '../../auth/data/session.dart';
import 'models.dart';

/// Accounts, activity and money movements. Throws [AppException].
abstract interface class WalletRepository {
  Future<Wallet> load(Session session);

  /// Sends [amount] from an account to a person. Returns the new outflow.
  Future<Transaction> transfer({
    required String accountId,
    required String recipient,
    required int amount,
  });

  /// Adds [amount] to an account from the linked bank. Returns the inflow.
  Future<Transaction> topUp({required String accountId, required int amount});

  /// An in-store contactless payment. Returns the outflow.
  Future<Transaction> pay({
    required String accountId,
    required String merchant,
    required int amount,
  });
}

/// The fake keeps each user's wallet in memory, so data survives logout and
/// login of the same user within a run, like a backend would.
final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => Env.hasBackend
      ? HttpWalletRepository(ref.watch(dioProvider))
      : FakeWalletRepository(now: ref.watch(clockProvider)),
);

class HttpWalletRepository implements WalletRepository {
  HttpWalletRepository(this._dio);

  final Dio _dio;

  @override
  Future<Wallet> load(Session session) async {
    final (accounts, txns) = await (
      guardHttp(() => _dio.get<List<Object?>>('/accounts')),
      guardHttp(() => _dio.get<List<Object?>>('/transactions')),
    ).wait;
    return Wallet(
      accounts: [
        for (final a in accounts.data ?? const <Object?>[])
          Account.fromJson(a! as Map<String, Object?>),
      ],
      transactions: [
        for (final t in txns.data ?? const <Object?>[])
          Transaction.fromJson(t! as Map<String, Object?>),
      ],
    );
  }

  Future<Transaction> _post(String path, Map<String, Object?> body) async {
    final res = await guardHttp(
      () => _dio.post<Map<String, Object?>>(path, data: body),
    );
    return Transaction.fromJson(res.data ?? const {});
  }

  @override
  Future<Transaction> transfer({
    required String accountId,
    required String recipient,
    required int amount,
  }) => _post('/transfers', {
    'account_id': accountId,
    'recipient': recipient,
    'amount': amount,
  });

  @override
  Future<Transaction> topUp({required String accountId, required int amount}) =>
      _post('/top-ups', {'account_id': accountId, 'amount': amount});

  @override
  Future<Transaction> pay({
    required String accountId,
    required String merchant,
    required int amount,
  }) => _post('/payments', {
    'account_id': accountId,
    'merchant': merchant,
    'amount': amount,
  });
}

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository({
    required this._now,
    this.delay = const Duration(milliseconds: 400),
  });

  final DateTime Function() _now;
  final Duration delay;
  final _wallets = <String, Wallet>{};
  String? _user;
  var _seq = 0;

  Wallet get _wallet => _wallets[_user]!;
  set _wallet(Wallet w) => _wallets[_user!] = w;

  @override
  Future<Wallet> load(Session session) async {
    await Future<void>.delayed(delay);
    _user = session.userId;
    return _wallets.putIfAbsent(session.userId, () => _seed(_now()));
  }

  Future<Transaction> _move({
    required String accountId,
    required String title,
    required Category category,
    required int amount,
    bool person = false,
  }) async {
    await Future<void>.delayed(delay);
    final account = _wallet.account(accountId);
    if (account == null) throw const RequestException(404, 'no_account');
    if (amount < 0 && account.balance + amount < 0) {
      throw const RequestException(422, 'insufficient_funds');
    }
    final t = Transaction(
      id: 'new-${_seq++}',
      title: title,
      category: category,
      accountId: accountId,
      amount: amount,
      at: _now(),
      person: person,
    );
    _wallet = Wallet(
      accounts: [
        for (final a in _wallet.accounts)
          a.id == accountId ? a.withBalance(a.balance + amount) : a,
      ],
      transactions: [t, ..._wallet.transactions],
    );
    return t;
  }

  @override
  Future<Transaction> transfer({
    required String accountId,
    required String recipient,
    required int amount,
  }) => _move(
    accountId: accountId,
    title: recipient,
    category: Category.transfer,
    amount: -amount,
    person: true,
  );

  @override
  Future<Transaction> topUp({required String accountId, required int amount}) =>
      _move(
        accountId: accountId,
        title: 'Techcombank',
        category: Category.topUp,
        amount: amount,
      );

  @override
  Future<Transaction> pay({
    required String accountId,
    required String merchant,
    required int amount,
  }) => _move(
    accountId: accountId,
    title: merchant,
    category: Category.coffee,
    amount: -amount,
  );

  static Wallet _seed(DateTime now) {
    DateTime at(int daysAgo, int h, int m) =>
        DateTime(now.year, now.month, now.day - daysAgo, h, m);
    Transaction t(
      String id,
      String title,
      Category c,
      int amount,
      DateTime when, {
      String account = 'daily',
      bool person = false,
    }) => Transaction(
      id: id,
      title: title,
      category: c,
      accountId: account,
      amount: amount,
      at: when,
      person: person,
    );
    return Wallet(
      accounts: const [
        Account(
          id: 'daily',
          name: 'Chi tiêu hằng ngày',
          institution: 'Techcombank',
          last4: '4821',
          color: AccountColor.yellow,
          balance: 12450000,
        ),
        Account(
          id: 'home',
          name: 'Tiết kiệm mua nhà',
          institution: 'Vietcombank',
          last4: '0937',
          color: AccountColor.green,
          balance: 86000000,
        ),
        Account(
          id: 'trip',
          name: 'Du lịch Đà Nẵng',
          institution: 'TPBank',
          last4: '2210',
          color: AccountColor.blue,
          balance: 6130000,
        ),
      ],
      transactions: [
        t('t1', 'Highlands Coffee', Category.coffee, -65000, at(0, 8, 42)),
        t('t2', 'Grab', Category.transport, -42000, at(0, 7, 55)),
        t(
          't3',
          'Hoà Chu',
          Category.transfer,
          -250000,
          at(1, 19, 10),
          person: true,
        ),
        t('t4', 'Phở Thìn', Category.food, -55000, at(1, 12, 5)),
        t('t5', 'Shopee', Category.shopping, -349000, at(3, 21, 30)),
        t('t6', 'EVN', Category.utilities, -620000, at(5, 9, 0)),
        t(
          't7',
          'Pharmacity',
          Category.health,
          -120000,
          at(6, 18, 20),
          account: 'trip',
        ),
        t('t8', 'Lương tháng trước', Category.income, 18500000, at(8, 9, 0)),
      ],
    );
  }
}
