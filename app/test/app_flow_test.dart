import 'package:app/core/storage.dart';
import 'package:app/features/auth/auth_routes.dart';
import 'package:app/features/auth/data/session_controller.dart';
import 'package:app/features/wallet/data/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/harness.dart';

void main() {
  String location(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .routeInformationProvider
          .value
          .uri
          .toString();

  testWidgets(
    'login -> home -> transfer -> hide balance -> VI -> logout clears '
    'everything -> another user',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final analytics = FakeAnalytics();
      final container = await pumpApp(tester, analytics: analytics);

      // Log in: the router leaves /login for Home.
      await logIn(tester);
      expect(location(tester), '/');
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Lan'), findsOneWidget);
      expect(find.bySemanticsLabel('104.580.000 dong'), findsOneWidget);

      // Transfer 250.000 ₫ from the first account.
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      expect(find.text('Send 0 ₫'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('sheet.recipient')),
        'Minh Anh',
      );
      await tester.enterText(find.byKey(const Key('sheet.amount')), '250000');
      await tester.pump();
      expect(find.text('Send 250.000 ₫'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sheet.confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet.confirm')), findsNothing);
      expect(find.bySemanticsLabel('104.330.000 dong'), findsOneWidget);
      expect(find.text('Minh Anh'), findsOneWidget);

      // Hide the balance.
      await tester.tap(find.byKey(const Key('home.eye')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Balance hidden'), findsWidgets);

      // Switch to Vietnamese from Profile; the choice is saved.
      await openTab(tester, 'Profile');
      expect(location(tester), '/profile');
      await tester.tap(find.byKey(const Key('profile.language')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếng Việt').last);
      await tester.pumpAndSettle();
      expect(find.text('Cá nhân'), findsWidgets);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app.locale'), 'vi');

      // Log out: back to login, tokens and every per-user state gone.
      await tester.tap(find.byKey(const Key('profile.logout')));
      await tester.pumpAndSettle();
      expect(location(tester), AuthPaths.login);
      expect(find.text('Đăng nhập vào Pebble'), findsOneWidget);
      expect(container.read(sessionProvider).value, isNull);
      expect(await container.read(tokenStoreProvider).read(), isNull);
      expect(container.read(balanceHiddenProvider), isFalse);
      expect((await container.read(walletProvider.future)).accounts, isEmpty);
      expect(analytics.calls, containsAllInOrder(['track:logout', 'reset']));

      // Another user starts clean, in the saved language.
      await logIn(tester, email: 'minh@example.com');
      expect(find.text('Chào buổi sáng'), findsOneWidget);
      expect(find.text('Minh'), findsOneWidget);
      expect(find.bySemanticsLabel('104.580.000 đồng'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('a card pays with Tap to pay and the balance follows', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    await logIn(tester);

    await openTab(tester, 'Cards');
    expect(find.text('My cards'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('^Techcombank, Chi tiêu')));
    await tester.pumpAndSettle();
    expect(find.text('Pay'), findsOneWidget);
    expect(
      find.text('Hold the back of your phone near the reader'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('pay.confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Paid'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pay.back')));
    await tester.pumpAndSettle();
    expect(location(tester), '/cards');
    expect(find.bySemanticsLabel(RegExp('12.385.000 dong')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Activity filters spending and income', (tester) async {
    await pumpApp(tester);
    await logIn(tester);
    await openTab(tester, 'Activity');
    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('Lương tháng trước'), findsOneWidget);

    // The segmented control keeps a hidden bold copy of each label.
    await tester.tap(find.text('Received').last);
    await tester.pumpAndSettle();
    expect(find.text('Highlands Coffee'), findsNothing);
    expect(find.text('Lương tháng trước'), findsOneWidget);
  });
}
