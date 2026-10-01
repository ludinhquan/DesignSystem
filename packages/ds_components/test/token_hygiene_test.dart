import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Cheap guard rails until a custom lint exists: components must use tokens
/// only and must stay on `package:material_ui`.
void main() {
  final rules = <String, RegExp>{
    'imports package:flutter/material.dart (use package:material_ui)': RegExp(
      r'''package:flutter/(material|cupertino)\.dart''',
    ),
    'reads primitive tokens (use semantic/component tokens)': RegExp(
      r'package:ds_tokens/primitives\.dart|\bPrimitive[A-Z]\w*',
    ),
    'uses a raw colour (use context.colors)': RegExp(
      r'\bColor\(0x|\bColor\.from(ARGB|RGBO)\(|\bColors\.',
    ),
    'builds a TextStyle by hand (use context.typography)': RegExp(
      r'\bTextStyle\(',
    ),
    'uses a raw number for a dimension (use a token)': RegExp(
      r'\b(width|height|size|dimension|fontSize|strokeWidth|elevation|'
      r'spacing|runSpacing)\s*:\s*-?\d|'
      r'EdgeInsets(Directional)?\.\w+\(\s*(\w+\s*:\s*)?-?\d|'
      r'(Radius|BorderRadius)\.circular\(\s*\d',
    ),
  };

  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    test('${file.path} uses tokens only', () {
      final violations = <String>[];
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        for (final rule in rules.entries) {
          if (rule.value.hasMatch(line)) {
            violations.add('  line ${i + 1}: ${rule.key}\n    $line');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  }
}
