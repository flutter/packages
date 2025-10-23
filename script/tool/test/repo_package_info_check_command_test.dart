// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/repo_package_info_check_command.dart';
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
    root = packagesDir.fileSystem.currentDirectory;

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

  void writeCodeOwners(List<RepositoryPackage> ownedPackages) {
    final List<String> subpaths = ownedPackages
        .map((RepositoryPackage p) => p.isFederated
            ? <String>[p.directory.parent.basename, p.directory.basename]
                .join('/')
            : p.directory.basename)
        .toList();
    root.childFile('CODEOWNERS').writeAsStringSync('''
${subpaths.map((String subpath) => 'packages/$subpath/** @someone').join('\n')}
''');
  }

  String readmeTableEntry(String packageName) {
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    return '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';
  }

  test('passes for correct README coverage', () async {
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
    writeCodeOwners(packages);

    final List<String> output =
        await runCapturingPrint(runner, <String>['repo-package-info-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 1 package(s)')]));
  });

  test('passes for federated plugins with only app-facing package listed',
      () async {
    const String pluginName = 'foo';
    final Directory pluginDir = packagesDir.childDirectory(pluginName);
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePlugin(pluginName, pluginDir),
      createFakePlugin('${pluginName}_platform_interface', pluginDir),
      createFakePlugin('${pluginName}_android', pluginDir),
      createFakePlugin('${pluginName}_ios', pluginDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(pluginName)}
''');
    writeCodeOwners(packages);

    final List<String> output =
        await runCapturingPrint(runner, <String>['repo-package-info-check']);

    expect(output,
        containsAllInOrder(<Matcher>[contains('Ran for 4 package(s)')]));
  });

  test('fails for unexpected README table entry', () async {
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');
    writeCodeOwners(packages);

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
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
      createFakePackage('another_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');
    writeCodeOwners(packages);

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

  test('fails for unexpected format in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry = '| [$packageName](./packages/$packageName/) | '
        'Some random text | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Invalid repo root README.md table entry: "Some random text"'),
          contains('a_package:\n'
              '    Invalid root README.md table entry')
        ]));
  });

  test('fails for incorrect source link in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const String incorrectPackageName = 'a_pakage';
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry =
        '| [$packageName](./packages/$incorrectPackageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Incorrect link in root README.md table: "./packages/$incorrectPackageName/"'),
          contains('a_package:\n'
              '    Incorrect link in root README.md table')
        ]));
  });

  test('fails for incorrect packages/* link in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const String incorrectPackageName = 'a_pakage';
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry = '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$incorrectPackageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Incorrect link in root README.md table: "https://pub.dev/packages/$incorrectPackageName/score"'),
          contains('a_package:\n'
              '    Incorrect link in root README.md table')
        ]));
  });

  test('fails for incorrect labels/* link in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final String incorrectTag = Uri.encodeComponent('p: a_pakage');
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry = '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$incorrectTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Incorrect link in root README.md table: "https://github.com/flutter/flutter/labels/$incorrectTag"'),
          contains('a_package:\n'
              '    Incorrect link in root README.md table')
        ]));
  });

  test('fails for incorrect packages/* anchor in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const String incorrectPackageName = 'a_pakage';
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry = '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$incorrectPackageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Incorrect anchor in root README.md table: "![pub points](https://img.shields.io/pub/points/$incorrectPackageName)"'),
          contains('a_package:\n'
              '    Incorrect anchor in root README.md table')
        ]));
  });

  test('fails for incorrect tag query anchor in README table entry', () async {
    const String packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final String incorrectTag = Uri.encodeComponent('p: a_pakage');
    final List<RepositoryPackage> packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final String entry = '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$incorrectTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Incorrect anchor in root README.md table: "![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$incorrectTag?label=)'),
          contains('a_package:\n'
              '    Incorrect anchor in root README.md table')
        ]));
  });

  test('fails for missing CODEOWNER', () async {
    const String packageName = 'a_package';
    createFakePackage(packageName, packagesDir);

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(packageName)}
''');
    writeCodeOwners(<RepositoryPackage>[]);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['repo-package-info-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Missing CODEOWNERS entry.'),
          contains('a_package:\n'
              '    Missing CODEOWNERS entry')
        ]));
  });

  group('ci_config check', () {
    test('control test', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeCodeOwners(<RepositoryPackage>[package]);

      package.ciConfigFile.writeAsStringSync('''
release:
  batch: false
    ''');

      final List<String> output =
          await runCapturingPrint(runner, <String>['repo-package-info-check']);

      expect(
        output,
        containsAll(<Matcher>[
          contains('  Checking ci_config.yaml...'),
          contains('No issues found!'),
        ]),
      );
    });

    test('missing ci_config file is ok', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeCodeOwners(<RepositoryPackage>[package]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['repo-package-info-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No issues found!'),
        ]),
      );
    });

    test('fails for unknown key', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeCodeOwners(<RepositoryPackage>[package]);
      package.ciConfigFile.writeAsStringSync('''
something: true
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
          contains('Unknown key `something` in config, the possible keys are'),
        ]),
      );
    });

    test('fails for invalid value type for batch property in release',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeCodeOwners(<RepositoryPackage>[package]);
      package.ciConfigFile.writeAsStringSync('''
release:
  batch: 1
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
          contains(
              'Invalid value `1` for key `release.batch`, the possible values are [true, false]'),
        ]),
      );
    });
  });
}
