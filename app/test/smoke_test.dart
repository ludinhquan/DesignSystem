import 'package:app/app.dart';
import 'package:app/core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/harness.dart';

void main() {
  testWidgets('the app starts on the home screen', (tester) async {
    final prefs = await setUpStorage();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );
    expect(find.text('Welcome to Acme'), findsOneWidget);
  });
}
