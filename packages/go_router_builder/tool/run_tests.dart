// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:go_router_builder/src/duplicate_path_severity.dart';
import 'package:go_router_builder/src/go_router_generator.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final formatter = dart_style.DartFormatter(languageVersion: await _packageVersion());
  final dir = Directory('test_inputs');
  final List<File> testFiles = dir
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();
  for (final file in testFiles) {
    final String fileName = file.path.split('/').last;
    final expectFile = File(p.join('${file.path}.expect'));
    if (!expectFile.existsSync()) {
      throw Exception(
        'A text input must have a .expect file. '
        'Found test input $fileName with out an expect file.',
      );
    }
    final String expectResult = expectFile.readAsStringSync().trim();

    // A test input may declare builder options in a `.options` file holding a
    // JSON map, matching what `build.yaml` would pass to the builder.
    final optionsFile = File(p.join('${file.path}.options'));
    final BuilderOptions builderOptions = optionsFile.existsSync()
        ? BuilderOptions(json.decode(optionsFile.readAsStringSync()) as Map<String, dynamic>)
        : BuilderOptions.empty;
    final generator = GoRouterGenerator(
      duplicatePathSeverity: duplicatePathSeverityFromOptions(builderOptions),
    );

    // A test input declares the warnings the builder must log in a `.warnings`
    // file, one per line. Inputs that log nothing need no file, so an input that
    // starts logging a warning fails until the warning is declared.
    final warningsFile = File(p.join('${file.path}.warnings'));
    final String expectedWarnings = warningsFile.existsSync()
        ? warningsFile.readAsStringSync().trim()
        : '';

    test('verify $fileName', () async {
      // Normalize path separators for cross-platform compatibility
      final String path = file.path.replaceAll(r'\', '/');
      final targetLibraryAssetId = '__test__|$path';
      final LibraryElement element = await resolveSources<LibraryElement>(
        <String, String>{targetLibraryAssetId: file.readAsStringSync()},
        (Resolver resolver) async {
          final assetId = AssetId.parse(targetLibraryAssetId);
          return resolver.libraryFor(assetId);
        },
        readAllSourcesFromFilesystem: true,
      );
      final reader = LibraryReader(element);
      final results = <String>{};
      // Outside a build step, `package:build`'s `log` falls back to a plain
      // logger, whose records reach the root logger.
      final warnings = <String>[];
      final StreamSubscription<LogRecord> logs = Logger.root.onRecord.listen((LogRecord record) {
        if (record.level >= Level.WARNING) {
          warnings.add(record.message);
        }
      });
      try {
        generator.generateForAnnotation(reader, results, <String>{});
      } on InvalidGenerationSourceError catch (e) {
        // The generated message is the value under test, so it goes first.
        // Reversing these labels the diff backwards on failure.
        expect(e.message.trim(), expectResult);
        return;
      } finally {
        await logs.cancel();
      }

      expect(warnings.join('\n'), expectedWarnings);

      // Apply consistent formatting to both generated and expected code for comparison.
      final String generated = formatter.format(results.join('\n\n').trim());
      final String expected = formatter.format(expectResult.trim());
      expect(generated, equals(expected));
      // Each case resolves its input against the real SDK and package sources,
      // which takes seconds on an idle machine but far longer on a loaded one.
      // The generous timeout keeps a busy bot from reporting a false failure.
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}

Future<Version> _packageVersion() async {
  final PackageConfig packageConfig = await loadPackageConfigUri(Isolate.packageConfigSync!);
  final Uri pkgUri = Platform.script.resolve('../pubspec.yaml');
  final Package? package = packageConfig.packageOf(pkgUri);
  if (package == null) {
    throw StateError('No package at "$pkgUri"');
  }
  final LanguageVersion? languageVersion = package.languageVersion;
  if (languageVersion == null) {
    throw StateError('No language version "$pkgUri"');
  }
  return Version.parse('$languageVersion.0');
}
