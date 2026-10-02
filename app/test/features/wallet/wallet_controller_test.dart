import 'package:app/core/http.dart';
import 'package:app/features/auth/data/session_controller.dart';
import 'package:app/features/wallet/data/models.dart';
import 'package:app/features/wallet/data/wallet_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> signedIn(String email) async {
    final prefs = await setUpStorage();
    final c = ProviderContainer.test(
      overrides: testOverrides(prefs, FakeAnalytics()),
    );
    await c.read(sessionProvider.future);
    await c.read(sessionProvider.notifier).login(email: email, password: 'x');
    c.listen(walletProvider, (_, _) {});
    await c.read(walletProvider.future);
    return c;
  }

  test('loads the signed-in user\'s wallet', () async {
    final c = await signedIn('lan@example.com');
    final w = c.read(walletProvider).value!;
    expect(w.accounts, hasLength(3));
    expect(w.total, 104580000);
    expect(w.transactions.first.title, 'Highlands Coffee');
  });

  test('a transfer moves money and adds a fresh outflow first', () async {
    final c = await signedIn('lan@example.com');
    final t = await c
        .read(walletProvider.notifier)
        .transfer(accountId: 'daily', recipient: 'Minh', amount: 250000);
    final w = c.read(walletProvider).value!;
    expect(t.amount, -250000);
    expect(t.category, Category.transfer);
    expect(w.account('daily')!.balance, 12200000);
    expect(w.transactions.first.id, t.id);
    expect(c.read(walletProvider.notifier).fresh, contains(t.id));
  });

  test('over the balance throws and leaves the wallet unchanged', () async {
    final c = await signedIn('lan@example.com');
    await expectLater(
      c
          .read(walletProvider.notifier)
          .transfer(accountId: 'trip', recipient: 'Minh', amount: 99000000),
      throwsA(
        isA<RequestException>().having(
          (e) => e.code,
          'code',
          'insufficient_funds',
        ),
      ),
    );
    expect(c.read(walletProvider).value!.total, 104580000);
  });

  test('month delta counts only this month', () {
    final w = Wallet(
      accounts: const [],
      transactions: [
        Transaction(
          id: 'a',
          title: 'x',
          category: Category.coffee,
          accountId: 'd',
          amount: -100,
          at: DateTime(2026, 10, 1),
        ),
        Transaction(
          id: 'b',
          title: 'y',
          category: Category.income,
          accountId: 'd',
          amount: 500,
          at: DateTime(2026, 9, 30),
        ),
      ],
    );
    expect(w.monthDelta(DateTime(2026, 10, 2)), -100);
  });
}
