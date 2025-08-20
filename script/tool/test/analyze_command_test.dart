// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/analyze_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late RecordingProcessRunner gitProcessRunner;
  late CommandRunner<void> runner;

  setUp(() {
    mockPlatform = MockPlatform();
    final GitDir gitDir;
    (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
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

  test('throws if no analysis options are included', () async {
    createFakePackage('a', packagesDir);

    await expectLater(
        () => runCapturingPrint(runner, <String>['analyze', '--no-dart']),
        throwsA(isA<ToolExit>()));
  });

  group('result aggregation', () {
    test('repeorts failure if any analysis fails', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline),
        platformIOS: const PlatformDetails(PlatformSupport.inline),
        platformMacOS: const PlatformDetails(PlatformSupport.inline),
      });

      // Simulate Android analysis failure only.
      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--ios', '--macos'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
            ],
          ));
    });

    test('reports skip if everything is skipped', () async {
      createFakePlugin('plugin', packagesDir);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'analyze',
        '--no-dart',
        '--android',
        '--ios',
        '--macos',
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('SKIPPING:'),
          ]));

      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('reports success for a mixture of skip and success', () async {
      createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline)
          });

      final List<String> output = await runCapturingPrint(runner, <String>[
        'analyze',
        '--no-dart',
        '--android',
        '--ios',
        '--macos',
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('No issues found'),
          ]));
      expect(
          output,
          isNot(containsAllInOrder(<Matcher>[
            contains('SKIPPING:'),
          ])));
    });
  });

  group('dart analyze', () {
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
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin2.path),
          ]));
    });

    test('skips flutter pub get for examples', () async {
      final RepositoryPackage plugin1 = createFakePlugin('a', packagesDir);

      await runCapturingPrint(runner, <String>['analyze']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('flutter', const <String>['pub', 'get'], plugin1.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin1.path),
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
            ProcessCall(
                'dart',
                const <String>['analyze', '--fatal-infos', 'lib'],
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
            ProcessCall(
                'dart',
                const <String>['analyze', '--fatal-infos', 'lib'],
                mainPackage.path),
          ]));
    });

    test("don't elide a non-contained example package", () async {
      final RepositoryPackage plugin1 = createFakePlugin('a', packagesDir);
      final RepositoryPackage plugin2 =
          createFakePlugin('example', packagesDir);

      await runCapturingPrint(runner, <String>['analyze']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('flutter', const <String>['pub', 'get'], plugin1.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin1.path),
            ProcessCall('flutter', const <String>['pub', 'get'], plugin2.path),
            ProcessCall('dart', const <String>['analyze', '--fatal-infos'],
                plugin2.path),
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
            () => runCapturingPrint(runner,
                <String>['analyze', '--custom-analysis', allowFile.path]),
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

    group('file filtering', () {
      test('runs command for changes to Dart source', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(stdout: '''
packages/package_a/foo.dart
''')),
        ];

        final List<String> output =
            await runCapturingPrint(runner, <String>['analyze']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for package_a'),
            ]));
      });

      const List<String> files = <String>[
        'foo.java',
        'foo.kt',
        'foo.m',
        'foo.swift',
        'foo.c',
        'foo.cc',
        'foo.cpp',
        'foo.h',
      ];
      for (final String file in files) {
        test('skips command for changes to non-Dart source $file', () async {
          createFakePackage('package_a', packagesDir);

          gitProcessRunner.mockProcessesForExecutable['git-diff'] =
              <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stdout: '''
packages/package_a/$file
''')),
          ];

          final List<String> output =
              await runCapturingPrint(runner, <String>['analyze']);

          expect(
              output,
              isNot(containsAllInOrder(<Matcher>[
                contains('Running for package_a'),
              ])));
          expect(
              output,
              containsAllInOrder(<Matcher>[
                contains('SKIPPING ALL PACKAGES'),
              ]));
        });
      }

      test('skips commands if all files should be ignored', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(stdout: '''
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
''')),
        ];

        final List<String> output =
            await runCapturingPrint(runner, <String>['analyze']);

        expect(
            output,
            isNot(containsAllInOrder(<Matcher>[
              contains('Running for package_a'),
            ])));
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING ALL PACKAGES'),
            ]));
      });
    });
  });

  group('gradle lint', () {
    test('runs gradle lint', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });

      final Directory androidDir =
          plugin.getExamples().first.platformDirectory(FlutterPlatform.android);

      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            androidDir.childFile('gradlew').path,
            const <String>['plugin1:lintDebug'],
            androidDir.path,
          ),
        ]),
      );

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin1'),
            contains('No issues found!'),
          ]));
    });

    test('runs on all examples', () async {
      final List<String> examples = <String>['example1', 'example2'];
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          examples: examples,
          extraFiles: <String>[
            'example/example1/android/gradlew',
            'example/example2/android/gradlew',
          ],
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });

      final Iterable<Directory> exampleAndroidDirs = plugin.getExamples().map(
          (RepositoryPackage example) =>
              example.platformDirectory(FlutterPlatform.android));

      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          for (final Directory directory in exampleAndroidDirs)
            ProcessCall(
              directory.childFile('gradlew').path,
              const <String>['plugin1:lintDebug'],
              directory.path,
            ),
        ]),
      );

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin1'),
            contains('No issues found!'),
          ]));
    });

    test('runs --config-only build if gradlew is missing', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });

      final Directory androidDir =
          plugin.getExamples().first.platformDirectory(FlutterPlatform.android);

      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            getFlutterCommand(mockPlatform),
            const <String>['build', 'apk', '--config-only'],
            plugin.getExamples().first.directory.path,
          ),
          ProcessCall(
            androidDir.childFile('gradlew').path,
            const <String>['plugin1:lintDebug'],
            androidDir.path,
          ),
        ]),
      );

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin1'),
            contains('No issues found!'),
          ]));
    });

    test('fails if gradlew generation fails', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Unable to configure Gradle project'),
            ],
          ));
    });

    test('fails if linting finds issues', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The following packages had errors:'),
            ],
          ));
    });

    test('skips non-Android plugins', () async {
      createFakePlugin('plugin1', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Package does not contain native Android plugin code')
            ],
          ));
    });

    test('skips non-inline plugins', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.federated)
          });

      final List<String> output = await runCapturingPrint(
          runner, <String>['analyze', '--android', '--no-dart']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Package does not contain native Android plugin code')
            ],
          ));
    });

    group('file filtering', () {
      const List<String> files = <String>[
        'foo.java',
        'foo.kt',
      ];
      for (final String file in files) {
        test('runs command for changes to $file', () async {
          createFakePackage('package_a', packagesDir);

          gitProcessRunner.mockProcessesForExecutable['git-diff'] =
              <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stdout: '''
packages/package_a/$file
''')),
          ];

          final List<String> output = await runCapturingPrint(
              runner, <String>['analyze', '--android', '--no-dart']);

          expect(
              output,
              containsAllInOrder(<Matcher>[
                contains('Running for package_a'),
              ]));
        });
      }

      test('skips commands if all files should be ignored', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(stdout: '''
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
packages/package_a/lib/foo.dart
''')),
        ];

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--android', '--no-dart']);

        expect(
            output,
            isNot(containsAllInOrder(<Matcher>[
              contains('Running for package_a'),
            ])));
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING ALL PACKAGES'),
            ]));
      });
    });
  });

  group('Xcode analyze', () {
    test('temporarily disables Swift Package Manager', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>[], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      await runCapturingPrint(runner, <String>[
        'analyze',
        '--no-dart',
        '--ios',
      ]);

      // Ensure that SwiftPM was disabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: false')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: false'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);
    });

    group('iOS', () {
      test('skip if iOS is not supported', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--ios']);
        expect(
            output,
            contains(
                contains('Package does not contain native iOS plugin code')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if iOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--ios']);
        expect(
            output,
            contains(
                contains('Package does not contain native iOS plugin code')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for iOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--ios',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('plugin/example (iOS) passed analysis.')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('passes min iOS deployment version when requested', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--ios',
          '--ios-min-version=14.0'
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('plugin/example (iOS) passed analysis.')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'IPHONEOS_DEPLOYMENT_TARGET=14.0',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1))
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>[
            'analyze',
            '--no-dart',
            '--ios',
          ],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('The following packages had errors:'),
              contains('  plugin'),
            ]));
      });
    });

    group('macOS', () {
      test('skip if macOS is not supported', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--macos']);
        expect(
            output,
            contains(
                contains('Package does not contain native macOS plugin code')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if macOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.federated),
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--macos']);
        expect(
            output,
            contains(
                contains('Package does not contain native macOS plugin code')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for macOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--macos',
        ]);

        expect(output,
            contains(contains('plugin/example (macOS) passed analysis.')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('passes min macOS deployment version when requested', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--macos',
          '--macos-min-version=12.0'
        ]);

        expect(output,
            contains(contains('plugin/example (macOS) passed analysis.')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'MACOSX_DEPLOYMENT_TARGET=12.0',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1))
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--macos'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('  plugin'),
          ]),
        );
      });
    });

    group('combined', () {
      test('runs both iOS and macOS when supported', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline),
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAll(<Matcher>[
              contains('plugin/example (iOS) passed analysis.'),
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only macOS for a macOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only iOS for a iOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'analyze',
          '--no-dart',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(
                <Matcher>[contains('plugin/example (iOS) passed analysis.')]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });
    });

    group('file filtering', () {
      const List<String> files = <String>[
        'foo.m',
        'foo.swift',
        'foo.cc',
        'foo.cpp',
        'foo.h',
      ];
      for (final String file in files) {
        test('runs command for changes to $file', () async {
          createFakePackage('package_a', packagesDir);

          gitProcessRunner.mockProcessesForExecutable['git-diff'] =
              <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stdout: '''
packages/package_a/$file
''')),
          ];

          final List<String> output = await runCapturingPrint(
              runner, <String>['analyze', '--no-dart', '--ios']);

          expect(
              output,
              containsAllInOrder(<Matcher>[
                contains('Running for package_a'),
              ]));
        });
      }

      test('skips commands if all files should be ignored', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(stdout: '''
.gemini/config.yaml
AGENTS.md
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
packages/package_a/lib/foo.dart
''')),
        ];

        final List<String> output = await runCapturingPrint(
            runner, <String>['analyze', '--no-dart', '--ios']);

        expect(
            output,
            isNot(containsAllInOrder(<Matcher>[
              contains('Running for package_a'),
            ])));
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING ALL PACKAGES'),
            ]));
      });
    });
  });
}
