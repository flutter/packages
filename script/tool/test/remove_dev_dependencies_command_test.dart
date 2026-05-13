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
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks();

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

    expect(
      output,
      containsAllInOrder(<Matcher>[contains('SKIPPING: Nothing to remove.')]),
    );
  });

  test('removes dev_dependencies', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      version: '1.0.0',
    );

    addToPubspec(package, '''
dev_dependencies:
  some_dependency: ^2.1.8
  another_dependency: ^1.0.0
''');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[contains('Removed dev_dependencies')]),
    );
    expect(
      package.pubspecFile.readAsStringSync(),
      isNot(contains('some_dependency:')),
    );
    expect(
      package.pubspecFile.readAsStringSync(),
      isNot(contains('another_dependency:')),
    );
  });

  test('removes from examples', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      version: '1.0.0',
    );

    final RepositoryPackage example = package.getExamples().first;
    addToPubspec(example, '''
dev_dependencies:
  some_dependency: ^2.1.8
  another_dependency: ^1.0.0
''');

    final List<String> output = await runCapturingPrint(runner, <String>[
      'remove-dev-dependencies',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[contains('Removed dev_dependencies')]),
    );
    expect(
      package.pubspecFile.readAsStringSync(),
      isNot(contains('some_dependency:')),
    );
    expect(
      package.pubspecFile.readAsStringSync(),
      isNot(contains('another_dependency:')),
    );
  });
}
