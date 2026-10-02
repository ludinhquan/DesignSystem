// Generates lib/src/systems/<name>/<name>_tokens.g.dart for every
// systems/<name>/ folder holding a tokens.json (Design System artifact
// format) and a system.json ({"fields": {"yellow": "marigold", ...}}).
//
//   dart run tool/gen_tokens.dart          # regenerate
//   dart run tool/gen_tokens.dart --check  # CI: fail if anything is stale
//
// Run from packages/ds.

import 'dart:convert';
import 'dart:io';

import 'src/tokens_codegen.dart';

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  final systems =
      Directory('systems')
          .listSync()
          .whereType<Directory>()
          .where((d) => File('${d.path}/tokens.json').existsSync())
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (systems.isEmpty) {
    stderr.writeln(
      'No systems/<name>/tokens.json found. Run from packages/ds.',
    );
    exit(2);
  }

  var stale = false;
  for (final dir in systems) {
    final dartName = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final tokens = jsonDecode(
      File('${dir.path}/tokens.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final config = jsonDecode(
      File('${dir.path}/system.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final fields = (config['fields'] as Map).cast<String, String>();

    final String source;
    try {
      source = generate(
        tokens: tokens,
        dartName: dartName,
        fieldNames: fields,
        source: 'systems/$dartName/tokens.json',
      );
    } on TokensException catch (e) {
      stderr.writeln('$dartName: $e');
      exit(1);
    }

    final out = File('lib/src/systems/$dartName/${dartName}_tokens.g.dart');
    final formatted = await _format(source);
    if (check) {
      if (!out.existsSync() || out.readAsStringSync() != formatted) {
        stderr.writeln(
          '${out.path} is stale. Run dart run tool/gen_tokens.dart',
        );
        stale = true;
      }
    } else {
      out
        ..createSync(recursive: true)
        ..writeAsStringSync(formatted);
      stdout.writeln('Wrote ${out.path}');
    }
  }
  if (stale) exit(1);
}

/// Formats with `dart format` so the output matches the repo's style.
Future<String> _format(String source) async {
  final tmp = await Directory.systemTemp.createTemp('gen_tokens');
  try {
    // The language version is explicit: the temp dir has no package config.
    final file = File('${tmp.path}/out.dart')..writeAsStringSync(source);
    final result = await Process.run(Platform.resolvedExecutable, [
      'format',
      '--language-version=3.13',
      file.path,
    ]);
    if (result.exitCode != 0) {
      throw StateError('dart format failed: ${result.stderr}');
    }
    return file.readAsStringSync();
  } finally {
    await tmp.delete(recursive: true);
  }
}
