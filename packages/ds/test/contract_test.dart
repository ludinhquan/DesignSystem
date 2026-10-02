import 'dart:math' as math;

import 'package:ds/ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/themed.dart';

/// WCAG 2 contrast of [fg] over [bg] (translucent colours composited on
/// [ground]).
double contrast(Color fg, Color bg, {Color? ground}) {
  final b = ground == null ? bg : Color.alphaBlend(bg, ground);
  final f = Color.alphaBlend(fg, b);
  double l(Color c) {
    double ch(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final (a, z) = (l(f), l(b));
  return (math.max(a, z) + 0.05) / (math.min(a, z) + 0.05);
}

void main() {
  for (final MapEntry(key: name, value: system) in systems.entries) {
    for (final b in Brightness.values) {
      final c = b == Brightness.light
          ? system.tokens.colorsLight
          : system.tokens.colorsDark;
      group('$name ${b.name}: contrast floors', () {
        for (final (label, ground) in [
          ('canvas', c.canvas),
          ('surface', c.surface),
          ('surface-2', c.surface2),
          ('surface-3', c.surface3),
        ]) {
          test('text-1 and text-2 hold 4.5:1 on $label', () {
            expect(contrast(c.text1, ground), greaterThanOrEqualTo(4.5));
            expect(contrast(c.text2, ground), greaterThanOrEqualTo(4.5));
          });
          test('text-3 and focus ring hold 3:1 on $label', () {
            expect(contrast(c.text3, ground), greaterThanOrEqualTo(3));
            expect(contrast(c.focusRing, ground), greaterThanOrEqualTo(3));
          });
          test('status and link colours hold 4.5:1 on $label', () {
            expect(contrast(c.accentText, ground), greaterThanOrEqualTo(4.5));
            expect(contrast(c.positive, ground), greaterThanOrEqualTo(4.5));
            expect(contrast(c.negative, ground), greaterThanOrEqualTo(4.5));
          });
        }

        test('on-accent holds 4.5:1 on accent and accent-pressed', () {
          expect(contrast(c.onAccent, c.accent), greaterThanOrEqualTo(4.5));
          expect(
            contrast(c.onAccent, c.accentPressed),
            greaterThanOrEqualTo(4.5),
          );
        });

        test('text-1 holds 4.5:1 on the soft status grounds', () {
          for (final soft in [c.accentSoft, c.positiveSoft, c.negativeSoft]) {
            expect(contrast(c.text1, soft), greaterThanOrEqualTo(4.5));
          }
        });

        for (final f in DsField.values) {
          test('object ink holds 4.5:1 on both stops of ${f.name}', () {
            final o = c.field(f);
            for (final stop in [o.face, o.end]) {
              expect(contrast(o.ink, stop), greaterThanOrEqualTo(4.5));
              expect(contrast(o.ink2, stop), greaterThanOrEqualTo(4.5));
            }
          });
        }
      });
    }
  }

  test('every system resolves all type roles on every platform', () {
    for (final system in systems.values) {
      for (final p in TargetPlatform.values) {
        final t = DsTokens(system, Brightness.light, platform: p).text;
        expect(t.displayHero.fontSize, greaterThan(t.body.fontSize!));
        expect(t.caption.fontSize, greaterThanOrEqualTo(12));
      }
    }
  });

  test('Pebble uses Inter on Android and the platform face on iOS', () {
    TextStyle body(TargetPlatform p) =>
        DsTokens(pebble, Brightness.light, platform: p).text.body;
    expect(body(TargetPlatform.android).fontFamily, 'packages/ds/Inter');
    expect(body(TargetPlatform.iOS).fontFamily, isNull);
    final hero = DsTokens(
      pebble,
      Brightness.light,
      platform: TargetPlatform.iOS,
    ).text.displayHero;
    expect(hero.fontFamily, 'packages/ds/BricolageGrotesque');
    expect(
      hero.fontVariations!.map((v) => v.axis),
      containsAll(['wght', 'opsz', 'wdth']),
    );
    expect(hero.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('switching the system switches every token, not only colours', () {
    final p = DsTokens(pebble, Brightness.light);
    final k = DsTokens(classic, Brightness.light);
    expect(p.colors.accent, isNot(k.colors.accent));
    expect(p.radius.card, isNot(k.radius.card));
    expect(p.shape(8), isA<RoundedSuperellipseBorder>());
    expect(k.shape(8), isA<RoundedRectangleBorder>());
    expect(
      p.icons.home.regular.fontFamily,
      isNot(k.icons.home.regular.fontFamily),
    );
  });

  test('DsTokens lerps colours and keeps the rest from the nearer side', () {
    final a = DsTokens(pebble, Brightness.light);
    final b = DsTokens(pebble, Brightness.dark);
    final mid = a.lerp(b, 0.5);
    expect(mid.colors.canvas, Color.lerp(a.colors.canvas, b.colors.canvas, .5));
    expect(a.lerp(b, 0.2).brightness, Brightness.light);
    expect(a.lerp(b, 0.8).brightness, Brightness.dark);
  });

  test('springs follow stiffness = (2π/d)², damping = 4π(1−bounce)/d', () {
    final s = pebble.motion.object.description;
    expect(s.stiffness, closeTo(157.9, 0.1));
    expect(s.damping, closeTo(20.1, 0.1));
    expect(pebble.motion.object.curve.transform(1), 1);
  });
}
