// Design token generator: tokens/*.json (W3C DTCG) -> packages/ds_tokens.
//
// Usage (from the repository root):
//   dart run tool/gen_tokens.dart          # regenerate
//   dart run tool/gen_tokens.dart --check  # CI: exit 1 if output is stale
//
// Pure Dart, no Node / Style Dictionary required.
//
// Input conventions
// -----------------
// * `tokens/primitives.json`      -> `abstract final class Primitive<Group>`
//                                    with `static const` members.
// * `tokens/<name>.json`          -> `abstract final class <Group>Tokens`
//                                    with `static const` members.
// * `tokens/<name>.<mode>.json`   -> files sharing `<name>` form a *mode set*
//                                    (e.g. light/dark). Each top-level group
//                                    becomes `final class <Group>Tokens` with
//                                    one `static const` instance per mode.
//                                    Every mode must define the same tokens.
//
// Supported `$type`s: color, dimension, number, fontWeight, duration,
// typography (fontSize, fontWeight, lineHeight, letterSpacing, fontFamily).
// `$type` is inherited from parent groups. Values may be aliases such as
// `{color.blue.500}`; aliases to static tokens are emitted as references to
// the generated constant so the tier chain stays visible in the Dart code.

import 'dart:convert';
import 'dart:io';

const String tokensDir = 'tokens';

/// Generated constants (depends on package:flutter/widgets.dart only).
const String outDir = 'packages/ds_tokens/lib/src';

/// Generated ThemeExtensions for themed (mode-set) token groups.
const String foundationOutDir = 'packages/ds_foundation/lib/src/generated';

/// Must match the Material import used everywhere else in the repo
/// (see README "Material dependency").
const String materialImport = 'package:material_ui/material_ui.dart';

const String barrelFile = 'tokens.g.dart';
const String generatedHeader = '// GENERATED – do not edit.';
const List<String> outputDirs = [outDir, foundationOutDir];

Future<void> main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    stdout.writeln(
      'Usage: dart run tool/gen_tokens.dart [--check]\n\n'
      'Regenerates ${outputDirs.join(' and ')} from $tokensDir/*.json.\n'
      '  --check  Do not write; exit 1 if the generated files are stale.',
    );
    return;
  }
  final unknown = args.where((a) => a != '--check').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('Unknown arguments: ${unknown.join(' ')}');
    exit(64);
  }
  final check = args.contains('--check');

  if (!Directory(tokensDir).existsSync()) {
    stderr.writeln(
      'Run this from the repository root ($tokensDir/ not found).',
    );
    exit(66);
  }

  // Keys are repository-relative paths.
  final Map<String, String> generated;
  try {
    generated = await _format(Generator.fromDirectory(tokensDir).generate());
  } on TokenException catch (e) {
    stderr.writeln('Token error: ${e.message}');
    exit(65);
  }

  final existing = <String, String>{
    for (final dir in outputDirs)
      if (Directory(dir).existsSync())
        for (final f in Directory(dir).listSync().whereType<File>())
          if (f.path.endsWith('.g.dart'))
            '$dir/${_basename(f.path)}': f.readAsStringSync(),
  };

  final stale = <String>[
    for (final e in generated.entries)
      if (existing[e.key] != e.value) e.key,
    for (final path in existing.keys)
      if (!generated.containsKey(path)) path,
  ]..sort();

  if (check) {
    if (stale.isEmpty) {
      stdout.writeln(
        'Design tokens are up to date (${generated.length} files).',
      );
      return;
    }
    stderr.writeln(
      'Generated design tokens are stale:\n'
      '${stale.map((s) => '  $s').join('\n')}\n'
      'Run `dart run tool/gen_tokens.dart` and commit the result.',
    );
    exit(1);
  }

  for (final e in generated.entries) {
    File(e.key)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(e.value);
  }
  for (final path in existing.keys) {
    if (!generated.containsKey(path)) File(path).deleteSync();
  }
  stdout.writeln(
    stale.isEmpty
        ? 'Design tokens already up to date.'
        : 'Wrote ${stale.length} file(s):\n${stale.map((s) => '  $s').join('\n')}',
  );
}

/// Runs `dart format` over the generated sources so that the output is
/// byte-identical to what `dart format .` would produce in the repo.
Future<Map<String, String>> _format(Map<String, String> sources) async {
  final tmp = Directory('.dart_tool/gen_tokens');
  if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  tmp.createSync(recursive: true);
  final tmpPathFor = <String, String>{};
  var i = 0;
  for (final e in sources.entries) {
    final path = '${tmp.path}/${i++}_${_basename(e.key)}';
    File(path).writeAsStringSync(e.value);
    tmpPathFor[e.key] = path;
  }
  final result = await Process.run(Platform.resolvedExecutable, [
    'format',
    '--output=write',
    ...tmpPathFor.values,
  ]);
  if (result.exitCode != 0) {
    throw TokenException(
      'dart format failed on generated code:\n${result.stdout}${result.stderr}',
    );
  }
  final formatted = {
    for (final e in tmpPathFor.entries) e.key: File(e.value).readAsStringSync(),
  };
  tmp.deleteSync(recursive: true);
  return formatted;
}

String _basename(String path) => path.split(RegExp(r'[/\\]')).last;

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class TokenException implements Exception {
  TokenException(this.message);
  final String message;
}

/// A single DTCG token (an object with a `$value`).
class Token {
  Token({
    required this.segments,
    required this.declaredType,
    required this.value,
    required this.description,
    required this.file,
    required this.mode,
  });

  final List<String> segments;
  final String? declaredType;
  final Object? value;
  final String? description;
  final String file;

  /// `null` for static tokens, otherwise the mode name (e.g. `light`).
  final String? mode;

  String get path => segments.join('.');
  String get group => segments.first;
  bool get isStatic => mode == null;
}

/// A generated Dart file.
class Output {
  Output({
    required this.fileName,
    required this.sources,
    required this.classPrefix,
    required this.classSuffix,
    this.modes = const [],
  });

  final String fileName;
  final List<String> sources;
  final String classPrefix;
  final String classSuffix;

  /// Non-empty for mode sets (themed tokens).
  final List<String> modes;

  /// Tokens per mode (`''` key for static outputs), in source order.
  final Map<String, List<Token>> tokens = {};

  bool get isModeSet => modes.isNotEmpty;

  String className(String group) =>
      '$classPrefix${_pascal(_words(group))}$classSuffix';
}

// ---------------------------------------------------------------------------
// Generator
// ---------------------------------------------------------------------------

class Generator {
  Generator(this.outputs) {
    for (final out in outputs) {
      for (final list in out.tokens.values) {
        for (final t in list) {
          if (t.isStatic) {
            final dup = _static[t.path];
            if (dup != null) {
              throw TokenException(
                '`${t.path}` is defined in both ${dup.file} and ${t.file}.',
              );
            }
            _static[t.path] = t;
          } else {
            (_themed[t.mode!] ??= {})[t.path] = t;
          }
          _ownerOf[t] = out;
        }
      }
    }
    for (final modeTokens in _themed.values) {
      for (final path in modeTokens.keys) {
        if (_static.containsKey(path)) {
          throw TokenException(
            '`$path` is defined both as a static and as a themed token.',
          );
        }
      }
    }
    final classNames = <String, String>{};
    for (final out in outputs) {
      final groups = {
        for (final list in out.tokens.values) ...list.map((t) => t.group),
      };
      for (final g in groups) {
        final name = out.className(g);
        final other = classNames[name];
        if (other != null && other != out.fileName) {
          throw TokenException(
            'Class `$name` would be generated by both $other and '
            '${out.fileName}. Rename one of the `$g` groups.',
          );
        }
        classNames[name] = out.fileName;
      }
    }
  }

  factory Generator.fromDirectory(String dir) {
    final files =
        Directory(dir)
            .listSync()
            .whereType<File>()
            .map((f) => _basename(f.path))
            .where((n) => n.endsWith('.json'))
            .toList()
          ..sort();
    if (files.isEmpty) throw TokenException('No *.json files in $dir/.');

    final outputs = <Output>[];
    final modeSets = <String, Map<String, String>>{};
    for (final file in files) {
      final parts = file.substring(0, file.length - '.json'.length).split('.');
      if (parts.length == 1) {
        final name = parts.single;
        final isPrimitive = name == 'primitives';
        outputs.add(
          Output(
            fileName: '${_snake(name)}.g.dart',
            sources: [file],
            classPrefix: isPrimitive ? 'Primitive' : '',
            classSuffix: isPrimitive ? '' : 'Tokens',
          ),
        );
      } else if (parts.length == 2) {
        (modeSets[parts[0]] ??= {})[parts[1]] = file;
      } else {
        throw TokenException(
          'Unsupported file name `$file`; use <name>.json or <name>.<mode>.json.',
        );
      }
    }
    for (final e in modeSets.entries) {
      // `light` first, then the remaining modes alphabetically.
      final modes = e.value.keys.toList()
        ..sort((a, b) {
          if (a == b) return 0;
          if (a == 'light') return -1;
          if (b == 'light') return 1;
          return a.compareTo(b);
        });
      outputs.add(
        Output(
          fileName: '${_snake(e.key)}_modes.g.dart',
          sources: [for (final m in modes) e.value[m]!],
          classPrefix: '',
          classSuffix: 'Tokens',
          modes: modes,
        ),
      );
    }

    for (final out in outputs) {
      if (out.isModeSet) {
        for (final mode in out.modes) {
          final file = out.sources[out.modes.indexOf(mode)];
          out.tokens[mode] = _parseFile('$dir/$file', file, mode);
        }
        _checkModesMatch(out);
      } else {
        final file = out.sources.single;
        out.tokens[''] = _parseFile('$dir/$file', file, null);
      }
    }
    return Generator(outputs);
  }

  final List<Output> outputs;
  final Map<String, Token> _static = {};
  final Map<String, Map<String, Token>> _themed = {};
  final Map<Token, Output> _ownerOf = {};

  /// Returns `{fileName: unformatted source}`.
  Map<String, String> generate() {
    final result = <String, String>{};
    for (final out in outputs) {
      result['$outDir/${out.fileName}'] = _emitOutput(out);
      if (out.isModeSet) {
        for (final group in _groupsOf(out.tokens[out.modes.first]!)) {
          final ext = _extensionName(group);
          result['$foundationOutDir/${_snake(ext)}.g.dart'] =
              _emitThemeExtension(out, group);
        }
      }
    }
    // The barrel deliberately omits primitives: widgets must consume the
    // semantic/component tiers. Primitives live behind
    // `package:ds_tokens/primitives.dart` for tooling and theme builders.
    result['$outDir/$barrelFile'] = [
      generatedHeader,
      '// Semantic and component tiers. Primitives are intentionally excluded.',
      '// Regenerate with: dart run tool/gen_tokens.dart',
      '',
      for (final out in outputs)
        if (out.isModeSet || !out.sources.single.startsWith('primitive'))
          "export '${out.fileName}';",
      '',
    ].join('\n');
    return result;
  }

  // -- Emission --------------------------------------------------------------

  String _emitOutput(Output out) {
    final deps = <String>{};
    var needsWidgets = false;
    final body = StringBuffer();

    void trackType(String dartType) {
      if (dartType != 'double') needsWidgets = true;
    }

    if (!out.isModeSet) {
      final tokens = out.tokens['']!;
      for (final group in _groupsOf(tokens)) {
        final members = tokens.where((t) => t.group == group).toList();
        final cls = out.className(group);
        final source = out.sources.single;
        final tierName = source.startsWith('primitive')
            ? 'Primitive (tier 1)'
            : source.startsWith('component')
            ? 'Component (tier 3)'
            : 'Semantic (tier 2)';
        body
          ..writeln('/// $tierName `$group` tokens from `$tokensDir/$source`.')
          ..writeln('abstract final class $cls {');
        for (final t in members) {
          final type = _dartType(_typeOf(t, null));
          trackType(type);
          final expr = _expr(t, null, deps, {});
          _writeDoc(body, t, '  ');
          body.writeln('  static const $type ${_memberName(t)} = $expr;');
          body.writeln();
        }
        body.writeln('}');
        body.writeln();
      }
    } else {
      final first = out.tokens[out.modes.first]!;
      for (final group in _groupsOf(first)) {
        final cls = out.className(group);
        final members = first.where((t) => t.group == group).toList();
        final modeList = out.modes.map((m) => '[$m]').join(', ');
        body
          ..writeln(
            '/// Semantic (tier 2) themed `$group` tokens. One instance per '
            'mode: $modeList.',
          )
          ..writeln('///')
          ..writeln(
            '/// Source: ${out.sources.map((s) => '`$tokensDir/$s`').join(', ')}.',
          )
          ..writeln('final class $cls {')
          ..writeln('  /// Creates a set of `$group` tokens.')
          ..writeln('  const $cls({');
        for (final t in members) {
          body.writeln('    required this.${_memberName(t)},');
        }
        body
          ..writeln('  });')
          ..writeln();
        for (final mode in out.modes) {
          final modeTokens = out.tokens[mode]!;
          body
            ..writeln('  /// `$mode` mode values.')
            ..writeln('  static const $cls $mode = $cls(');
          for (final t in members) {
            final mt = modeTokens.firstWhere((x) => x.path == t.path);
            final expr = _expr(mt, mode, deps, {});
            body.writeln('    ${_memberName(t)}: $expr,');
          }
          body
            ..writeln('  );')
            ..writeln();
        }
        body
          ..writeln('  /// All modes, keyed by name.')
          ..writeln('  static const Map<String, $cls> modes = {');
        for (final mode in out.modes) {
          body.writeln("    '$mode': $mode,");
        }
        body
          ..writeln('  };')
          ..writeln();
        for (final t in members) {
          final type = _dartType(_typeOf(t, t.mode));
          trackType(type);
          for (final mode in out.modes.skip(1)) {
            final other = out.tokens[mode]!.firstWhere((x) => x.path == t.path);
            final otherType = _dartType(_typeOf(other, mode));
            if (otherType != type) {
              throw TokenException(
                '`${t.path}` has type $type in ${out.modes.first} but '
                '$otherType in $mode.',
              );
            }
          }
          _writeDoc(body, t, '  ');
          body.writeln('  final $type ${_memberName(t)};');
          body.writeln();
        }
        body.writeln('}');
        body.writeln();
      }
    }

    deps.remove(out.fileName);
    final header = StringBuffer()
      ..writeln(generatedHeader)
      ..writeln(
        '// Source: ${out.sources.map((s) => '$tokensDir/$s').join(', ')}',
      )
      ..writeln('// Regenerate with: dart run tool/gen_tokens.dart')
      ..writeln();
    final imports = [
      if (needsWidgets) "import 'package:flutter/widgets.dart';",
      for (final d in deps.toList()..sort()) "import '$d';",
    ];
    if (imports.isNotEmpty) {
      header
        ..writeln(imports.join('\n'))
        ..writeln();
    }
    return '$header$body';
  }

  /// `color` -> `AppColors`.
  static String _extensionName(String group) => 'App${_pascal(_words(group))}s';

  /// Emits a [ThemeExtension] mirroring a themed token group, so that adding
  /// a token to `<name>.<mode>.json` needs no hand-written code.
  String _emitThemeExtension(Output out, String group) {
    final cls = _extensionName(group);
    final tokenCls = out.className(group);
    final members = [
      for (final t in out.tokens[out.modes.first]!)
        if (t.group == group) t,
    ];
    final types = {for (final t in members) t: _dartType(_typeOf(t, t.mode))};
    final needsLerpDouble = types.values.contains('double');

    String lerpExpr(String type, String name) => switch (type) {
      'Color' => 'Color.lerp($name, other.$name, t)!',
      'double' => 'lerpDouble($name, other.$name, t)!',
      'TextStyle' => 'TextStyle.lerp($name, other.$name, t)!',
      'FontWeight' => 'FontWeight.lerp($name, other.$name, t)!',
      _ => 't < 0.5 ? $name : other.$name',
    };

    final sb = StringBuffer()
      ..writeln(generatedHeader)
      ..writeln(
        '// Source: ${out.sources.map((s) => '$tokensDir/$s').join(', ')}',
      )
      ..writeln('// Regenerate with: dart run tool/gen_tokens.dart')
      ..writeln()
      ..writeln(needsLerpDouble ? "import 'dart:ui' show lerpDouble;\n" : '')
      ..writeln("import 'package:ds_tokens/ds_tokens.dart';")
      ..writeln("import '$materialImport';")
      ..writeln()
      ..writeln('/// Themed `$group` tokens exposed as a [ThemeExtension].')
      ..writeln('///')
      ..writeln(
        '/// Read it with `context.${_camel(_words(group))}s` (see '
        '`context_extensions.dart`).',
      )
      ..writeln('/// Built from [$tokenCls]; supports [copyWith] and [lerp]')
      ..writeln('/// so theme switches animate.')
      ..writeln('@immutable')
      ..writeln('class $cls extends ThemeExtension<$cls> {')
      ..writeln('  /// Creates a `$group` theme extension.')
      ..writeln('  const $cls({');
    for (final t in members) {
      sb.writeln('    required this.${_memberName(t)},');
    }
    sb
      ..writeln('  });')
      ..writeln()
      ..writeln(
        '  /// Creates the extension from a generated [$tokenCls] mode.',
      )
      ..writeln('  $cls.fromTokens($tokenCls tokens)')
      ..write('    : ');
    sb.writeln(
      [for (final t in members) '${_memberName(t)} = tokens.${_memberName(t)}']
          .join(',\n      '),
    );
    sb.writeln('  ;');
    sb.writeln();
    for (final mode in out.modes) {
      sb
        ..writeln('  /// `$mode` mode.')
        ..writeln(
          '  static final $cls $mode = $cls.fromTokens($tokenCls.$mode);',
        )
        ..writeln();
    }
    for (final t in members) {
      _writeDoc(sb, t, '  ');
      sb.writeln('  final ${types[t]} ${_memberName(t)};');
      sb.writeln();
    }
    sb
      ..writeln('  @override')
      ..writeln('  $cls copyWith({');
    for (final t in members) {
      sb.writeln('    ${types[t]}? ${_memberName(t)},');
    }
    sb
      ..writeln('  }) {')
      ..writeln('    return $cls(');
    for (final t in members) {
      final n = _memberName(t);
      sb.writeln('      $n: $n ?? this.$n,');
    }
    sb
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
        '  $cls lerp(covariant ThemeExtension<$cls>? other, double t) {',
      )
      ..writeln('    if (other is! $cls) return this;')
      ..writeln('    return $cls(');
    for (final t in members) {
      final n = _memberName(t);
      sb.writeln('      $n: ${lerpExpr(types[t]!, n)},');
    }
    sb
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');
    return sb.toString();
  }

  void _writeDoc(StringBuffer sb, Token t, String indent) {
    sb.writeln('$indent/// `${t.path}`');
    final d = t.description;
    if (d != null && d.isNotEmpty) {
      sb
        ..writeln('$indent///')
        ..writeln('$indent/// $d');
    }
  }

  /// Top-level groups in source order (set literals preserve insertion order).
  Iterable<String> _groupsOf(List<Token> tokens) => {
    for (final t in tokens) t.group,
  };

  // -- Resolution -------------------------------------------------------------

  Token? _lookup(String path, String? mode) =>
      _static[path] ?? (mode == null ? null : _themed[mode]?[path]);

  Token _resolveAlias(String path, Token from, String? mode) {
    final target = _lookup(path, mode);
    if (target == null) {
      final themedSomewhere = _themed.values.any((m) => m.containsKey(path));
      throw TokenException(
        themedSomewhere && mode == null
            ? '`${from.path}` (${from.file}) is static but aliases the themed '
                  'token `{$path}`. Move it into a <name>.<mode>.json file.'
            : '`${from.path}` (${from.file}) references unknown token `{$path}`.',
      );
    }
    return target;
  }

  String _typeOf(Token t, String? mode, [Set<String>? visiting]) {
    if (t.declaredType != null) return t.declaredType!;
    final alias = _aliasPath(t.value);
    if (alias == null) {
      throw TokenException('`${t.path}` (${t.file}) has no \$type.');
    }
    visiting ??= {};
    if (!visiting.add(t.path)) {
      throw TokenException('Alias cycle involving `${t.path}`.');
    }
    return _typeOf(_resolveAlias(alias, t, mode), mode, visiting);
  }

  /// Dart expression for [t]'s value in [mode].
  String _expr(Token t, String? mode, Set<String> deps, Set<String> visiting) {
    if (!visiting.add(t.path)) {
      throw TokenException(
        'Alias cycle: ${[...visiting, t.path].join(' -> ')}',
      );
    }
    final type = _typeOf(t, mode);
    return _valueExpr(t.value, type, t, mode, deps, visiting);
  }

  String _valueExpr(
    Object? value,
    String type,
    Token t,
    String? mode,
    Set<String> deps,
    Set<String> visiting,
  ) {
    final alias = _aliasPath(value);
    if (alias != null) {
      final target = _resolveAlias(alias, t, mode);
      final targetType = _typeOf(target, mode);
      if (targetType != type) {
        throw TokenException(
          '`${t.path}` expects $type but `{$alias}` is $targetType.',
        );
      }
      if (target.isStatic) {
        final owner = _ownerOf[target]!;
        deps.add(owner.fileName);
        return '${owner.className(target.group)}.${_memberName(target)}';
      }
      if (t.isStatic) {
        throw TokenException(
          '`${t.path}` is static but aliases the themed token `{$alias}`.',
        );
      }
      return _expr(target, mode, deps, {...visiting});
    }
    String where() => '`${t.path}` (${t.file})';
    switch (type) {
      case 'color':
        return _colorExpr(value, where);
      case 'dimension':
        return _num(_dimension(value, where));
      case 'number':
        if (value is num) return _num(value);
        throw TokenException('${where()}: number expected, got $value.');
      case 'fontWeight':
        return 'FontWeight.w${_fontWeight(value, where)}';
      case 'duration':
        return 'Duration(milliseconds: ${_durationMs(value, where)})';
      case 'typography':
        if (value is! Map) {
          throw TokenException('${where()}: typography must be an object.');
        }
        const fields = {
          'fontFamily': ('fontFamily', 'fontFamily'),
          'fontSize': ('fontSize', 'dimension'),
          'fontWeight': ('fontWeight', 'fontWeight'),
          'lineHeight': ('height', 'number'),
          'letterSpacing': ('letterSpacing', 'dimension'),
        };
        final args = <String>[];
        for (final key in value.keys) {
          final spec = fields[key];
          if (spec == null) {
            throw TokenException(
              '${where()}: unsupported typography field `$key`.',
            );
          }
          final sub = value[key];
          if (spec.$2 == 'fontFamily') {
            final family = sub is List ? sub.first : sub;
            args.add("${spec.$1}: '$family'");
          } else {
            args.add(
              '${spec.$1}: ${_valueExpr(sub, spec.$2, t, mode, deps, visiting)}',
            );
          }
        }
        return 'TextStyle(${args.join(', ')})';
      default:
        throw TokenException('${where()}: unsupported \$type `$type`.');
    }
  }

  // -- Parsing -----------------------------------------------------------------

  static List<Token> _parseFile(String path, String file, String? mode) {
    final Object? json;
    try {
      json = jsonDecode(File(path).readAsStringSync());
    } on FormatException catch (e) {
      throw TokenException('$file is not valid JSON: ${e.message}');
    }
    if (json is! Map<String, Object?>) {
      throw TokenException('$file must contain a JSON object.');
    }
    final tokens = <Token>[];
    void walk(Map<String, Object?> node, List<String> segs, String? type) {
      final groupType = node[r'$type'] as String? ?? type;
      if (node.containsKey(r'$value')) {
        if (segs.length < 2) {
          throw TokenException(
            '$file: token `${segs.join('.')}` must be inside a group.',
          );
        }
        tokens.add(
          Token(
            segments: segs,
            declaredType: groupType,
            value: node[r'$value'],
            description: node[r'$description'] as String?,
            file: file,
            mode: mode,
          ),
        );
        return;
      }
      for (final e in node.entries) {
        if (e.key.startsWith(r'$')) continue;
        final child = e.value;
        if (child is! Map<String, Object?>) {
          throw TokenException(
            '$file: `${[...segs, e.key].join('.')}` must be a group or token.',
          );
        }
        walk(child, [...segs, e.key], groupType);
      }
    }

    walk(json, const [], null);
    return tokens;
  }

  static void _checkModesMatch(Output out) {
    final reference = out.tokens[out.modes.first]!.map((t) => t.path).toSet();
    for (final mode in out.modes.skip(1)) {
      final paths = out.tokens[mode]!.map((t) => t.path).toSet();
      final missing = reference.difference(paths);
      final extra = paths.difference(reference);
      if (missing.isNotEmpty || extra.isNotEmpty) {
        throw TokenException(
          'Mode `$mode` does not match `${out.modes.first}`.'
          '${missing.isEmpty ? '' : ' Missing: ${missing.join(', ')}.'}'
          '${extra.isEmpty ? '' : ' Extra: ${extra.join(', ')}.'}',
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Value helpers
// ---------------------------------------------------------------------------

final RegExp _aliasRe = RegExp(r'^\{([^{}]+)\}$');

String? _aliasPath(Object? value) =>
    value is String ? _aliasRe.firstMatch(value.trim())?.group(1) : null;

String _colorExpr(Object? value, String Function() where) {
  int r, g, b;
  double a = 1;
  String? hex;
  if (value is String) {
    hex = value;
  } else if (value is Map) {
    final alpha = value['alpha'];
    if (alpha is num) a = alpha.toDouble();
    if (value['hex'] is String) {
      hex = value['hex'] as String;
    } else if (value['components'] is List && value['colorSpace'] == 'srgb') {
      final c = (value['components'] as List).cast<num>();
      hex =
          '#${c.map((v) => (v * 255).round().toRadixString(16).padLeft(2, '0')).join()}';
    }
  }
  if (hex == null) {
    throw TokenException('${where()}: unsupported color $value.');
  }
  var h = hex.replaceFirst('#', '');
  if (h.length == 3 || h.length == 4) {
    h = h.split('').map((c) => '$c$c').join();
  }
  if (h.length != 6 && h.length != 8) {
    throw TokenException('${where()}: invalid hex color `$hex`.');
  }
  r = int.parse(h.substring(0, 2), radix: 16);
  g = int.parse(h.substring(2, 4), radix: 16);
  b = int.parse(h.substring(4, 6), radix: 16);
  if (h.length == 8) a *= int.parse(h.substring(6, 8), radix: 16) / 255;
  final argb = ((a * 255).round() << 24) | (r << 16) | (g << 8) | b;
  return 'Color(0x${argb.toRadixString(16).toUpperCase().padLeft(8, '0')})';
}

num _dimension(Object? value, String Function() where) {
  num v;
  String unit;
  if (value is num) {
    return value;
  } else if (value is Map && value['value'] is num) {
    v = value['value'] as num;
    unit = value['unit'] as String? ?? 'px';
  } else if (value is String) {
    final m = RegExp(r'^(-?[\d.]+)\s*(px|rem)?$').firstMatch(value.trim());
    if (m == null) {
      throw TokenException('${where()}: invalid dimension $value.');
    }
    v = num.parse(m.group(1)!);
    unit = m.group(2) ?? 'px';
  } else {
    throw TokenException('${where()}: invalid dimension $value.');
  }
  return switch (unit) {
    'px' => v,
    'rem' => v * 16,
    _ => throw TokenException('${where()}: unsupported unit `$unit`.'),
  };
}

int _fontWeight(Object? value, String Function() where) {
  const names = {
    'thin': 100,
    'hairline': 100,
    'extra-light': 200,
    'ultra-light': 200,
    'light': 300,
    'normal': 400,
    'regular': 400,
    'book': 400,
    'medium': 500,
    'semi-bold': 600,
    'demi-bold': 600,
    'bold': 700,
    'extra-bold': 800,
    'ultra-bold': 800,
    'black': 900,
    'heavy': 900,
  };
  final w = value is num ? value.round() : names[value];
  if (w == null || w < 100 || w > 900 || w % 100 != 0) {
    throw TokenException(
      '${where()}: font weight must be 100..900 in steps of 100, got $value.',
    );
  }
  return w;
}

int _durationMs(Object? value, String Function() where) {
  if (value is Map && value['value'] is num) {
    final v = value['value'] as num;
    return (value['unit'] == 's' ? v * 1000 : v).round();
  }
  if (value is String) {
    final m = RegExp(r'^([\d.]+)\s*(ms|s)$').firstMatch(value.trim());
    if (m != null) {
      final v = num.parse(m.group(1)!);
      return (m.group(2) == 's' ? v * 1000 : v).round();
    }
  }
  throw TokenException('${where()}: invalid duration $value.');
}

String _dartType(String tokenType) => switch (tokenType) {
  'color' => 'Color',
  'dimension' || 'number' => 'double',
  'fontWeight' => 'FontWeight',
  'duration' => 'Duration',
  'typography' => 'TextStyle',
  _ => throw TokenException('Unsupported \$type `$tokenType`.'),
};

String _num(num v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

// ---------------------------------------------------------------------------
// Naming helpers
// ---------------------------------------------------------------------------

const Set<String> _reserved = {
  'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', //
  'class', 'const', 'continue', 'default', 'do', 'else', 'enum', 'extends',
  'false', 'final', 'finally', 'for', 'if', 'in', 'is', 'new', 'null', 'return',
  'super', 'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while',
  'with', 'yield', 'modes',
};

/// Member name: the token path without its top-level group, camelCased.
/// Paths that would start with a digit get the group name as prefix
/// (`space.4` -> `space4`).
String _memberName(Token t) {
  final words = [for (final s in t.segments.skip(1)) ..._words(s)];
  var name = _camel(words);
  if (name.isEmpty || RegExp(r'^\d').hasMatch(name)) {
    name = _camel([..._words(t.group), ...words]);
  }
  if (_reserved.contains(name)) {
    throw TokenException(
      '`${t.path}` (${t.file}) maps to the reserved name `$name`; rename it.',
    );
  }
  return name;
}

List<String> _words(String s) =>
    s.split(RegExp(r'[^A-Za-z0-9]+')).where((w) => w.isNotEmpty).toList();

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _camel(List<String> words) {
  if (words.isEmpty) return '';
  final first = words.first;
  return first[0].toLowerCase() + first.substring(1) + _pascal(words.skip(1));
}

String _pascal(Iterable<String> words) => words.map(_cap).join();

String _snake(String s) => s
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
    .toLowerCase();
