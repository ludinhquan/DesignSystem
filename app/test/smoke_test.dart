import 'package:app/app.dart';
import 'package:app/core/analytics.dart';
import 'package:app/core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/harness.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    final p = await setUpStorage(prefs: prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          analyticsProvider.overrideWithValue(FakeAnalytics()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the app starts on the home screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome to Acme!'), findsOneWidget);
  });

  testWidgets('switching to Vietnamese translates and is saved', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng bạn đến với Acme!'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.locale'), 'vi');
  });

  testWidgets('the saved language is used on start', (tester) async {
    await pumpApp(tester, prefs: {'app.locale': 'vi'});
    expect(find.text('Ngôn ngữ'), findsOneWidget);
  });
}
