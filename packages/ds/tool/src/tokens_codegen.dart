// Turns a Design System `tokens.json` (the claude.ai Design System artifact
// format: every family is a list of {name, value, usage}) into a Dart
// `DsTokenSet`. Pure Dart, no build_runner.

/// Thrown with every problem found, so one run lists them all.
class TokensException implements Exception {
  TokensException(this.problems);

  final List<String> problems;

  @override
  String toString() =>
      'tokens.json does not fill the design-system contract:\n'
      '${problems.map((p) => '  - $p').join('\n')}';
}

/// Contract colour token names → DsColors field names.
const contractColors = {
  'canvas': 'canvas',
  'surface': 'surface',
  'surface-2': 'surface2',
  'surface-3': 'surface3',
  'thumb': 'thumb',
  'knob': 'knob',
  'fill-subtle': 'fillSubtle',
  'fill-strong': 'fillStrong',
  'separator': 'separator',
  'glass': 'glass',
  'scrim': 'scrim',
  'text-1': 'text1',
  'text-2': 'text2',
  'text-3': 'text3',
  'accent': 'accent',
  'accent-pressed': 'accentPressed',
  'on-accent': 'onAccent',
  'accent-text': 'accentText',
  'accent-soft': 'accentSoft',
  'focus-ring': 'focusRing',
  'positive': 'positive',
  'positive-soft': 'positiveSoft',
  'negative': 'negative',
  'negative-soft': 'negativeSoft',
};

/// The hue slots of DsField, in declaration order.
const contractFields = ['yellow', 'red', 'blue', 'green', 'purple', 'graphite'];

const contractShadows = {
  'shadow-surface': 'surface',
  'shadow-highlight': 'highlight',
  'shadow-obj-press': 'objectPress',
  'shadow-accent': 'accent',
  'shadow-glass': 'glass',
  'shadow-knob': 'knob',
  'shadow-sheet': 'sheet',
};

const contractType = [
  'display-hero',
  'display-entry',
  'title-screen',
  'display-card',
  'title-section',
  'amount-row',
  'monogram',
  'headline',
  'body',
  'button',
  'row-title',
  'callout',
  'subhead',
  'button-sm',
  'footnote',
  'label',
  'caption',
  'tile-label',
  'tab-label',
  'chip',
];

const contractSpacing = {
  'space-1': 's1',
  'space-2': 's2',
  'space-3': 's3',
  'space-4': 's4',
  'space-5': 's5',
  'space-6': 's6',
  'space-8': 's8',
  'space-12': 's12',
  'gutter': 'gutter',
};

const contractRadii = {
  'radius-xs': 'xs',
  'radius-glyph': 'glyph',
  'radius-tile-sm': 'tileSm',
  'radius-tile-lg': 'tileLg',
  'radius-tile': 'tile',
  'radius-card': 'card',
  'radius-sheet': 'sheet',
  'radius-sheet-bottom': 'sheetBottom',
  'radius-full': 'full',
};

const contractSizes = {
  'hit-target': 'hitTarget',
  'control-sm': 'controlSm',
  'control-md': 'controlMd',
  'control-lg': 'controlLg',
  'field-height': 'fieldHeight',
  'row-content': 'rowContent',
  'row-min': 'rowMin',
  'avatar': 'avatar',
  'avatar-lg': 'avatarLg',
  'glyph-tile': 'glyphTile',
  'icon-size-inline': 'iconInline',
  'icon-size-nav': 'iconNav',
  'icon-size-tab': 'iconTab',
  'tab-pill': 'tabPill',
  'tile-row': 'tileRow',
  'tile-sm': 'tileSm',
  'tile-lg': 'tileLg',
  'emoji-row': 'emojiRow',
  'emoji-tile': 'emojiTile',
  'emoji-moment': 'emojiMoment',
  'emoji-onboarding': 'emojiOnboarding',
  'card-aspect': 'cardAspect',
  'card-max': 'cardMax',
  'stack-peek': 'stackPeek',
  'tabbar-fade': 'tabbarFade',
};

const contractOpacity = {
  'opacity-grain': 'grain',
  'opacity-specular': 'specular',
  'opacity-shift': 'shift',
  'opacity-disabled': 'disabled',
};

/// An RGBA colour (0–255 channels, alpha 0–1).
class Rgba {
  const Rgba(this.r, this.g, this.b, this.a);

  final int r;
  final int g;
  final int b;
  final double a;

  String get dart {
    final alpha = (a * 255).round();
    String hex(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    return 'Color(0x${hex(alpha)}${hex(r)}${hex(g)}${hex(b)})';
  }
}

final _hex = RegExp(r'^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
final _rgb = RegExp(
  r'^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+%?)\s*)?\)$',
);

/// Parses `#rgb[a]`, `#rrggbb[aa]`, `rgb()`, `rgba()`. Returns null otherwise.
Rgba? parseColor(String raw) {
  final s = raw.trim();
  if (_hex.firstMatch(s) case final m?) {
    var h = m.group(1)!;
    if (h.length <= 4) h = h.split('').map((c) => '$c$c').join();
    int at(int i) => int.parse(h.substring(i, i + 2), radix: 16);
    return Rgba(at(0), at(2), at(4), h.length == 8 ? at(6) / 255 : 1);
  }
  if (_rgb.firstMatch(s) case final m?) {
    final a = m.group(4);
    return Rgba(
      double.parse(m.group(1)!).round(),
      double.parse(m.group(2)!).round(),
      double.parse(m.group(3)!).round(),
      a == null
          ? 1
          : a.endsWith('%')
          ? double.parse(a.substring(0, a.length - 1)) / 100
          : double.parse(a),
    );
  }
  return null;
}

/// A length in px (`16px`, `0.5px`, `1rem` = 16, a bare number).
double? parseLength(Object? raw) {
  if (raw is num) return raw.toDouble();
  if (raw is! String) return null;
  final s = raw.trim();
  if (s.endsWith('px')) return double.tryParse(s.substring(0, s.length - 2));
  if (s.endsWith('rem')) {
    return (double.tryParse(s.substring(0, s.length - 3)) ?? 0) * 16;
  }
  return double.tryParse(s);
}

class ShadowLayer {
  ShadowLayer(this.color, this.dx, this.dy, this.blur, this.spread, this.inset);

  final Rgba color;
  final double dx;
  final double dy;
  final double blur;
  final double spread;
  final bool inset;

  String get dart {
    final args = [
      'color: ${color.dart}',
      if (dx != 0) 'dx: ${_num(dx)}',
      if (dy != 0) 'dy: ${_num(dy)}',
      if (blur != 0) 'blur: ${_num(blur)}',
      if (spread != 0) 'spread: ${_num(spread)}',
      if (inset) 'inset: true',
    ];
    return 'DsShadowLayer(${args.join(', ')})';
  }
}

/// Splits on commas that are not inside parentheses.
List<String> _splitTop(String s) {
  final out = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ',' && depth == 0) {
      out.add(s.substring(start, i).trim());
      start = i + 1;
    }
  }
  out.add(s.substring(start).trim());
  return out.where((p) => p.isNotEmpty).toList();
}

/// Parses a CSS `box-shadow` list. `none` is an empty list.
List<ShadowLayer> parseShadow(String css) {
  if (css.trim() == 'none') return const [];
  return [
    for (final layer in _splitTop(css))
      () {
        var rest = layer;
        final inset = rest.startsWith('inset ');
        if (inset) rest = rest.substring(6).trim();
        final colorStart = rest.indexOf(RegExp(r'(rgba?\(|#)'));
        if (colorStart < 0) throw FormatException('No colour in "$layer"');
        final color = parseColor(rest.substring(colorStart));
        if (color == null) throw FormatException('Bad colour in "$layer"');
        final lengths = rest
            .substring(0, colorStart)
            .trim()
            .split(RegExp(r'\s+'))
            .map(parseLength)
            .toList();
        if (lengths.length < 2 || lengths.contains(null)) {
          throw FormatException('Bad lengths in "$layer"');
        }
        double at(int i) => i < lengths.length ? lengths[i]! : 0;
        return ShadowLayer(color, at(0), at(1), at(2), at(3), inset);
      }(),
  ];
}

String _num(double v) {
  final s = v.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

String _dartNum(double v) => v == v.roundToDouble() ? '${v.round()}.0' : '$v';

/// Generates the Dart source for one system.
///
/// [fieldNames] maps each contract hue slot (`yellow`) to the system's own
/// field name (`marigold`), used in `obj-<name>`, `tint-<name>` ... tokens.
String generate({
  required Map<String, Object?> tokens,
  required String dartName,
  required Map<String, String> fieldNames,
  required String source,
}) {
  final problems = <String>[];

  List<Map<String, Object?>> family(String key) {
    final f = tokens[key];
    if (f is! Map || f['tokens'] is! List) return const [];
    return [
      for (final e in f['tokens'] as List)
        if (e is Map<String, Object?>) e,
    ];
  }

  // ---- Colours, resolved per theme with aliases.
  final themes = [
    for (final t in (tokens['color'] as Map?)?['themes'] as List? ?? const [])
      (t as Map)['id'] as String,
  ];
  if (!themes.contains('light') || !themes.contains('dark')) {
    problems.add('color.themes must include "light" and "dark"');
  }
  final rawColors = {for (final e in family('color')) e['name'] as String: e};

  Rgba? color(String name, String theme, [Set<String> seen = const {}]) {
    final entry = rawColors[name];
    if (entry == null || seen.contains(name)) return null;
    final v = entry['value'];
    final raw = switch (v) {
      final String s => s,
      final Map<String, Object?> m =>
        (m[theme] ?? m[themes.isEmpty ? 'light' : themes.first]) as String?,
      _ => null,
    };
    if (raw == null) return null;
    final alias = RegExp(r'^\{(.+)\}$').firstMatch(raw.trim());
    if (alias != null) return color(alias.group(1)!, theme, {...seen, name});
    return parseColor(raw);
  }

  String requireColor(String name, String theme) {
    final c = color(name, theme);
    if (c == null) {
      problems.add('color "$name" ($theme) is missing or not a colour');
      return 'Color(0x00000000)';
    }
    return c.dart;
  }

  // ---- Shadows per theme.
  final rawShadows = {for (final e in family('shadow')) e['name'] as String: e};

  String shadow(String name, String theme) {
    final v = rawShadows[name]?['value'];
    final css = switch (v) {
      final String s => s,
      final Map<String, Object?> m => (m[theme] ?? m['light']) as String?,
      _ => null,
    };
    if (css == null) {
      problems.add('shadow "$name" is missing');
      return 'DsShadow.none';
    }
    try {
      final layers = parseShadow(css);
      if (layers.isEmpty) return 'DsShadow.none';
      return 'DsShadow([${layers.map((l) => l.dart).join(', ')}])';
    } on FormatException catch (e) {
      problems.add('shadow "$name" ($theme): ${e.message}');
      return 'DsShadow.none';
    }
  }

  String colorsFor(String theme) {
    final b = StringBuffer('DsColors(');
    contractColors.forEach((token, field) {
      b.write('$field: ${requireColor(token, theme)},');
    });
    for (final slot in contractFields) {
      final f = fieldNames[slot];
      if (f == null) {
        problems.add('system.json "fields" has no entry for "$slot"');
        continue;
      }
      final tint = color('tint-$f', theme);
      b.write(
        '$slot: DsFieldColors('
        'face: ${requireColor('obj-$f', theme)},'
        'end: ${requireColor('obj-$f-end', theme)},'
        'ink: ${requireColor('on-obj-$f', theme)},'
        'ink2: ${requireColor('on-obj-$f-2', theme)},'
        '${tint == null ? '' : 'tint: ${tint.dart},'}'
        'shadow: ${shadow('shadow-obj-$f', theme)},'
        '),',
      );
    }
    b.write(')');
    return b.toString();
  }

  String shadowsFor(String theme) {
    final b = StringBuffer('DsShadows(');
    contractShadows.forEach((token, field) {
      b.write('$field: ${shadow(token, theme)},');
    });
    b.write(')');
    return b.toString();
  }

  // ---- Type.
  final styles = <String, (String, Map<String, Object?>)>{};
  final typeGroups = (tokens['type'] as Map?)?['groups'] as List? ?? const [];
  for (final g in typeGroups.whereType<Map<String, Object?>>()) {
    final family = g['family'] as String? ?? 'sans';
    for (final s
        in (g['styles'] as List? ?? const [])
            .whereType<Map<String, Object?>>()) {
      styles[s['name'] as String] = (family, s);
    }
  }
  String typeSpec(String name) {
    final entry = styles[name];
    if (entry == null) {
      problems.add('type style "$name" is missing');
      return 'DsTypeSpec(role: DsFontRole.sans, size: 0, lineHeight: 0, '
          'weight: 400)';
    }
    final (family, s) = entry;
    final role = switch (family) {
      'display' => 'display',
      'rounded' => 'rounded',
      _ => 'sans',
    };
    final size = parseLength(s['fontSize']);
    final lh = parseLength(s['lineHeight']);
    final weight = switch (s['fontWeight']) {
      final num n => n.toDouble(),
      final String w => double.tryParse(w.split(' ').first),
      _ => 400.0,
    };
    if (size == null || lh == null || weight == null) {
      problems.add('type style "$name" needs fontSize, lineHeight, fontWeight');
      return 'DsTypeSpec(role: DsFontRole.sans, size: 0, lineHeight: 0, '
          'weight: 400)';
    }
    // A unitless lineHeight is a multiple of the size.
    final lineHeight =
        (s['lineHeight'] is num ||
            (s['lineHeight'] is String &&
                double.tryParse(s['lineHeight']! as String) != null))
        ? lh * size
        : lh;
    final tracking = parseLength(s['letterSpacing']) ?? 0;
    final opsz = parseLength(s['opticalSize']);
    return 'DsTypeSpec('
        'role: DsFontRole.$role,'
        'size: ${_dartNum(size)},'
        'lineHeight: ${_dartNum(lineHeight)},'
        'weight: ${_dartNum(weight)},'
        '${tracking == 0 ? '' : 'tracking: ${_dartNum(tracking)},'}'
        '${opsz == null ? '' : 'opticalSize: ${_dartNum(opsz)},'}'
        '${role == 'sans' ? '' : 'tabular: true,'}'
        ')';
  }

  String camel(String name) =>
      name.replaceAllMapped(RegExp(r'-(\w)'), (m) => m.group(1)!.toUpperCase());

  // ---- Plain number families.
  String numbers(
    String familyKey,
    Map<String, String> contract,
    String dartClass,
  ) {
    final values = {
      for (final e in family(familyKey)) e['name'] as String: e['value'],
    };
    final b = StringBuffer('$dartClass(');
    contract.forEach((token, field) {
      final v = parseLength(values[token]);
      if (v == null) {
        problems.add('$familyKey "$token" is missing or not a number');
      }
      b.write('$field: ${_dartNum(v ?? 0)},');
    });
    b.write(')');
    return b.toString();
  }

  final type = StringBuffer('DsTypeScale(');
  for (final name in contractType) {
    type.write('${camel(name)}: ${typeSpec(name)},');
  }
  type.write(')');

  final name = tokens['name'] as String? ?? dartName;
  final body =
      '''
// GENERATED by tool/gen_tokens.dart from $source. Do not edit:
// change the tokens.json, then run `dart run tool/gen_tokens.dart`.

import 'package:flutter/painting.dart';

import '../../foundation/ds_colors.dart';
import '../../foundation/ds_metrics.dart';
import '../../foundation/ds_shadows.dart';
import '../../foundation/ds_system.dart';
import '../../foundation/ds_type.dart';

const ${dartName}Tokens = DsTokenSet(
  name: '$name',
  colorsLight: ${colorsFor('light')},
  colorsDark: ${colorsFor('dark')},
  shadowsLight: ${shadowsFor('light')},
  shadowsDark: ${shadowsFor('dark')},
  type: $type,
  spacing: ${numbers('spacing', contractSpacing, 'DsSpacing')},
  radii: ${numbers('radius', contractRadii, 'DsRadii')},
  sizes: ${numbers('size', contractSizes, 'DsSizes')},
  opacity: ${numbers('opacity', contractOpacity, 'DsOpacities')},
);
''';
  if (problems.isNotEmpty) throw TokensException(problems);
  return body;
}
