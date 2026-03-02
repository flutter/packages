// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/repo_package_info_check_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late Directory root;
  late Directory packagesDir;
  late RecordingProcessRunner gitProcessRunner;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, :gitProcessRunner, :gitDir) =
        configureBaseCommandMocks();
    root = packagesDir.fileSystem.currentDirectory;

    final command = RepoPackageInfoCheckCommand(packagesDir, gitDir: gitDir);
    runner = CommandRunner<void>(
      'dependabot_test',
      'Test for $RepoPackageInfoCheckCommand',
    );
    runner.addCommand(command);

    // Default to failing these checks so that tests of non-batch-release packages
    // (the default) don't fail due to "unexpected" branches/labels being found.
    gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
        <FakeProcessInfo>[FakeProcessInfo(MockProcess(exitCode: 1))];
  });

  String readmeTableHeader() {
    return '''
| Package | Pub | Points | Popularity | Issues | Pull requests |
|---------|-----|--------|------------|--------|---------------|
''';
  }

  void writeCodeOwners(List<RepositoryPackage> ownedPackages) {
    final List<String> subpaths = ownedPackages
        .map(
          (RepositoryPackage p) => p.isFederated
              ? <String>[
                  p.directory.parent.basename,
                  p.directory.basename,
                ].join('/')
              : p.directory.basename,
        )
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

  void writeAutoLabelerYaml(List<RepositoryPackage> packages) {
    final File labelerYaml = root
        .childDirectory('.github')
        .childFile('labeler.yml');
    labelerYaml.createSync(recursive: true);
    labelerYaml.writeAsStringSync(
      packages
          .map((RepositoryPackage p) {
            final bool isThirdParty = p.path.contains('third_party/');
            return '''
-p: ${p.directory.basename}
  - changed-files:
    - any-glob-to-any-file:
      - ${isThirdParty ? 'third_party/' : ''}packages/${p.directory.basename}/**/*
''';
          })
          .join('\n\n'),
    );
  }

  test('passes for correct coverage', () async {
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'repo-package-info-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[contains('Ran for 1 package(s)')]),
    );
  });

  test(
    'passes for federated plugins with only app-facing package listed',
    () async {
      const pluginName = 'foo';
      final Directory pluginDir = packagesDir.childDirectory(pluginName);
      final packages = <RepositoryPackage>[
        createFakePlugin(pluginName, pluginDir),
        createFakePlugin('${pluginName}_platform_interface', pluginDir),
        createFakePlugin('${pluginName}_android', pluginDir),
        createFakePlugin('${pluginName}_ios', pluginDir),
      ];

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(pluginName)}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[packages.first]);
      writeAutoLabelerYaml(<RepositoryPackage>[packages.first]);
      writeCodeOwners(packages);

      // 4 packages * 2 checks (git, gh) = 8 calls.
      // Default mocks in setUp cover 1 call each. We need 3 more each.
      gitProcessRunner.mockProcessesForExecutable['git-ls-remote']!
          .addAll(<FakeProcessInfo>[
            FakeProcessInfo(MockProcess(exitCode: 1)),
            FakeProcessInfo(MockProcess(exitCode: 1)),
            FakeProcessInfo(MockProcess(exitCode: 1)),
          ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'repo-package-info-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Ran for 4 package(s)')]),
      );
    },
  );

  test('fails for unexpected README table entry', () async {
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Unknown package "another_package" in root README.md table'),
      ]),
    );
  });

  test('fails for missing README table entry', () async {
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
      createFakePackage('another_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('another_package')}
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Missing repo root README.md table entry'),
        contains(
          'a_package:\n'
          '    Missing repo root README.md table entry',
        ),
      ]),
    );
  });

  test('fails for unexpected format in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
        '| [$packageName](./packages/$packageName/) | '
        'Some random text | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Invalid repo root README.md table entry: "Some random text"'),
        contains(
          'a_package:\n'
          '    Invalid root README.md table entry',
        ),
      ]),
    );
  });

  test('fails for incorrect source link in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const incorrectPackageName = 'a_pakage';
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
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
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'Incorrect link in root README.md table: "./packages/$incorrectPackageName/"',
        ),
        contains(
          'a_package:\n'
          '    Incorrect link in root README.md table',
        ),
      ]),
    );
  });

  test('fails for incorrect packages/* link in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const incorrectPackageName = 'a_pakage';
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
        '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$incorrectPackageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'Incorrect link in root README.md table: "https://pub.dev/packages/$incorrectPackageName/score"',
        ),
        contains(
          'a_package:\n'
          '    Incorrect link in root README.md table',
        ),
      ]),
    );
  });

  test('fails for incorrect labels/* link in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final String incorrectTag = Uri.encodeComponent('p: a_pakage');
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
        '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$incorrectTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'Incorrect link in root README.md table: "https://github.com/flutter/flutter/labels/$incorrectTag"',
        ),
        contains(
          'a_package:\n'
          '    Incorrect link in root README.md table',
        ),
      ]),
    );
  });

  test('fails for incorrect packages/* anchor in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    const incorrectPackageName = 'a_pakage';
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
        '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$incorrectPackageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$encodedTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'Incorrect anchor in root README.md table: "![pub points](https://img.shields.io/pub/points/$incorrectPackageName)"',
        ),
        contains(
          'a_package:\n'
          '    Incorrect anchor in root README.md table',
        ),
      ]),
    );
  });

  test('fails for incorrect tag query anchor in README table entry', () async {
    const packageName = 'a_package';
    final String encodedTag = Uri.encodeComponent('p: $packageName');
    final String incorrectTag = Uri.encodeComponent('p: a_pakage');
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    final entry =
        '| [$packageName](./packages/$packageName/) | '
        '[![pub package](https://img.shields.io/pub/v/$packageName.svg)](https://pub.dev/packages/$packageName) | '
        '[![pub points](https://img.shields.io/pub/points/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![popularity](https://img.shields.io/pub/popularity/$packageName)](https://pub.dev/packages/$packageName/score) | '
        '[![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$incorrectTag?label=)](https://github.com/flutter/flutter/labels/$encodedTag) | '
        '[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr/flutter/packages/$encodedTag?label=)](https://github.com/flutter/packages/labels/$encodedTag) |';

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
$entry
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'Incorrect anchor in root README.md table: "![GitHub issues by-label](https://img.shields.io/github/issues/flutter/flutter/$incorrectTag?label=)',
        ),
        contains(
          'a_package:\n'
          '    Incorrect anchor in root README.md table',
        ),
      ]),
    );
  });

  test('fails for missing CODEOWNER', () async {
    const packageName = 'a_package';
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(packageName)}
''');
    writeAutoLabelerYaml(packages);
    writeCodeOwners(<RepositoryPackage>[]);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Missing CODEOWNERS entry.'),
        contains(
          'a_package:\n'
          '    Missing CODEOWNERS entry',
        ),
      ]),
    );
  });

  test('fails for missing auto-labeler entry', () async {
    const packageName = 'a_package';
    final packages = <RepositoryPackage>[
      createFakePackage('a_package', packagesDir),
    ];

    root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry(packageName)}
''');
    writeAutoLabelerYaml(<RepositoryPackage>[]);
    writeCodeOwners(packages);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['repo-package-info-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Missing a rule in .github/labeler.yml.'),
        contains(
          'a_package:\n'
          '    Missing auto-labeler entry',
        ),
      ]),
    );
  });

  group('ci_config check', () {
    test('control test', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[package]);
      writeCodeOwners(<RepositoryPackage>[package]);

      package.ciConfigFile.writeAsStringSync('''
release:
  batch: false
    ''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'repo-package-info-check',
      ]);

      expect(output, containsAll(<Matcher>[contains('No issues found!')]));
    });

    test('missing ci_config file is ok', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[package]);
      writeCodeOwners(<RepositoryPackage>[package]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'repo-package-info-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('No issues found!')]),
      );
    });

    test('fails for unknown key', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[package]);
      writeCodeOwners(<RepositoryPackage>[package]);
      package.ciConfigFile.writeAsStringSync('''
something: true
    ''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unknown key `something` in config, the possible keys are'),
        ]),
      );
    });

    test('fails for invalid value type for batch property in release', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[package]);
      writeCodeOwners(<RepositoryPackage>[package]);
      package.ciConfigFile.writeAsStringSync('''
release:
  batch: 1
    ''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Invalid value `1` for key `release.batch`, the possible values are [true, false]',
          ),
        ]),
      );
    });
  });

  group('release strategy check', () {
    RepositoryPackage setupReleaseStrategyTest() {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      root.childFile('README.md').writeAsStringSync('''
${readmeTableHeader()}
${readmeTableEntry('a_package')}
''');
      writeAutoLabelerYaml(<RepositoryPackage>[package]);
      writeCodeOwners(<RepositoryPackage>[package]);
      return package;
    }

    void writeBatchConfig(RepositoryPackage package) {
      package.ciConfigFile.writeAsStringSync('''
release:
  batch: true
''');
    }

    void writeWorkflowFiles({
      bool validBatchFile = true,
      bool validReleaseFromBranches = true,
      bool validSyncRelease = true,
    }) {
      final Directory workflowDir = root
          .childDirectory('.github')
          .childDirectory('workflows');
      workflowDir.createSync(recursive: true);

      if (validBatchFile) {
        workflowDir.childFile('a_package_batch.yml').writeAsStringSync('''
name: Batch Release
on:
  schedule:
    - cron: "0 8 * * 1"
jobs:
  dispatch_release_pr:
    runs-on: ubuntu-latest
    steps:
      - name: Repository Dispatch
        uses: peter-evans/repository-dispatch@5fc4efd1a4797ddb68ffd0714a238564e4cc0e6f
        with:
          event-type: batch-release-pr
          client-payload: '{"package": "a_package"}'
''');
      }

      if (validReleaseFromBranches) {
        workflowDir.childFile('release_from_branches.yml').writeAsStringSync('''
on:
  push:
    branches:
      - 'release-a_package'
''');
      }

      if (validSyncRelease) {
        workflowDir.childFile('sync_release_pr.yml').writeAsStringSync('''
on:
  push:
    branches:
      - 'release-a_package'
''');
      }
    }

    test(
      'ignores non-batch release packages if they have no artifacts',
      () async {
        setupReleaseStrategyTest();
        // No config, so batch is false by default.

        gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
            <FakeProcessInfo>[
              FakeProcessInfo(
                MockProcess(exitCode: 1),
              ), // git ls-remote fails (branch doesn't exist)
            ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'repo-package-info-check',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[contains('No issues found!')]),
        );
      },
    );

    test('fails if non-batch package has batch artifacts', () async {
      setupReleaseStrategyTest();
      // batch defaults to false
      writeWorkflowFiles();

      gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
          <FakeProcessInfo>[
            FakeProcessInfo(
              MockProcess(),
            ), // git ls-remote succeeds (branch exists)
          ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Unexpected batch workflow file: .github/workflows/a_package_batch.yml',
          ),
        ),
      );
      expect(
        output,
        contains(
          contains(
            'Unexpected trigger for release-a_package in .github/workflows/release_from_branches.yml',
          ),
        ),
      );
      expect(
        output,
        contains(
          contains(
            'Unexpected trigger for release-a_package in .github/workflows/sync_release_pr.yml',
          ),
        ),
      );
    });

    test('fails if batch package has pre-release version', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      writeWorkflowFiles();
      package.pubspecFile.writeAsStringSync('''
name: a_package
version: 1.0.0-wip
''');
      gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess()), // git ls-remote succeeds
          ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Batch release packages must not have a pre-release version.',
          ),
        ),
      );
    });

    test('fails if batch workflow file is missing', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      // Don't write workflow files.

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Missing batch workflow file: .github/workflows/a_package_batch.yml',
          ),
        ),
      );
    });

    test('fails if batch workflow content is invalid', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      final Directory workflowDir = root
          .childDirectory('.github')
          .childDirectory('workflows');
      workflowDir.createSync(recursive: true);
      workflowDir.childFile('a_package_batch.yml').writeAsStringSync('''
name: Batch Release
jobs:
  dispatch_release_pr:
    steps:
      - uses: peter-evans/repository-dispatch@5fc4efd1a4797ddb68ffd0714a238564e4cc0e6f
        with:
          event-type: something-else
          client-payload: '{"package": "a_package"}'
''');
      // Write other files to be valid so we focus on this error
      workflowDir
          .childFile('release_from_branches.yml')
          .writeAsStringSync("- 'release-a_package'");
      workflowDir
          .childFile('sync_release_pr.yml')
          .writeAsStringSync("- 'release-a_package'");

      // Mock successful git and gh calls
      gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
          <FakeProcessInfo>[FakeProcessInfo(MockProcess())];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Invalid batch workflow content in a_package_batch.yml. '
            'Must contain a step using peter-evans/repository-dispatch with:\n'
            '  event-type: batch-release-pr\n'
            '  client-payload: \'{"package": "a_package"}\'',
          ),
        ),
      );
    });

    test('fails if global workflows are missing triggers', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      writeWorkflowFiles(
        validReleaseFromBranches: false,
        validSyncRelease: false,
      );
      // Create files but without correct content
      final Directory workflowDir = root
          .childDirectory('.github')
          .childDirectory('workflows');
      workflowDir
          .childFile('release_from_branches.yml')
          .writeAsStringSync('name: something');
      workflowDir
          .childFile('sync_release_pr.yml')
          .writeAsStringSync('name: something');

      gitProcessRunner.mockProcessesForExecutable['git'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess()),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Missing trigger for release-a_package in .github/workflows/release_from_branches.yml',
          ),
        ),
      );
      expect(
        output,
        contains(
          contains(
            'Missing trigger for release-a_package in .github/workflows/sync_release_pr.yml',
          ),
        ),
      );
    });

    test('fails if remote branch check fails', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      writeWorkflowFiles();

      gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(exitCode: 1)), // git ls-remote fails
          ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains(
            'Branch release-a_package does not exist on remote flutter/packages',
          ),
        ),
      );
    });

    test('passes if all checks pass', () async {
      final RepositoryPackage package = setupReleaseStrategyTest();
      writeBatchConfig(package);
      writeWorkflowFiles();

      gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] =
          <FakeProcessInfo>[FakeProcessInfo(MockProcess())];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['repo-package-info-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      if (commandError != null) {
        print('ERROR: Command failed in "passes if all checks pass"');
        print('Output:\n${output.join('\n')}');
      }

      expect(commandError, isNull);
      expect(
        output,
        containsAllInOrder(<Matcher>[contains('No issues found!')]),
      );
    });
  });
}
