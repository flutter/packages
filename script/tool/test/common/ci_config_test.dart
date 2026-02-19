// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late Directory packagesDir;

  setUp(() {
    (:packagesDir, processRunner: _, gitProcessRunner: _, gitDir: _) =
        configureBaseCommandMocks();
  });

  group('CIConfig', () {
    test('file', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );

      final File ciConfigFile = plugin.ciConfigFile;

      expect(
        ciConfigFile.path,
        plugin.directory.childFile('ci_config.yaml').path,
      );
    });

    test('parsing', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );
      plugin.ciConfigFile.writeAsStringSync('''
release:
  batch: true
''');

      final CIConfig? config = plugin.parseCIConfig();

      expect(config, isNotNull);
      expect(config!.isBatchRelease, isTrue);
    });

    test('parsing missing file returns null', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );

      final CIConfig? config = plugin.parseCIConfig();

      expect(config, isNull);
    });

    test('parsing invalid file throws', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );
      plugin.ciConfigFile.writeAsStringSync('not a map');

      expect(
        () => plugin.parseCIConfig(),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Root of ci_config.yaml must be a map'),
          ),
        ),
      );
    });

    test('reports unknown keys', () {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );
      plugin.ciConfigFile.writeAsStringSync('''
foo: bar
''');

      expect(
        () => plugin.parseCIConfig(),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Unknown key `foo` in config'),
          ),
        ),
      );
    });

    test('reports invalid values', () {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );
      plugin.ciConfigFile.writeAsStringSync('''
release:
  batch: not-a-bool
''');

      expect(
        () => plugin.parseCIConfig(),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Invalid value `not-a-bool` for key `release.batch`'),
          ),
        ),
      );
    });
  });
}
