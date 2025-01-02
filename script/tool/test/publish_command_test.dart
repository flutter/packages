// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/publish_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'common/package_command_test.mocks.dart';
import 'mocks.dart';
import 'util.dart';

void main() {
  late MockPlatform platform;
  late Directory packagesDir;
  late MockGitDir gitDir;
  late TestProcessRunner processRunner;
  late PublishCommand command;
  late CommandRunner<void> commandRunner;
  late MockStdin mockStdin;
  late FileSystem fileSystem;
  // Map of package name to mock response.
  late Map<String, Map<String, dynamic>> mockHttpResponses;

  void createMockCredentialFile() {
    fileSystem.file(command.credentialsPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('some credential');
  }

  setUp(() async {
    platform = MockPlatform(isLinux: true);
    platform.environment['HOME'] = '/home';
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);
    processRunner = TestProcessRunner();

    mockHttpResponses = <String, Map<String, dynamic>>{};
    final MockClient mockClient = MockClient((http.Request request) async {
      final String packageName =
          request.url.pathSegments.last.replaceAll('.json', '');
      final Map<String, dynamic>? response = mockHttpResponses[packageName];
      if (response != null) {
        return http.Response(json.encode(response), 200);
      }
      // Default to simulating the plugin never having been published.
      return http.Response('', 404);
    });

    gitDir = MockGitDir();
    when(gitDir.path).thenReturn(packagesDir.parent.path);
    when(gitDir.runCommand(any, throwOnError: anyNamed('throwOnError')))
        .thenAnswer((Invocation invocation) {
      final List<String> arguments =
          invocation.positionalArguments[0]! as List<String>;
      // Route git calls through the process runner, to make mock output
      // consistent with outer processes. Attach the first argument to the
      // command to make targeting the mock results easier.
      final String gitCommand = arguments.removeAt(0);
      return processRunner.run('git-$gitCommand', arguments);
    });

    mockStdin = MockStdin();
    command = PublishCommand(
      packagesDir,
      platform: platform,
      processRunner: processRunner,
      stdinput: mockStdin,
      gitDir: gitDir,
      httpClient: mockClient,
    );
    commandRunner = CommandRunner<void>('tester', '')..addCommand(command);
  });

  group('Initial validation', () {
    test('refuses to proceed with dirty files', () async {
      final RepositoryPackage plugin =
          createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['git-status'] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '?? ${plugin.directory.childFile('tmp').path}\n'))
      ];

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains("There are files in the package directory that haven't "
                'been saved in git. Refusing to publish these files:\n\n'
                '?? /packages/foo/tmp\n\n'
                'If the directory should be clean, you can run `git clean -xdf && '
                'git reset --hard HEAD` to wipe all local changes.'),
            contains('foo:\n'
                '    uncommitted changes'),
          ]));
    });

    test("fails immediately if the remote doesn't exist", () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['git-remote'] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          commandRunner, <String>['publish', '--packages=foo'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Unable to find URL for remote upstream; cannot push tags'),
          ]));
    });
  });

  group('pre-publish script', () {
    test('runs if present', () async {
      final RepositoryPackage package =
          createFakePackage('foo', packagesDir, examples: <String>[]);
      package.prePublishScript.createSync(recursive: true);

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running pre-publish hook tool/pre_publish.dart...'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(<ProcessCall>[
            ProcessCall(
                'dart',
                const <String>[
                  'pub',
                  'get',
                ],
                package.directory.path),
            ProcessCall(
                'dart',
                const <String>[
                  'run',
                  'tool/pre_publish.dart',
                ],
                package.directory.path),
          ]));
    });

    test('causes command failure if it fails', () async {
      final RepositoryPackage package = createFakePackage('foo', packagesDir,
          isFlutter: true, examples: <String>[]);
      package.prePublishScript.createSync(recursive: true);

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1),
            <String>['run']), // run tool/pre_publish.dart
      ];

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Pre-publish script failed.'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          containsAllInOrder(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(platform),
                const <String>[
                  'pub',
                  'get',
                ],
                package.directory.path),
            ProcessCall(
                'dart',
                const <String>[
                  'run',
                  'tool/pre_publish.dart',
                ],
                package.directory.path),
          ]));
    });
  });

  group('Publishes package', () {
    test('while showing all output from pub publish to the user', () async {
      createFakePlugin('plugin1', packagesDir, examples: <String>[]);
      createFakePlugin('plugin2', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(
            MockProcess(
                stdout: 'Foo',
                stderr: 'Bar',
                stdoutEncoding: utf8,
                stderrEncoding: utf8),
            <String>['pub', 'publish']), // publish for plugin1
        FakeProcessInfo(
            MockProcess(
                stdout: 'Baz', stdoutEncoding: utf8, stderrEncoding: utf8),
            <String>['pub', 'publish']), // publish for plugin2
      ];

      final List<String> output = await runCapturingPrint(
          commandRunner, <String>['publish', '--packages=plugin1,plugin2']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running `pub publish ` in /packages/plugin1...'),
            contains('Foo'),
            contains('Bar'),
            contains('Package published!'),
            contains('Running `pub publish ` in /packages/plugin2...'),
            contains('Baz'),
            contains('Package published!'),
          ]));
    });

    test('forwards input from the user to `pub publish`', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      mockStdin.mockUserInputs.add(utf8.encode('user input'));

      await runCapturingPrint(
          commandRunner, <String>['publish', '--packages=foo']);

      expect(processRunner.mockPublishProcess.stdinMock.lines,
          contains('user input'));
    });

    test('forwards --pub-publish-flags to pub publish', () async {
      final RepositoryPackage plugin =
          createFakePlugin('foo', packagesDir, examples: <String>[]);

      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--pub-publish-flags',
        '--dry-run,--server=bar'
      ]);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              'flutter',
              const <String>['pub', 'publish', '--dry-run', '--server=bar'],
              plugin.path)));
    });

    test(
        '--skip-confirmation flag automatically adds --force to --pub-publish-flags',
        () async {
      createMockCredentialFile();
      final RepositoryPackage plugin =
          createFakePlugin('foo', packagesDir, examples: <String>[]);

      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--skip-confirmation',
        '--pub-publish-flags',
        '--server=bar'
      ]);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              'flutter',
              const <String>['pub', 'publish', '--server=bar', '--force'],
              plugin.path)));
    });

    test('--force is only added once, regardless of plugin count', () async {
      createMockCredentialFile();
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin_a', packagesDir, examples: <String>[]);
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin_b', packagesDir, examples: <String>[]);

      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=plugin_a,plugin_b',
        '--skip-confirmation',
        '--pub-publish-flags',
        '--server=bar'
      ]);

      expect(
          processRunner.recordedCalls,
          containsAllInOrder(<ProcessCall>[
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--server=bar', '--force'],
                plugin1.path),
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--server=bar', '--force'],
                plugin2.path),
          ]));
    });

    test('creates credential file from envirnoment variable if necessary',
        () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);
      const String credentials = 'some credential';
      platform.environment['PUB_CREDENTIALS'] = credentials;

      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--skip-confirmation',
        '--pub-publish-flags',
        '--server=bar'
      ]);

      final File credentialFile = fileSystem.file(command.credentialsPath);
      expect(credentialFile.existsSync(), true);
      expect(credentialFile.readAsStringSync(), credentials);
    });

    test('throws if pub publish fails', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 128), <String>['pub', 'publish'])
      ];

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Publishing foo failed.'),
          ]));
    });

    test('publish, dry run', () async {
      final RepositoryPackage plugin =
          createFakePlugin('foo', packagesDir, examples: <String>[]);

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--dry-run',
      ]);

      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('=============== DRY RUN ==============='),
            contains('Running for foo'),
            contains('Running `pub publish ` in ${plugin.path}...'),
            contains('Tagging release foo-v0.0.1...'),
            contains('Pushing tag to upstream...'),
            contains('Published foo successfully!'),
          ]));
    });

    test('can publish non-flutter package', () async {
      const String packageName = 'a_package';
      createFakePackage(packageName, packagesDir);

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=$packageName',
      ]);

      expect(
        output,
        containsAllInOrder(
          <Matcher>[
            contains('Running `pub publish ` in /packages/a_package...'),
            contains('Package published!'),
          ],
        ),
      );
    });

    test('skips publish with --tag-for-auto-publish', () async {
      const String packageName = 'a_package';
      createFakePackage(packageName, packagesDir);

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=$packageName',
        '--tag-for-auto-publish',
      ]);

      // There should be no variant of any command containing "publish".
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.toString()),
          isNot(contains(contains('publish'))));
      // The output should indicate that it was tagged, not published.
      expect(
        output,
        containsAllInOrder(
          <Matcher>[
            contains('Tagged a_package successfully!'),
          ],
        ),
      );
    });
  });

  group('Tags release', () {
    test('with the version and name from the pubspec.yaml', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);
      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ]);

      expect(processRunner.recordedCalls,
          contains(const ProcessCall('git-tag', <String>['foo-v0.0.1'], null)));
    });

    test('only if publishing succeeded', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 128), <String>['pub', 'publish']),
      ];

      Error? commandError;
      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Publishing foo failed.'),
          ]));
      expect(
          processRunner.recordedCalls,
          isNot(contains(
              const ProcessCall('git-tag', <String>['foo-v0.0.1'], null))));
    });

    test('when passed --tag-for-auto-publish', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);
      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--tag-for-auto-publish',
      ]);

      expect(processRunner.recordedCalls,
          contains(const ProcessCall('git-tag', <String>['foo-v0.0.1'], null)));
    });
  });

  group('Pushes tags', () {
    test('to upstream by default', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      mockStdin.readLineOutput = 'y';

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
      ]);

      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'foo-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Pushing tag to upstream...'),
            contains('Published foo successfully!'),
          ]));
    });

    test('does not ask for user input if the --skip-confirmation flag is on',
        () async {
      createMockCredentialFile();
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--skip-confirmation',
        '--packages=foo',
      ]);

      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'foo-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Published foo successfully!'),
          ]));
    });

    test('when passed --tag-for-auto-publish', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);
      await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--skip-confirmation',
        '--tag-for-auto-publish',
      ]);

      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'foo-v0.0.1'], null)));
    });

    test('to upstream by default, dry run', () async {
      final RepositoryPackage plugin =
          createFakePlugin('foo', packagesDir, examples: <String>[]);

      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(
          commandRunner, <String>['publish', '--packages=foo', '--dry-run']);

      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('=============== DRY RUN ==============='),
            contains('Running `pub publish ` in ${plugin.path}...'),
            contains('Tagging release foo-v0.0.1...'),
            contains('Pushing tag to upstream...'),
            contains('Published foo successfully!'),
          ]));
    });

    test('to different remotes based on a flag', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      mockStdin.readLineOutput = 'y';

      final List<String> output =
          await runCapturingPrint(commandRunner, <String>[
        'publish',
        '--packages=foo',
        '--remote',
        'origin',
      ]);

      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['origin', 'foo-v0.0.1'], null)));
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Published foo successfully!'),
          ]));
    });
  });

  group('--already-tagged', () {
    test('passes when HEAD has the expected tag', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['git-tag'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess()), // Skip the initializeRun call.
        FakeProcessInfo(MockProcess(stdout: 'foo-v0.0.1\n'),
            <String>['--points-at', 'HEAD'])
      ];

      await runCapturingPrint(commandRunner,
          <String>['publish', '--packages=foo', '--already-tagged']);
    });

    test('fails if HEAD does not have the expected tag', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--packages=foo', '--already-tagged'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The current checkout is not already tagged "foo-v0.0.1"'),
            contains('missing tag'),
          ]));
    });

    test('does not create or push tags', () async {
      createFakePlugin('foo', packagesDir, examples: <String>[]);

      processRunner.mockProcessesForExecutable['git-tag'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess()), // Skip the initializeRun call.
        FakeProcessInfo(MockProcess(stdout: 'foo-v0.0.1\n'),
            <String>['--points-at', 'HEAD'])
      ];

      await runCapturingPrint(commandRunner,
          <String>['publish', '--packages=foo', '--already-tagged']);

      expect(
          processRunner.recordedCalls,
          isNot(contains(
              const ProcessCall('git-tag', <String>['foo-v0.0.1'], null))));
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });
  });

  group('Auto release (all-changed flag)', () {
    test('can release newly created plugins', () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir);
      // federated
      final RepositoryPackage plugin2 = createFakePlugin(
        'plugin2',
        packagesDir.childDirectory('plugin2'),
      );
      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Publishing all packages that have changed relative to "HEAD~"'),
            contains('Running `pub publish ` in ${plugin1.path}...'),
            contains('Running `pub publish ` in ${plugin2.path}...'),
            contains('plugin1 - published'),
            contains('plugin2/plugin2 - published'),
          ]));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.1'], null)));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.1'], null)));
    });

    test('can release newly created plugins, while there are existing plugins',
        () async {
      mockHttpResponses['plugin0'] = <String, dynamic>{
        'name': 'plugin0',
        'versions': <String>['0.0.1'],
      };

      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      // The existing plugin.
      createFakePlugin('plugin0', packagesDir);
      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir);
      // federated
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      // Git results for plugin0 having been released already, and plugin1 and
      // plugin2 being new.
      processRunner.mockProcessesForExecutable['git-tag'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(stdout: 'plugin0-v0.0.1\n'))
      ];
      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];

      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Running `pub publish ` in ${plugin1.path}...\n',
            'Running `pub publish ` in ${plugin2.path}...\n',
          ]));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.1'], null)));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.1'], null)));
    });

    test('can release newly created plugins, dry run', () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>[],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>[],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir);
      // federated
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];
      mockStdin.readLineOutput = 'y';

      final List<String> output = await runCapturingPrint(
          commandRunner, <String>[
        'publish',
        '--all-changed',
        '--base-sha=HEAD~',
        '--dry-run'
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('=============== DRY RUN ==============='),
            contains('Running `pub publish ` in ${plugin1.path}...'),
            contains('Tagging release plugin1-v0.0.1...'),
            contains('Pushing tag to upstream...'),
            contains('Published plugin1 successfully!'),
            contains('Running `pub publish ` in ${plugin2.path}...'),
            contains('Tagging release plugin2-v0.0.1...'),
            contains('Pushing tag to upstream...'),
            contains('Published plugin2 successfully!'),
          ]));
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('version change triggers releases.', () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.1'],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.1'],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final RepositoryPackage plugin2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];

      mockStdin.readLineOutput = 'y';

      final List<String> output2 = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);
      expect(
          output2,
          containsAllInOrder(<Matcher>[
            contains('Running `pub publish ` in ${plugin1.path}...'),
            contains('Published plugin1 successfully!'),
            contains('Running `pub publish ` in ${plugin2.path}...'),
            contains('Published plugin2 successfully!'),
          ]));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.2'], null)));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin2-v0.0.2'], null)));
    });

    test(
        'delete package will not trigger publish but exit the command successfully!',
        () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.1'],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.1'],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));
      plugin2.directory.deleteSync(recursive: true);

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];

      mockStdin.readLineOutput = 'y';

      final List<String> output2 = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);
      expect(
          output2,
          containsAllInOrder(<Matcher>[
            contains('Running `pub publish ` in ${plugin1.path}...'),
            contains('Published plugin1 successfully!'),
            contains(
                'The pubspec file for plugin2/plugin2 does not exist, so no publishing will happen.\nSafe to ignore if the package is deleted in this commit.\n'),
            contains('SKIPPING: package deleted'),
            contains('skipped (with warning)'),
          ]));
      expect(
          processRunner.recordedCalls,
          contains(const ProcessCall(
              'git-push', <String>['upstream', 'plugin1-v0.0.2'], null)));
    });

    test('Existing versions do not trigger release, also prints out message.',
        () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.2'],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.2'],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final RepositoryPackage plugin2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];
      processRunner.mockProcessesForExecutable['git-tag'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: 'plugin1-v0.0.2\n'
                'plugin2-v0.0.2\n'))
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('plugin1 0.0.2 has already been published'),
            contains('SKIPPING: already published'),
            contains('plugin2 0.0.2 has already been published'),
            contains('SKIPPING: already published'),
          ]));

      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test(
        'Existing versions do not trigger release, but fail if the tags do not exist.',
        () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'plugin1',
        'versions': <String>['0.0.2'],
      };

      mockHttpResponses['plugin2'] = <String, dynamic>{
        'name': 'plugin2',
        'versions': <String>['0.0.2'],
      };

      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, version: '0.0.2');
      // federated
      final RepositoryPackage plugin2 = createFakePlugin(
          'plugin2', packagesDir.childDirectory('plugin2'),
          version: '0.0.2');

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.pubspecFile.path}\n'
                '${plugin2.pubspecFile.path}\n'))
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('plugin1 0.0.2 has already been published, '
                'however the git release tag (plugin1-v0.0.2) was not found.'),
            contains('plugin2 0.0.2 has already been published, '
                'however the git release tag (plugin2-v0.0.2) was not found.'),
          ]));
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('No version change does not release any plugins', () async {
      // Non-federated
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir);
      // federated
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir.childDirectory('plugin2'));

      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(
            stdout: '${plugin1.libDirectory.childFile('plugin1.dart').path}\n'
                '${plugin2.libDirectory.childFile('plugin2.dart').path}\n'))
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);

      expect(output, containsAllInOrder(<String>['Ran for 0 package(s)']));
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });

    test('Do not release flutter_plugin_tools', () async {
      mockHttpResponses['plugin1'] = <String, dynamic>{
        'name': 'flutter_plugin_tools',
        'versions': <String>[],
      };

      final RepositoryPackage flutterPluginTools =
          createFakePlugin('flutter_plugin_tools', packagesDir);
      processRunner.mockProcessesForExecutable['git-diff'] = <FakeProcessInfo>[
        FakeProcessInfo(
            MockProcess(stdout: flutterPluginTools.pubspecFile.path))
      ];

      final List<String> output = await runCapturingPrint(commandRunner,
          <String>['publish', '--all-changed', '--base-sha=HEAD~']);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'SKIPPING: publishing flutter_plugin_tools via the tool is not supported')
          ]));
      expect(
          output.contains(
            'Running `pub publish ` in ${flutterPluginTools.path}...',
          ),
          isFalse);
      expect(
          processRunner.recordedCalls
              .map((ProcessCall call) => call.executable),
          isNot(contains('git-push')));
    });
  });

  group('credential location', () {
    test('Linux with XDG', () async {
      platform = MockPlatform(isLinux: true);
      platform.environment['XDG_CONFIG_HOME'] = '/xdghome/config';
      command = PublishCommand(packagesDir, platform: platform);

      expect(
          command.credentialsPath, '/xdghome/config/dart/pub-credentials.json');
    });

    test('Linux without XDG', () async {
      platform = MockPlatform(isLinux: true);
      platform.environment['HOME'] = '/home';
      command = PublishCommand(packagesDir, platform: platform);

      expect(
          command.credentialsPath, '/home/.config/dart/pub-credentials.json');
    });

    test('macOS', () async {
      platform = MockPlatform(isMacOS: true);
      platform.environment['HOME'] = '/Users/someuser';
      command = PublishCommand(packagesDir, platform: platform);

      expect(command.credentialsPath,
          '/Users/someuser/Library/Application Support/dart/pub-credentials.json');
    });

    test('Windows', () async {
      platform = MockPlatform(isWindows: true);
      platform.environment['APPDATA'] = r'C:\Users\SomeUser\AppData';
      command = PublishCommand(packagesDir, platform: platform);

      expect(command.credentialsPath,
          r'C:\Users\SomeUser\AppData\dart\pub-credentials.json');
    });
  });
}

/// An extension of [RecordingProcessRunner] that stores 'flutter pub publish'
/// calls so that their input streams can be checked in tests.
class TestProcessRunner extends RecordingProcessRunner {
  // Most recent returned publish process.
  late MockProcess mockPublishProcess;

  @override
  Future<io.Process> start(String executable, List<String> args,
      {Directory? workingDirectory}) async {
    final io.Process process =
        await super.start(executable, args, workingDirectory: workingDirectory);
    if (executable == 'flutter' &&
        args.isNotEmpty &&
        args[0] == 'pub' &&
        args[1] == 'publish') {
      mockPublishProcess = process as MockProcess;
    }
    return process;
  }
}

class MockStdin extends Mock implements io.Stdin {
  List<List<int>> mockUserInputs = <List<int>>[];
  final StreamController<List<int>> _controller = StreamController<List<int>>();
  String? readLineOutput;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    mockUserInputs.forEach(_addUserInputsToSteam);
    return _controller.stream.transform(streamTransformer);
  }

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  String? readLineSync(
          {Encoding encoding = io.systemEncoding,
          bool retainNewlines = false}) =>
      readLineOutput;

  void _addUserInputsToSteam(List<int> input) => _controller.add(input);
}
