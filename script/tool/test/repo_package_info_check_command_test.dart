// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/repo_package_info_check_command.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/package_command_test.mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late FileSystem fileSystem;
  late Directory root;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    root = fileSystem.currentDirectory;
    packagesDir = root.childDirectory('packages');

    final MockGitDir gitDir = MockGitDir();
    when(gitDir.path).thenReturn(root.path);

    final RepoPackageInfoCheckCommand command = RepoPackageInfoCheckCommand(
      packagesDir,
      gitDir: gitDir,
    );
    runner = CommandRunner<void>(
        'dependabot_test', 'Test for $RepoPackageInfoCheckCommand');
    runner.addCommand(command);
  });

  String readmeTableHeader() {
    return '''
| Package | Pub | Points | Popularity | Issues | Pull requests |
|---------|-----|--------|------------|--------|---------------|
''';
  }

  String readmeTableEntry(String packageName, {String? tag}) {
    final String encodedTag = Uri.encodeComponent(tag ?? 'p: $packageName');
    return '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';
  }

  test('passes for correct README coverage', () async {
    createFakePackage('a_package', packagesDir);

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['repo-package-info-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 1 package(s)')]));
  });

  test('passes for federated plugins with only app-facing package listed',
      () async {
    const String pluginName = 'foo';
    final Directory pluginDir = packagesDir.childDirectory(pluginName);
    createFakePlugin(pluginName, pluginDir);
    createFakePlugin('${pluginName}_platform_interface', pluginDir);
    createFakePlugin('${pluginName}_android', pluginDir);
    createFakePlugin('${pluginName}_ios', pluginDir);

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(pluginName)}
''');

    final List<String> output =
        await runCapturingPrint(runner, <String>['repo-package-info-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 4 package(s)')]));
  });

  test('fails for unexpected README table entry', () async {
    createFakePackage('a_package', packagesDir);

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unknown package "another_package" in root README.md table'),
        ]));
  });

  test('fails for missing README table entry', () async {
    createFakePackage('a_package', packagesDir);
    createFakePackage('another_package', packagesDir);

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing repo root README.md table entry'),
          contains('a_package:\n'
              '    Missing repo root README.md table entry')
        ]));
  });
}
