import 'package:app/features/auth/data/session_controller.dart';
import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/harness.dart';

void main() {
  DsButton submit(WidgetTester tester) =>
      tester.widget<DsButton>(find.byKey(const Key('login.submit')));

  testWidgets('validates empty fields with localized messages', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('shows the button loading while logging in', (tester) async {
    final container = await pumpApp(tester);
    expect(find.text('Sign in to Acme'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login.email')),
      'lan@example.com',
    );
    await tester.enterText(find.byKey(const Key('login.password')), 'secret');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pump();

    expect(submit(tester).loading, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(fakeLoginDelay);
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider).value?.email, 'lan@example.com');
  });

  testWidgets('a rejected login shows a localized error and stays', (
    tester,
  ) async {
    await pumpApp(tester);
    await logIn(tester, password: 'wrong');

    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(find.text('Sign in to Acme'), findsOneWidget);
    expect(submit(tester).loading, isFalse);
  });

  testWidgets('is translated to Vietnamese', (tester) async {
    await pumpApp(tester, prefs: {'app.locale': 'vi'});
    expect(find.text('Đăng nhập vào Acme'), findsOneWidget);

    await logIn(tester, password: 'wrong');
    expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
  });
}
