import 'package:app/core/storage.dart';
import 'package:app/features/auth/auth_routes.dart';
import 'package:app/features/auth/data/session_controller.dart';
import 'package:app/features/home/ui/tap_count_controller.dart';
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
    'login -> home -> switch EN/VI -> logout clears user state -> login',
    (tester) async {
      final analytics = FakeAnalytics();
      final container = await pumpApp(tester, analytics: analytics);

      // Log in: the router leaves /login for home.
      await logIn(tester);
      expect(location(tester), '/');
      expect(find.text('Welcome to Acme, lan!'), findsOneWidget);

      // Per-user state.
      await tester.tap(find.text('Tap'));
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(find.text('You tapped the button 2 times'), findsOneWidget);

      // Switch to Vietnamese; the choice is saved.
      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();
      expect(find.text('Chào mừng bạn đến với Acme, lan!'), findsOneWidget);
      expect(find.text('Bạn đã nhấn nút 2 lần'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app.locale'), 'vi');

      // And back to English.
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // Log out: back to login, tokens and user state gone.
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(location(tester), AuthPaths.login);
      expect(container.read(sessionProvider).value, isNull);
      expect(await container.read(tokenStoreProvider).read(), isNull);
      expect(container.read(tapCountProvider), 0);
      expect(analytics.calls, containsAllInOrder(['track:logout', 'reset']));

      // A new login starts from a clean slate.
      await logIn(tester, email: 'minh@example.com');
      expect(find.text('Welcome to Acme, minh!'), findsOneWidget);
      expect(find.text('You have not tapped the button yet'), findsOneWidget);
    },
  );
}
