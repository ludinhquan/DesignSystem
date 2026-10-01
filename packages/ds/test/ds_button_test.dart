import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/themed.dart';

void main() {
  testWidgets('enabled button calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpDs(DsButton(label: 'Save', onPressed: () => taps++));
    await tester.tap(find.byType(DsButton));
    expect(taps, 1);
  });

  testWidgets('disabled button ignores taps', (tester) async {
    await tester.pumpDs(const DsButton(label: 'Save', onPressed: null));
    await tester.tap(find.byType(DsButton), warnIfMissed: false);
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('loading button shows a spinner and ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpDs(
      DsButton(label: 'Save', loading: true, onPressed: () => taps++),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(DsButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('every size has a tap target of at least 48x48', (tester) async {
    for (final size in DsButtonSize.values) {
      await tester.pumpDs(DsButton(label: 'Ok', size: size, onPressed: () {}));
      final box = tester.getSize(find.byType(TextButton));
      expect(box.height, greaterThanOrEqualTo(DsSize.minTapTarget));
      expect(box.width, greaterThanOrEqualTo(DsSize.minTapTarget));
    }
  });

  testWidgets('exposes button semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpDs(DsButton(label: 'Save', onPressed: () {}));
    expect(
      tester.getSemantics(find.byType(DsButton)),
      matchesSemantics(
        label: 'Save',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpDs(
      DsButton(label: 'Save', loading: true, onPressed: () {}),
    );
    expect(
      tester.getSemantics(find.byType(DsButton)),
      matchesSemantics(
        label: 'Save',
        value: 'Loading',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('DsTokens lerp and copyWith', (tester) async {
    final a = DsTokens.light(baseRadius: 4);
    final b = DsTokens.dark(baseRadius: 12);
    expect(a.lerp(b, 1).radius.md, 12);
    expect(a.lerp(b, 0.5).radius.md, 8);
    expect(a.copyWith(textMuted: b.textMuted).textMuted, b.textMuted);
  });

  testWidgets('DsErrorView retry calls back', (tester) async {
    var retries = 0;
    await tester.pumpDs(DsErrorView('boom', onRetry: () => retries++));
    expect(find.text('boom'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
}
