// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import '../util.dart';

void main() {
  late Directory packagesDir;

  setUp(() {
    (:packagesDir, processRunner: _, gitProcessRunner: _, gitDir: _) =
        configureBaseCommandMocks();
  });

  group('displayName', () {
    test('prints packageDir-relative paths by default', () async {
      expect(
        RepositoryPackage(packagesDir.childDirectory('foo')).displayName,
        'foo',
      );
      expect(
        RepositoryPackage(
          packagesDir
              .childDirectory('foo')
              .childDirectory('bar')
              .childDirectory('baz'),
        ).displayName,
        'foo/bar/baz',
      );
    });

    test('handles third_party/packages/', () async {
      expect(
        RepositoryPackage(
          packagesDir.parent
              .childDirectory('third_party')
              .childDirectory('packages')
              .childDirectory('foo')
              .childDirectory('bar')
              .childDirectory('baz'),
        ).displayName,
        'foo/bar/baz',
      );
    });

    test('always uses Posix-style paths', () async {
      final Directory windowsPackagesDir = createPackagesDirectory(
        MemoryFileSystem(style: FileSystemStyle.windows),
      );

      expect(
        RepositoryPackage(windowsPackagesDir.childDirectory('foo')).displayName,
        'foo',
      );
      expect(
        RepositoryPackage(
          windowsPackagesDir
              .childDirectory('foo')
              .childDirectory('bar')
              .childDirectory('baz'),
        ).displayName,
        'foo/bar/baz',
      );
    });

    test('elides group name in grouped federated plugin structure', () async {
      expect(
        RepositoryPackage(
          packagesDir
              .childDirectory('a_plugin')
              .childDirectory('a_plugin_platform_interface'),
        ).displayName,
        'a_plugin_platform_interface',
      );
      expect(
        RepositoryPackage(
          packagesDir
              .childDirectory('a_plugin')
              .childDirectory('a_plugin_platform_web'),
        ).displayName,
        'a_plugin_platform_web',
      );
    });

    // The app-facing package doesn't get elided to avoid potential confusion
    // with the group folder itself.
    test('does not elide group name for app-facing packages', () async {
      expect(
        RepositoryPackage(
          packagesDir.childDirectory('a_plugin').childDirectory('a_plugin'),
        ).displayName,
        'a_plugin/a_plugin',
      );
    });
  });

  group('getExamples', () {
    test('handles a single Flutter example', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );

      final List<RepositoryPackage> examples = plugin.getExamples().toList();

      expect(examples.length, 1);
      expect(examples[0].isExample, isTrue);
      expect(examples[0].path, getExampleDir(plugin).path);
    });

    test('handles multiple Flutter examples', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>['example1', 'example2'],
      );

      final List<RepositoryPackage> examples = plugin.getExamples().toList();

      expect(examples.length, 2);
      expect(examples[0].isExample, isTrue);
      expect(examples[1].isExample, isTrue);
      expect(
        examples[0].path,
        getExampleDir(plugin).childDirectory('example1').path,
      );
      expect(
        examples[1].path,
        getExampleDir(plugin).childDirectory('example2').path,
      );
    });

    test('handles a single non-Flutter example', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      final List<RepositoryPackage> examples = package.getExamples().toList();

      expect(examples.length, 1);
      expect(examples[0].isExample, isTrue);
      expect(examples[0].path, getExampleDir(package).path);
    });

    test('handles multiple non-Flutter examples', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        examples: <String>['example1', 'example2'],
      );

      final List<RepositoryPackage> examples = package.getExamples().toList();

      expect(examples.length, 2);
      expect(examples[0].isExample, isTrue);
      expect(examples[1].isExample, isTrue);
      expect(
        examples[0].path,
        getExampleDir(package).childDirectory('example1').path,
      );
      expect(
        examples[1].path,
        getExampleDir(package).childDirectory('example2').path,
      );
    });
  });

  group('federated plugin queries', () {
    test('all return false for a simple plugin', () {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );
      expect(plugin.isFederated, false);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isFederated, false);
      expect(plugin.isExample, isFalse);
    });

    test('handle app-facing packages', () {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir.childDirectory('a_plugin'),
      );
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, true);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isPlatformImplementation, false);
      expect(plugin.isExample, isFalse);
    });

    test('handle platform interface packages', () {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin_platform_interface',
        packagesDir.childDirectory('a_plugin'),
      );
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, true);
      expect(plugin.isPlatformImplementation, false);
      expect(plugin.isExample, isFalse);
    });

    test('handle platform implementation packages', () {
      // A platform interface can end with anything, not just one of the known
      // platform names, because of cases like webview_flutter_wkwebview.
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin_foo',
        packagesDir.childDirectory('a_plugin'),
      );
      expect(plugin.isFederated, true);
      expect(plugin.isAppFacing, false);
      expect(plugin.isPlatformInterface, false);
      expect(plugin.isPlatformImplementation, true);
      expect(plugin.isExample, isFalse);
    });
  });

  group('pubspec', () {
    test('file', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
      );

      final File pubspecFile = plugin.pubspecFile;

      expect(pubspecFile.path, plugin.directory.childFile('pubspec.yaml').path);
    });

    test('parsing', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>['example1', 'example2'],
      );

      final Pubspec pubspec = plugin.parsePubspec();

      expect(pubspec.name, 'a_plugin');
    });
  });

  group('requiresFlutter', () {
    test('returns true for Flutter package', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        isFlutter: true,
      );
      expect(package.requiresFlutter(), true);
    });

    test('returns true for a dev dependency on Flutter', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final File pubspecFile = package.pubspecFile;
      final Pubspec pubspec = package.parsePubspec();
      pubspec.devDependencies['flutter'] = SdkDependency('flutter');
      pubspecFile.writeAsStringSync(pubspec.toString());

      expect(package.requiresFlutter(), true);
    });

    test('returns false for non-Flutter package', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      expect(package.requiresFlutter(), false);
    });
  });
  group('ciConfig', () {
    test('file', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);

      final File ciConfigFile = plugin.ciConfigFile;

      expect(
          ciConfigFile.path, plugin.directory.childFile('ci_config.yaml').path);
    });

    test('parsing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      plugin.ciConfigFile.writeAsStringSync('''
release:
  batch: true
''');

      final CiConfig? config = plugin.parseCiConfig();

      expect(config, isNotNull);
      expect(config!.isBatchRelease, isTrue);
    });

    test('parsing missing file returns null', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);

      final CiConfig? config = plugin.parseCiConfig();

      expect(config, isNull);
    });

    test('parsing invalid file throws', () async {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      plugin.ciConfigFile.writeAsStringSync('not a map');

      expect(
          () => plugin.parseCiConfig(),
          throwsA(isA<FormatException>().having(
              (FormatException e) => e.message,
              'message',
              contains('Root of ci_config.yaml must be a map'))));
    });

    test('reports unknown keys', () {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      plugin.ciConfigFile.writeAsStringSync('''
foo: bar
''');

      expect(
          () => plugin.parseCiConfig(),
          throwsA(isA<FormatException>().having(
              (FormatException e) => e.message,
              'message',
              contains('Unknown key `foo` in config'))));
    });

    test('reports invalid values', () {
      final RepositoryPackage plugin =
          createFakePlugin('a_plugin', packagesDir);
      plugin.ciConfigFile.writeAsStringSync('''
release:
  batch: not-a-bool
''');

      expect(
          () => plugin.parseCiConfig(),
          throwsA(isA<FormatException>().having(
              (FormatException e) => e.message,
              'message',
              contains('Invalid value `not-a-bool` for key `release.batch`'))));
    });
  });

  group('getPendingChangelogs', () {
    test('returns an error if the directory is missing', () {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      expect(() => package.getPendingChangelogs(), throwsFormatException);
    });

    test('returns empty lists if the directory is empty', () {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.pendingChangelogsDirectory.createSync();

      final List<PendingChangelogEntry> changelogs =
          package.getPendingChangelogs();

      expect(changelogs, isEmpty);
    });

    test('returns entries for valid files', () {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.pendingChangelogsDirectory.createSync();
      package.pendingChangelogsDirectory
          .childFile('a.yaml')
          .writeAsStringSync('''
changelog: A
version: patch
''');
      package.pendingChangelogsDirectory
          .childFile('b.yaml')
          .writeAsStringSync('''
changelog: B
version: minor
''');

      final List<PendingChangelogEntry> changelogs =
          package.getPendingChangelogs();

      expect(changelogs, hasLength(2));
      expect(changelogs[0].changelog, 'A');
      expect(changelogs[0].version, VersionChange.patch);
      expect(changelogs[1].changelog, 'B');
      expect(changelogs[1].version, VersionChange.minor);
    });

    test('returns an error for a malformed file', () {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.pendingChangelogsDirectory.createSync();
      final File changelogFile =
          package.pendingChangelogsDirectory.childFile('a.yaml');
      changelogFile.writeAsStringSync('not yaml');

      expect(
          () => package.getPendingChangelogs(),
          throwsA(isA<FormatException>().having(
              (FormatException e) => e.message,
              'message',
              contains('Expected a YAML map, but found String'))));
    });

    test('ignores template.yaml', () {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.pendingChangelogsDirectory.createSync();
      package.pendingChangelogsDirectory
          .childFile('a.yaml')
          .writeAsStringSync('''
changelog: A
version: patch
''');
      package.pendingChangelogsDirectory
          .childFile('template.yaml')
          .writeAsStringSync('''
changelog: TEMPLATE
version: skip
''');

      final List<PendingChangelogEntry> changelogs =
          package.getPendingChangelogs();

      expect(changelogs, hasLength(1));
      expect(changelogs[0].changelog, 'A');
    });
  });
}
