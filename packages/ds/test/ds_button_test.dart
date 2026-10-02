import 'package:ds/ds.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('DsErrorView shows the given message and retries', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpDs(
      DsErrorView(message: 'No connection', onRetry: () => retries++),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('default strings come from DsLocalizations', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpDs(
      Column(
        children: [
          DsButton(label: 'Save', loading: true, onPressed: () {}),
          const Expanded(
            child: DsErrorView(message: 'm', onRetry: _noop),
          ),
        ],
      ),
      localizationsDelegates: const [_PseudoDelegate()],
    );
    expect(
      tester.getSemantics(find.byType(DsButton).first),
      matchesSemantics(
        label: 'Save',
        value: '[loading]',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    expect(find.text('[error]'), findsOneWidget);
    expect(find.text('[retry]'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a missing DsLocalizations delegate fails loudly in debug', (
    tester,
  ) async {
    await tester.pumpDs(
      const DsErrorView(message: 'm'),
      localizationsDelegates: const [],
    );
    expect(tester.takeException(), isAssertionError);
  });
}

void _noop() {}

class _Pseudo extends DsLocalizations {
  const _Pseudo();
  @override
  String get loading => '[loading]';
  @override
  String get errorTitle => '[error]';
  @override
  String get retry => '[retry]';
}

class _PseudoDelegate extends LocalizationsDelegate<DsLocalizations> {
  const _PseudoDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<DsLocalizations> load(Locale locale) =>
      SynchronousFuture(const _Pseudo());
  @override
  bool shouldReload(_PseudoDelegate old) => false;
}
