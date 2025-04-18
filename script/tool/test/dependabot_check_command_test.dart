// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/dependabot_check_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late Directory root;
  late Directory packagesDir;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks();
    root = packagesDir.parent;

    final DependabotCheckCommand command = DependabotCheckCommand(
      packagesDir,
      gitDir: gitDir,
    );
    runner = CommandRunner<void>(
        'dependabot_test', 'Test for $DependabotCheckCommand');
    runner.addCommand(command);
  });

  void setDependabotCoverage({
    Iterable<String> gradleDirs = const <String>[],
    bool useDirectoriesKey = false,
  }) {
    final String gradleEntries;
    if (useDirectoriesKey) {
      gradleEntries = '''
  - package-ecosystem: "gradle"
    directories:
${gradleDirs.map((String directory) => '      - /$directory').join('\n')}
    schedule:
      interval: "daily"
''';
    } else {
      gradleEntries = gradleDirs.map((String directory) => '''
  - package-ecosystem: "gradle"
    directory: "/$directory"
    schedule:
      interval: "daily"
''').join('\n');
    }
    final File configFile =
        root.childDirectory('.github').childFile('dependabot.yml');
    configFile.createSync(recursive: true);
    configFile.writeAsStringSync('''
version: 2
updates:
$gradleEntries
''');
  }

  test('skips with no supported ecosystems', () async {
    setDependabotCoverage();
    createFakePackage('a_package', packagesDir);

    final List<String> output =
        await runCapturingPrint(runner, <String>['dependabot-check']);

    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: No supported package ecosystems'),
        ]));
  });

  test('fails for app missing Gradle coverage', () async {
    setDependabotCoverage();
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.directory
        .childDirectory('example')
        .childDirectory('android')
        .childDirectory('app')
        .createSync(recursive: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['dependabot-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing Gradle coverage.'),
          contains(
              'Add a "gradle" entry to .github/dependabot.yml for /packages/a_package/example/android/app'),
          contains('a_package/example:\n'
              '    Missing Gradle coverage')
        ]));
  });

  test('fails for plugin missing Gradle coverage', () async {
    setDependabotCoverage();
    final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
    plugin.directory.childDirectory('android').createSync(recursive: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['dependabot-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing Gradle coverage.'),
          contains(
              'Add a "gradle" entry to .github/dependabot.yml for /packages/a_plugin/android'),
          contains('a_plugin:\n'
              '    Missing Gradle coverage')
        ]));
  });

  test('passes for correct Gradle coverage with single directory', () async {
    setDependabotCoverage(gradleDirs: <String>[
      'packages/a_plugin/android',
      'packages/a_plugin/example/android/app',
    ]);
    final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
    // Test the plugin.
    plugin.directory.childDirectory('android').createSync(recursive: true);
    // And its example app.
    plugin.directory
        .childDirectory('example')
        .childDirectory('android')
        .childDirectory('app')
        .createSync(recursive: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['dependabot-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 2 package(s)')]));
  });

  test('passes for correct Gradle coverage with multiple directories',
      () async {
    setDependabotCoverage(
      gradleDirs: <String>[
        'packages/a_plugin/android',
        'packages/a_plugin/example/android/app',
      ],
      useDirectoriesKey: true,
    );
    final RepositoryPackage plugin = createFakePlugin('a_plugin', packagesDir);
    // Test the plugin.
    plugin.directory.childDirectory('android').createSync(recursive: true);
    // And its example app.
    plugin.directory
        .childDirectory('example')
        .childDirectory('android')
        .childDirectory('app')
        .createSync(recursive: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['dependabot-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 2 package(s)')]));
  });
}
