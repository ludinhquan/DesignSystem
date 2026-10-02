import 'package:ds/ds.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/themed.dart';

/// Records HapticFeedback calls.
List<String> _haptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  group('DsMoneyFormat', () {
    test('vi-VN grouping, no-break space, true minus', () {
      expect(DsMoneyFormat.format(24580000), '24.580.000 ₫');
      expect(DsMoneyFormat.format(-65000), '−65.000 ₫');
      expect(DsMoneyFormat.format(18500000, sign: true), '+18.500.000 ₫');
      expect(DsMoneyFormat.format(0, sign: true), '0 ₫');
    });

    test('chips abbreviate', () {
      expect(DsMoneyFormat.chip(100000), '+100K');
      expect(DsMoneyFormat.chip(1000000), '+1M');
      expect(DsMoneyFormat.chip(1500), '+1.500');
    });
  });

  group('DsMoney', () {
    testWidgets('reads aloud as words, not glyphs', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDs(const DsMoney(-65000, sign: true));
      expect(find.bySemanticsLabel('minus 65.000 dong'), findsOneWidget);
      await tester.pumpDs(const DsMoney(18500000, sign: true));
      expect(find.bySemanticsLabel('plus 18.500.000 dong'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('inflows with a sign are positive; outflows stay text-1', (
      tester,
    ) async {
      // The colour a run of text is painted in: the nearest style down the
      // span tree that sets one.
      Color? colorOf(String text) {
        Color? found;
        void walk(InlineSpan span, Color? inherited) {
          final color = span.style?.color ?? inherited;
          if (span is TextSpan) {
            if (span.text == text) found = color;
            for (final child in span.children ?? const <InlineSpan>[]) {
              walk(child, color);
            }
          }
        }

        for (final r in tester.widgetList<RichText>(find.byType(RichText))) {
          walk(r.text, null);
        }
        return found;
      }

      await tester.pumpDs(
        const Column(
          children: [DsMoney(-65000, sign: true), DsMoney(1000, sign: true)],
        ),
      );
      final c = pebble.tokens.colorsLight;
      expect(colorOf('−65.000'), c.text1);
      expect(colorOf('+1.000'), c.positive);
    });

    testWidgets('a hidden balance shows dots and keeps its footprint', (
      tester,
    ) async {
      await tester.pumpDs(const DsMoney(24580000, size: DsMoneySize.hero));
      final shown = tester.getSize(find.byType(DsMoney));
      await tester.pumpDs(
        const DsMoney(24580000, size: DsMoneySize.hero, hidden: true),
      );
      expect(find.text('••••••'), findsOneWidget);
      expect(tester.getSize(find.byType(DsMoney)), shown);
    });

    testWidgets('roll settles on the new value', (tester) async {
      await tester.pumpDs(const DsMoney(100, roll: true));
      await tester.pumpDs(const DsMoney(250, roll: true));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });
  });

  group('DsButton', () {
    testWidgets('taps, disables and loads', (tester) async {
      var taps = 0;
      await tester.pumpDs(DsButton(label: 'Gửi', onPressed: () => taps++));
      await tester.tap(find.text('Gửi'));
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.pumpDs(
        DsButton(label: 'Gửi', loading: true, onPressed: () => taps++),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Gửi'), warnIfMissed: false);
      expect(taps, 1);
    });

    testWidgets('every size has a tap target of at least hit-target', (
      tester,
    ) async {
      for (final system in systems.values) {
        for (final size in DsButtonSize.values) {
          await tester.pumpDs(
            DsButton(label: 'Ok', size: size, onPressed: () {}),
            system: system,
          );
          // Let the theme animation reach the new system.
          await tester.pump(const Duration(seconds: 1));
          final box = tester.getSize(find.byType(DsPressable));
          expect(
            box.height,
            greaterThanOrEqualTo(system.tokens.sizes.hitTarget),
          );
        }
      }
    });

    testWidgets('announces the loading state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDs(
        DsButton(label: 'Gửi', loading: true, onPressed: () {}),
      );
      expect(
        tester.getSemantics(find.byType(DsButton)),
        matchesSemantics(
          label: 'Gửi',
          value: 'Loading',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('only the prominent press fires a haptic', (tester) async {
      final haptics = _haptics(tester);
      await tester.pumpDs(
        Column(
          children: [
            DsButton(label: 'A', onPressed: () {}),
            DsButton(
              label: 'B',
              variant: DsButtonVariant.prominent,
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('a system with haptics off fires none', (tester) async {
      final haptics = _haptics(tester);
      await tester.pumpDs(
        DsButton(
          label: 'B',
          variant: DsButtonVariant.prominent,
          onPressed: () {},
        ),
        system: classic,
      );
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(haptics, isEmpty);
    });
  });

  testWidgets('DsToggle flips through onChanged and exposes its state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var value = false;
    await tester.pumpDs(
      StatefulBuilder(
        builder: (context, setState) => DsToggle(
          value: value,
          semanticLabel: 'Face ID',
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    );
    await tester.tap(find.byType(DsToggle));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(
      tester.getSemantics(find.byType(DsToggle)),
      matchesSemantics(
        label: 'Face ID',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('DsSegmentedControl selects another segment', (tester) async {
    int? picked;
    await tester.pumpDs(
      SizedBox(
        width: 300,
        child: DsSegmentedControl<int>(
          segments: const [DsSegment(0, 'Tuần'), DsSegment(1, 'Tháng')],
          value: 0,
          onChanged: (v) => picked = v,
        ),
      ),
    );
    await tester.tap(find.text('Tháng').last);
    expect(picked, 1);
  });

  testWidgets('DsTabBar reports the tapped tab', (tester) async {
    int? picked;
    final icons = pebble.icons;
    await tester.pumpDs(
      DsTabBar(
        index: 0,
        onChanged: (i) => picked = i,
        items: [
          DsTabItem(icon: icons.home, label: 'Home'),
          DsTabItem(icon: icons.cards, label: 'Cards'),
          DsTabItem(icon: icons.profile, label: 'Profile'),
        ],
      ),
    );
    await tester.tap(find.bySemanticsLabel('Profile'));
    expect(picked, 2);
  });

  group('DsAmountField', () {
    Widget field(ValueNotifier<int> v) => ValueListenableBuilder(
      valueListenable: v,
      builder: (context, value, _) => SizedBox(
        width: 360,
        child: DsAmountField(
          value: value,
          onChanged: (n) => v.value = n,
          available: 1000000,
          sourceField: DsField.yellow,
          sourceName: 'Chi tiêu',
          inputKey: const Key('amount'),
        ),
      ),
    );

    testWidgets('typing and chips set the amount', (tester) async {
      final v = ValueNotifier(0);
      await tester.pumpDs(field(v));
      await tester.enterText(find.byKey(const Key('amount')), '25a0000');
      await tester.pump();
      expect(v.value, 250000);
      await tester.tap(find.text('+100K'));
      expect(v.value, 350000);
    });

    testWidgets('over the balance warns once, with an error haptic', (
      tester,
    ) async {
      final haptics = _haptics(tester);
      final v = ValueNotifier(900000);
      await tester.pumpDs(field(v));
      expect(find.text('More than the available balance'), findsNothing);
      await tester.tap(find.text('+500K'));
      await tester.pumpAndSettle();
      expect(find.text('More than the available balance'), findsOneWidget);
      expect(haptics, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.errorNotification',
      ]);
    });
  });

  group('DsCardStack', () {
    const cards = [
      DsCardData(id: 'a', field: DsField.yellow, name: 'A', balance: 1),
      DsCardData(id: 'b', field: DsField.green, name: 'B', balance: 2),
      DsCardData(id: 'c', field: DsField.blue, name: 'C', balance: 3),
    ];

    testWidgets('the top band brings a card forward; the front opens', (
      tester,
    ) async {
      final changes = <String>[];
      final opened = <String>[];
      await tester.pumpDs(
        SizedBox(
          width: 340,
          child: DsCardStack(
            cards: cards,
            onChanged: changes.add,
            onOpen: opened.add,
          ),
        ),
      );
      final top = tester.getTopLeft(find.byType(DsCardStack));
      // The deepest card owns the top slice of the band.
      await tester.tapAt(top + const Offset(170, 4));
      await tester.pumpAndSettle();
      expect(changes, ['c']);

      await tester.tapAt(tester.getCenter(find.byType(DsCardStack)));
      await tester.pumpAndSettle();
      expect(opened, ['c']);
    });
  });

  testWidgets('DsTapToPay plays the moment once on success', (tester) async {
    final haptics = _haptics(tester);
    Widget pay(DsPayStatus s) => SizedBox(
      width: 340,
      child: DsTapToPay(
        card: const DsCardData(
          id: 'a',
          field: DsField.yellow,
          name: 'A',
          balance: 1,
        ),
        status: s,
        amount: 65000,
        readyLabel: 'Hold near the reader',
        successLabel: 'Paid',
      ),
    );
    await tester.pumpDs(pay(DsPayStatus.ready));
    expect(find.text('Hold near the reader'), findsOneWidget);
    await tester.pumpDs(pay(DsPayStatus.success));
    await tester.pump(const Duration(milliseconds: 100));
    expect(haptics, isEmpty, reason: 'never before the ring frame');
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.successNotification']);
    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('DsTapToPay shown already paid plays nothing', (tester) async {
    final haptics = _haptics(tester);
    await tester.pumpDs(
      const SizedBox(
        width: 340,
        child: DsTapToPay(
          card: DsCardData(
            id: 'a',
            field: DsField.yellow,
            name: 'A',
            balance: 1,
          ),
          status: DsPayStatus.success,
          amount: 65000,
          readyLabel: 'r',
          successLabel: 'Paid',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(haptics, isEmpty);
  });

  testWidgets('DsTextField: label names the input, clear button clears', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController(text: 'abc');
    await tester.pumpDs(
      SizedBox(
        width: 320,
        child: DsTextField(
          label: 'Ghi chú',
          controller: controller,
          error: 'Quá dài',
        ),
      ),
    );
    expect(find.text('Quá dài'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Ghi chú')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Delete'));
    expect(controller.text, isEmpty);
    handle.dispose();
  });

  testWidgets('default strings come from DsLocalizations', (tester) async {
    await tester.pumpDs(
      const DsErrorView(message: 'm', onRetry: _noop),
      localizationsDelegates: const [_PseudoDelegate()],
    );
    expect(find.text('[error]'), findsOneWidget);
    expect(find.text('[retry]'), findsOneWidget);
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
  @override
  String get close => '[close]';
  @override
  String get hiddenAmount => '[hidden]';
  @override
  String amountSemantics(
    String amount, {
    required bool negative,
    required bool positive,
  }) => '[$amount]';
  @override
  String cardSemantics({
    required String name,
    required String balance,
    String? institution,
    String? last4,
  }) => '[$name]';
  @override
  String amountFrom(String account) => '[from]';
  @override
  String amountAvailable(String amount) => '[available]';
  @override
  String get amountOverBalance => '[over]';
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
