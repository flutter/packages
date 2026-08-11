// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Evals structure consistency', () {
    test('all evals.json files across skills share consistent expected keys', () {
      final String packageRoot = _getPackageRoot();

      final List<File> evalsFiles = [
        ..._findEvalsFiles(Directory(p.join(packageRoot, '.agents', 'skills'))),
        ..._findEvalsFiles(Directory(p.join(packageRoot, 'evals'))),
      ]..sort((a, b) => a.path.compareTo(b.path));

      expect(
        evalsFiles,
        isNotEmpty,
        reason: 'Should find at least one evals.json file in .agents/skills or evals.',
      );

      _verifyStructuralConsistency(evalsFiles, 'evals');
    });

    test('all rubric JSON files in evals/ share consistent structure and keys', () {
      final String packageRoot = _getPackageRoot();

      final rubricsDir = Directory(p.join(packageRoot, 'evals'));
      expect(
        rubricsDir.existsSync(),
        isTrue,
        reason: 'evals/ directory must exist at $packageRoot/evals',
      );

      final List<File> rubricFiles =
          rubricsDir
              .listSync()
              .whereType<File>()
              .where((File f) => f.path.endsWith('.json') && !f.path.endsWith('_evals.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      expect(
        rubricFiles,
        isNotEmpty,
        reason: 'Should find at least one rubric JSON file in evals/.',
      );

      _verifyStructuralConsistency(rubricFiles, 'evals');
    });
  });
}

void _verifyStructuralConsistency(List<File> files, String itemsKey) {
  Set<String>? expectedRootKeys;
  String? expectedRootKeysFilePath;
  Set<String>? expectedItemKeys;
  String? expectedItemFilePath;

  for (final file in files) {
    final Object? decoded = jsonDecode(file.readAsStringSync());
    final Map<String, dynamic> decodedMap = switch (decoded) {
      final Map<String, dynamic> map => map,
      _ => fail('${file.path} must be a JSON map.'),
    };
    final Set<String> rootKeys = decodedMap.keys.toSet();
    if (expectedRootKeys == null) {
      expectedRootKeys = rootKeys;
      expectedRootKeysFilePath = file.path;
    } else {
      expect(
        rootKeys,
        equals(expectedRootKeys),
        reason:
            '${file.path} root keys do not match consistency pattern. '
            'Expected keys to match the first processed file ($expectedRootKeysFilePath).',
      );
    }

    final Object? itemsRaw = decodedMap[itemsKey];
    final List<dynamic> itemsList = switch (itemsRaw) {
      final List<dynamic> list => list,
      _ => fail('$itemsKey key in ${file.path} must be a List.'),
    };
    for (final Object? item in itemsList) {
      final Map<String, dynamic> itemMap = switch (item) {
        final Map<String, dynamic> map => map,
        _ => fail('Item in $itemsKey list in ${file.path} must be a JSON map.'),
      };
      final Set<String> itemKeys = itemMap.keys.toSet();
      if (expectedItemKeys == null) {
        expectedItemKeys = itemKeys;
        expectedItemFilePath = file.path;
      } else {
        expect(
          itemKeys,
          equals(expectedItemKeys),
          reason:
              'Item in ${file.path} keys do not match consistency pattern. '
              'Expected item keys to match the first processed file ($expectedItemFilePath).',
        );
      }
    }
  }
}

List<File> _findEvalsFiles(Directory baseDir) {
  if (!baseDir.existsSync()) {
    return [];
  }
  return baseDir.listSync(recursive: true).whereType<File>().where((File f) {
    final String name = p.basename(f.path);
    return name == 'evals.json' || name.endsWith('_evals.json');
  }).toList();
}

String _getPackageRoot() {
  String packageRoot = Directory.current.path;
  if (!File(p.join(packageRoot, 'pubspec.yaml')).existsSync()) {
    final String candidate = p.join(packageRoot, 'packages', 'camera', 'camera_android_camerax');
    if (Directory(candidate).existsSync()) {
      packageRoot = candidate;
    }
  }
  return packageRoot;
}
