// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/analyze_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;

  setUp(() {
    mockPlatform = MockPlatform();
    final GitDir gitDir;
    (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks(platform: mockPlatform);
    final AnalyzeCommand analyzeCommand = AnalyzeCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
      platform: mockPlatform,
    );

    runner = CommandRunner<void>('analyze_command', 'Test for analyze_command');
    runner.addCommand(analyzeCommand);
  });

  test('analyzes all packages', () async {
    final RepositoryPackage package1 = createFakePackage('a', packagesDir);
    final RepositoryPackage plugin2 = createFakePlugin('b', packagesDir);

    await runCapturingPrint(runner, <String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], package1.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              package1.path),
          ProcessCall('flutter', const <String>['pub', 'get'], plugin2.path),
          ProcessCall(
              'dart', const <String>['analyze', '--fatal-infos'], plugin2.path),
        ]));
  });

  test('skips flutter pub get for examples', () async {
    final RepositoryPackage plugin1 = createFakePlugin('a', packagesDir);

    await runCapturingPrint(runner, <String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], plugin1.path),
          ProcessCall(
              'dart', const <String>['analyze', '--fatal-infos'], plugin1.path),
        ]));
  });

  test('runs flutter pub get for non-example subpackages', () async {
    final RepositoryPackage mainPackage = createFakePackage('a', packagesDir);
    final Directory otherPackagesDir =
        mainPackage.directory.childDirectory('other_packages');
    final RepositoryPackage subpackage1 =
        createFakePackage('subpackage1', otherPackagesDir);
    final RepositoryPackage subpackage2 =
        createFakePackage('subpackage2', otherPackagesDir);

    await runCapturingPrint(runner, <String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['pub', 'get'], mainPackage.path),
          ProcessCall(
              'flutter', const <String>['pub', 'get'], subpackage1.path),
          ProcessCall(
              'flutter', const <String>['pub', 'get'], subpackage2.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
              mainPackage.path),
        ]));
  });

  test('passes lib/ directory with --lib-only', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);

    await runCapturingPrint(runner, <String>['analyze', '--lib-only']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos', 'lib'],
              package.path),
        ]));
  });

  test('skips when missing lib/ directory with --lib-only', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    package.libDirectory.deleteSync();

    final List<String> output =
        await runCapturingPrint(runner, <String>['analyze', '--lib-only']);

    expect(processRunner.recordedCalls, isEmpty);
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('SKIPPING: No lib/ directory'),
      ]),
    );
  });

  test(
      'does not run flutter pub get for non-example subpackages with --lib-only',
      () async {
    final RepositoryPackage mainPackage = createFakePackage('a', packagesDir);
    final Directory otherPackagesDir =
        mainPackage.directory.childDirectory('other_packages');
    createFakePackage('subpackage1', otherPackagesDir);
    createFakePackage('subpackage2', otherPackagesDir);

    await runCapturingPrint(runner, <String>['analyze', '--lib-only']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter', const <String>['pub', 'get'], mainPackage.path),
          ProcessCall('dart', const <String>['analyze', '--fatal-infos', 'lib'],
              mainPackage.path),
        ]));
  });

  test("don't elide a non-contained example package", () async {
    final RepositoryPackage plugin1 = createFakePlugin('a', packagesDir);
    final RepositoryPackage plugin2 = createFakePlugin('example', packagesDir);

    await runCapturingPrint(runner, <String>['analyze']);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], plugin1.path),
          ProcessCall(
              'dart', const <String>['analyze', '--fatal-infos'], plugin1.path),
          ProcessCall('flutter', const <String>['pub', 'get'], plugin2.path),
          ProcessCall(
              'dart', const <String>['analyze', '--fatal-infos'], plugin2.path),
        ]));
  });

  test('uses a separate analysis sdk', () async {
    final RepositoryPackage plugin = createFakePlugin('a', packagesDir);

    await runCapturingPrint(
        runner, <String>['analyze', '--analysis-sdk', 'foo/bar/baz']);

    expect(
      processRunner.recordedCalls,
      orderedEquals(<ProcessCall>[
        ProcessCall(
          'flutter',
          const <String>['pub', 'get'],
          plugin.path,
        ),
        ProcessCall(
          'foo/bar/baz/bin/dart',
          const <String>['analyze', '--fatal-infos'],
          plugin.path,
        ),
      ]),
    );
  });

  test('downgrades first when requested', () async {
    final RepositoryPackage plugin = createFakePlugin('a', packagesDir);

    await runCapturingPrint(runner, <String>['analyze', '--downgrade']);

    expect(
      processRunner.recordedCalls,
      orderedEquals(<ProcessCall>[
        ProcessCall(
          'flutter',
          const <String>['pub', 'downgrade'],
          plugin.path,
        ),
        ProcessCall(
          'flutter',
          const <String>['pub', 'get'],
          plugin.path,
        ),
        ProcessCall(
          'dart',
          const <String>['analyze', '--fatal-infos'],
          plugin.path,
        ),
      ]),
    );
  });

  group('verifies analysis settings', () {
    test('fails analysis_options.yaml', () async {
      createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Found an extra analysis_options.yaml at /packages/foo/analysis_options.yaml'),
          contains('  foo:\n'
              '    Unexpected local analysis options'),
        ]),
      );
    });

    test('fails .analysis_options', () async {
      createFakePlugin('foo', packagesDir,
          extraFiles: <String>['.analysis_options']);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Found an extra analysis_options.yaml at /packages/foo/.analysis_options'),
          contains('  foo:\n'
              '    Unexpected local analysis options'),
        ]),
      );
    });

    test('takes an allow list', () async {
      final RepositoryPackage plugin = createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);

      await runCapturingPrint(
          runner, <String>['analyze', '--custom-analysis', 'foo']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('flutter', const <String>['pub', 'get'], plugin.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin.path),
          ]));
    });

    test('ignores analysis options in the plugin .symlinks directory',
        () async {
      final RepositoryPackage plugin = createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);
      final RepositoryPackage includingPackage =
          createFakePlugin('bar', packagesDir);
      // Simulate the local state of having built 'bar' if it includes 'foo'.
      includingPackage.directory
          .childDirectory('example')
          .childDirectory('ios')
          .childLink('.symlinks')
          .createSync(plugin.directory.path, recursive: true);

      await runCapturingPrint(
          runner, <String>['analyze', '--custom-analysis', 'foo']);
    });

    test('takes an allow config file', () async {
      final RepositoryPackage plugin = createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);
      final File allowFile = packagesDir.childFile('custom.yaml');
      allowFile.writeAsStringSync('- foo');

      await runCapturingPrint(
          runner, <String>['analyze', '--custom-analysis', allowFile.path]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('flutter', const <String>['pub', 'get'], plugin.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin.path),
          ]));
    });

    test('allows an empty config file', () async {
      createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);
      final File allowFile = packagesDir.childFile('custom.yaml');
      allowFile.createSync();

      await expectLater(
          () => runCapturingPrint(
              runner, <String>['analyze', '--custom-analysis', allowFile.path]),
          throwsA(isA<ToolExit>()));
    });

    // See: https://github.com/flutter/flutter/issues/78994
    test('takes an empty allow list', () async {
      createFakePlugin('foo', packagesDir,
          extraFiles: <String>['analysis_options.yaml']);

      await expectLater(
          () => runCapturingPrint(
              runner, <String>['analyze', '--custom-analysis', '']),
          throwsA(isA<ToolExit>()));
    });
  });

  test('skips if requested if "pub get" fails in the resolver', () async {
    final RepositoryPackage plugin = createFakePlugin('foo', packagesDir);

    final FakeProcessInfo failingPubGet = FakeProcessInfo(
        MockProcess(
            exitCode: 1,
            stderr: 'So, because foo depends on both thing_one ^1.0.0 and '
                'thing_two from path, version solving failed.'),
        <String>['pub', 'get']);
    processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
      failingPubGet,
      // The command re-runs failures when --skip-if-resolver-fails is passed
      // to check the output, so provide the same failing outcome.
      failingPubGet,
    ];

    final List<String> output = await runCapturingPrint(
        runner, <String>['analyze', '--skip-if-resolving-fails']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Skipping package due to pub resolution failure.'),
      ]),
    );
    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], plugin.path),
          ProcessCall('flutter', const <String>['pub', 'get'], plugin.path),
        ]));
  });

  test('fails if "pub get" fails', () async {
    createFakePlugin('foo', packagesDir);

    processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['analyze'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Unable to get dependencies'),
      ]),
    );
  });

  test('fails if "pub downgrade" fails', () async {
    createFakePlugin('foo', packagesDir);

    processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'downgrade'])
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['analyze', '--downgrade'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Unable to downgrade dependencies'),
      ]),
    );
  });

  test('fails if "analyze" fails', () async {
    createFakePlugin('foo', packagesDir);

    processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['analyze'])
    ];

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['analyze'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('The following packages had errors:'),
        contains('  foo'),
      ]),
    );
  });

  // Ensure that the command used to analyze flutter/plugins in the Dart repo:
  // https://github.com/dart-lang/sdk/blob/main/tools/bots/flutter/analyze_flutter_plugins.sh
  // continues to work.
  //
  // DO NOT remove or modify this test without a coordination plan in place to
  // modify the script above, as it is run from source, but out-of-repo.
  // Contact stuartmorgan or devoncarew for assistance.
  test('Dart repo analyze command works', () async {
    final RepositoryPackage plugin = createFakePlugin('foo', packagesDir,
        extraFiles: <String>['analysis_options.yaml']);
    final File allowFile = packagesDir.childFile('custom.yaml');
    allowFile.writeAsStringSync('- foo');

    await runCapturingPrint(runner, <String>[
      // DO NOT change this call; see comment above.
      'analyze',
      '--analysis-sdk',
      'foo/bar/baz',
      '--custom-analysis',
      allowFile.path
    ]);

    expect(
      processRunner.recordedCalls,
      orderedEquals(<ProcessCall>[
        ProcessCall(
          'flutter',
          const <String>['pub', 'get'],
          plugin.path,
        ),
        ProcessCall(
          'foo/bar/baz/bin/dart',
          const <String>['analyze', '--fatal-infos'],
          plugin.path,
        ),
      ]),
    );
  });
}
