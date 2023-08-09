// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:go_router_builder/src/go_router_generator.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

const GoRouterGenerator generator = GoRouterGenerator();

Future<void> main() async {
  final dart_style.DartFormatter formatter = dart_style.DartFormatter();
  final Directory dir = Directory('test_inputs');
  final List<File> testFiles = dir
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();
  for (final File file in testFiles) {
    final String fileName = file.path.split('/').last;
    final File expectFile = File(p.join('${file.path}.expect'));
    if (!expectFile.existsSync()) {
      throw Exception('A text input must have a .expect file. '
          'Found test input $fileName with out an expect file.');
    }
    final String expectResult = expectFile.readAsStringSync().trim();
    test('verify $fileName', () async {
      final String targetLibraryAssetId = '__test__|${file.path}';
      final LibraryElement element = await resolveSources<LibraryElement>(
        <String, String>{
          targetLibraryAssetId: file.readAsStringSync(),
        },
        (Resolver resolver) async {
          final AssetId assetId = AssetId.parse(targetLibraryAssetId);
          return resolver.libraryFor(assetId);
        },
      );
      final LibraryReader reader = LibraryReader(element);
      final Set<String> results = <String>{};
      try {
        generator.generateForAnnotation(reader, results, <String>{});
      } on InvalidGenerationSourceError catch (e) {
        expect(expectResult, e.message.trim());
        return;
      }

      final String generated = formatter
          .format(results.join('\n\n'))
          .trim()
          .replaceAll('\r\n', '\n');
      expect(generated, equals(expectResult.replaceAll('\r\n', '\n')));
    }, timeout: const Timeout(Duration(seconds: 100)));
  }
}
