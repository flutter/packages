// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/remove_dev_dependencies_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) = configureBaseCommandMocks();

    final command = RemoveDevDependenciesCommand(packagesDir, gitDir: gitDir);
    runner = CommandRunner<void>(
      'trim_dev_dependencies_command',
      'Test for trim_dev_dependencies_command',
    );
    runner.addCommand(command);
  });

  void addToPubspec(RepositoryPackage package, String addition) {
    final String originalContent = package.pubspecFile.readAsStringSync();
    package.pubspecFile.writeAsStringSync('''
$originalContent
$addition
''');
  }

  test('skips if nothing is removed', () async {
    createFakePackage('a_package', packagesDir, version: '1.0.0');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(output, containsAllInOrder(<Matcher>[contains('SKIPPING: Nothing to remove.')]));
  });

  test('removes dev_dependencies', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');

    addToPubspec(package, '''
dev_dependencies:
  some_dependency: ^2.1.8
  another_dependency: ^1.0.0
''');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(output, containsAllInOrder(<Matcher>[contains('Removed dev_dependencies')]));
    expect(package.pubspecFile.readAsStringSync(), isNot(contains('some_dependency:')));
    expect(package.pubspecFile.readAsStringSync(), isNot(contains('another_dependency:')));
  });

  test('removes from examples', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');

    final RepositoryPackage example = package.getExamples().first;
    addToPubspec(example, '''
dev_dependencies:
  some_dependency: ^2.1.8
  another_dependency: ^1.0.0
''');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(output, containsAllInOrder(<Matcher>[contains('Removed dev_dependencies')]));
    expect(package.pubspecFile.readAsStringSync(), isNot(contains('some_dependency:')));
    expect(package.pubspecFile.readAsStringSync(), isNot(contains('another_dependency:')));
  });

  test('removes @docImport directives for removed dev_dependencies in lib/', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');

    package.pubspecFile.writeAsStringSync(
      package.pubspecFile.readAsStringSync().replaceFirst(
        'dependencies:',
        'dependencies:\n  kept_dependency: ^1.0.0\n  both_dependency: ^1.0.0',
      ),
    );
    addToPubspec(package, '''
dev_dependencies:
  dev_only: ^1.0.0
  other_dev: ^2.0.0
  both_dependency: ^1.0.0
''');

    final File rootDart = package.libDirectory.childFile('a_package.dart');
    rootDart.writeAsStringSync('''
/// @docImport 'dart:async';
/// @docImport 'package:kept_dependency/kept.dart';
/// @docImport 'package:both_dependency/both.dart';
/// @docImport 'package:dev_only/dev_only.dart';
/// @docImport "package:other_dev/other.dart" show Foo;
/// @docImport 'src/helper.dart';
library;
''');

    final Directory srcDir = package.libDirectory.childDirectory('src')..createSync();
    final File srcDart = srcDir.childFile('helper.dart');
    srcDart.writeAsStringSync('''
// Copyright header.

/// @docImport 'package:dev_only/widget.dart'
///     show WidgetA, WidgetB;
/// @docImport
///   'package:other_dev/extra.dart' as extra;
library;

/// Not a directive: package:dev_only/mentioned.dart
void helper() {}
''');

    final File documentedLib = srcDir.childFile('documented_lib.dart');
    documentedLib.writeAsStringSync('''
/// Library docs stay attached.
/// @docImport 'package:dev_only/widget.dart';
library;

void other() {}
''');

    await runCapturingPrint(runner, <String>['remove-dev-dependencies']);

    expect(rootDart.readAsStringSync(), '''
/// @docImport 'dart:async';
/// @docImport 'package:kept_dependency/kept.dart';
/// @docImport 'package:both_dependency/both.dart';
/// @docImport 'src/helper.dart';
library;
''');
    expect(srcDart.readAsStringSync(), '''
// Copyright header.

/// Not a directive: package:dev_only/mentioned.dart
void helper() {}
''');
    expect(documentedLib.readAsStringSync(), '''
/// Library docs stay attached.
library;

void other() {}
''');
  });

  test('preserves files outside lib/ and non-dart files in lib/', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');

    addToPubspec(package, '''
dev_dependencies:
  dev_only: ^1.0.0
''');

    final Directory testDir = package.testDirectory..createSync();
    final File testFile = testDir.childFile('a_package_test.dart');
    const testContent = '''
/// @docImport 'package:dev_only/dev_only.dart';
void main() {}
''';
    testFile.writeAsStringSync(testContent);

    final File notesFile = package.libDirectory.childFile('notes.md');
    const notesContent = "/// @docImport 'package:dev_only/dev_only.dart';\n";
    notesFile.writeAsStringSync(notesContent);

    await runCapturingPrint(runner, <String>['remove-dev-dependencies']);

    expect(testFile.readAsStringSync(), testContent);
    expect(notesFile.readAsStringSync(), notesContent);
  });

  test('preserves CRLF line endings when stripping @docImport lines', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');

    addToPubspec(package, '''
dev_dependencies:
  dev_only: ^1.0.0
''');

    final File crlfDart = package.libDirectory.childFile('crlf.dart');
    crlfDart.writeAsStringSync(
      "/// @docImport 'package:dev_only/dev_only.dart';\r\n"
      "/// @docImport 'local.dart';\r\n"
      'library;\r\n',
    );

    await runCapturingPrint(runner, <String>['remove-dev-dependencies']);

    expect(crlfDart.readAsStringSync(), "/// @docImport 'local.dart';\r\nlibrary;\r\n");
  });

  test('succeeds when a package with dev_dependencies has no lib/ directory', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    package.libDirectory.deleteSync(recursive: true);

    addToPubspec(package, '''
dev_dependencies:
  dev_only: ^1.0.0
''');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(output, containsAllInOrder(<Matcher>[contains('Removed dev_dependencies')]));
    expect(package.pubspecFile.readAsStringSync(), isNot(contains('dev_only:')));
  });
}
