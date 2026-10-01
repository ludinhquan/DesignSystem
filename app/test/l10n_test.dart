import 'dart:convert';
import 'dart:io';

import 'package:app/l10n/l10n.dart';
import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] with the app's delegates in [locale].
Future<BuildContext> pumpIn(WidgetTester tester, Locale locale) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  test('every ARB file has exactly the template keys', () {
    Set<String> keys(String file) => (jsonDecode(
      File('lib/l10n/$file').readAsStringSync(),
    ) as Map<String, Object?>).keys.where((k) => !k.startsWith('@')).toSet();
    final template = keys('app_en.arb');
    for (final locale in AppLocalizations.supportedLocales) {
      expect(
        keys('app_${locale.languageCode}.arb'),
        template,
        reason: '$locale',
      );
    }
  });

  testWidgets('material_ui built-in strings are Vietnamese', (tester) async {
    final context = await pumpIn(tester, const Locale('vi'));
    final material = MaterialLocalizations.of(context);
    expect(material, isA<MaterialLocalizationVi>());
    expect(material.backButtonTooltip, 'Quay lại');
  });

  testWidgets(
    'the generated AppLocalizations.localizationsDelegates breaks material_ui',
    (tester) async {
      // It lists flutter_localizations' GlobalMaterialLocalizations, whose
      // MaterialLocalizations type is the in-SDK one. material_ui then finds
      // no MaterialLocalizations for vi at all. That is why the app uses
      // appLocalizationsDelegates instead.
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('locale, vi, is not supported'),
      );
      expect(
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations),
        isNull,
      );
    },
  );

  testWidgets('design-system strings come from the app ARB files', (
    tester,
  ) async {
    final vi = DsLocalizations.of(await pumpIn(tester, const Locale('vi')));
    expect(
      [vi.loading, vi.errorTitle, vi.retry],
      ['Đang tải', 'Đã có lỗi xảy ra', 'Thử lại'],
    );

    final en = DsLocalizations.of(await pumpIn(tester, const Locale('en')));
    expect(
      [en.loading, en.errorTitle, en.retry],
      ['Loading', 'Something went wrong', 'Retry'],
    );
  });
}
