import 'package:ds_components/ds_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders its child on the raised surface', (tester) async {
      await tester.pumpApp(const AppCard(child: Text('Hello')));

      expect(find.text('Hello'), findsOneWidget);
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, AppColors.light.surfaceRaised);
    });

    testWidgets('is not tappable without onTap', (tester) async {
      await tester.pumpApp(const AppCard(child: Text('Hello')));
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('calls onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppCard(onTap: () => taps++, child: const Text('Hello')),
      );
      await tester.tap(find.text('Hello'));
      expect(taps, 1);
    });

    testWidgets('meets text contrast in dark mode', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const AppCard(child: Text('Readable')),
        theme: AppTheme.dark(),
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
