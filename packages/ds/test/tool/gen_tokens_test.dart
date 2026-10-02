import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/tokens_codegen.dart';

Map<String, Object?> _load(String system) =>
    jsonDecode(File('systems/$system/tokens.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, String> _fields(String system) =>
    ((jsonDecode(File('systems/$system/system.json').readAsStringSync())
                as Map)['fields']
            as Map)
        .cast<String, String>();

void main() {
  group('parseColor', () {
    test('hex in every length', () {
      expect(parseColor('#FFC233')!.dart, 'Color(0xFFFFC233)');
      expect(parseColor('#fc3')!.dart, 'Color(0xFFFFCC33)');
      expect(parseColor('#11223380')!.dart, 'Color(0x80112233)');
    });

    test('rgb and rgba', () {
      expect(parseColor('rgba(26, 23, 18, 0.06)')!.dart, 'Color(0x0F1A1712)');
      expect(parseColor('rgb(0,0,0)')!.dart, 'Color(0xFF000000)');
      expect(parseColor('rgba(0, 0, 0, 50%)')!.dart, 'Color(0x80000000)');
    });

    test('anything else is not a colour', () {
      expect(parseColor('red'), isNull);
      expect(parseColor('var(--x)'), isNull);
    });
  });

  group('parseShadow', () {
    test('several layers with inset, spread and negative values', () {
      final layers = parseShadow(
        'inset 0 1px 0 rgba(255, 255, 255, 0.45), '
        '0 8px 18px -8px rgba(122, 78, 0, 0.45)',
      );
      expect(layers, hasLength(2));
      expect(layers[0].inset, isTrue);
      expect(layers[0].dy, 1);
      expect(layers[1].spread, -8);
      expect(layers[1].blur, 18);
      expect(
        layers[1].dart,
        'DsShadowLayer(color: Color(0x737A4E00), dy: 8, blur: 18, spread: -8)',
      );
    });

    test('none is empty', () => expect(parseShadow('none'), isEmpty));
  });

  test('Pebble fills the contract, with aliases resolved per theme', () {
    final out = generate(
      tokens: _load('pebble'),
      dartName: 'pebble',
      fieldNames: _fields('pebble'),
      source: 'test',
    );
    expect(out, contains("name: 'Pebble'"));
    // on-obj-marigold is an alias of on-object.
    expect(out, contains('ink: Color(0xFF1A1712)'));
    // Graphite has no tint token: the field gets none.
    expect(
      RegExp('graphite: DsFieldColors\\([^)]*tint').hasMatch(out),
      isFalse,
    );
  });

  test('Classic fills the contract too', () {
    expect(
      () => generate(
        tokens: _load('classic'),
        dartName: 'classic',
        fieldNames: _fields('classic'),
        source: 'test',
      ),
      returnsNormally,
    );
  });

  test('a missing contract token names every gap at once', () {
    final tokens = _load('pebble');
    final colors = (tokens['color']! as Map)['tokens']! as List;
    colors.removeWhere(
      (e) => ['canvas', 'obj-sky-end'].contains((e as Map)['name']),
    );
    expect(
      () => generate(
        tokens: tokens,
        dartName: 'pebble',
        fieldNames: _fields('pebble'),
        source: 'test',
      ),
      throwsA(
        isA<TokensException>().having(
          (e) => e.problems.join('\n'),
          'problems',
          allOf(contains('"canvas"'), contains('"obj-sky-end"')),
        ),
      ),
    );
  });
}
