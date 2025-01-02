// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/publish_check_command.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('PublishCheckCommand tests', () {
    FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late RecordingProcessRunner processRunner;
    late CommandRunner<void> runner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final PublishCheckCommand publishCheckCommand = PublishCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(publishCheckCommand);
    });

    test('publish check all packages', () async {
      final RepositoryPackage plugin1 = createFakePlugin(
        'plugin_tools_test_package_a',
        packagesDir,
        examples: <String>[],
      );
      final RepositoryPackage plugin2 = createFakePlugin(
        'plugin_tools_test_package_b',
        packagesDir,
        examples: <String>[],
      );

      await runCapturingPrint(runner, <String>['publish-check']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin1.path),
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                plugin2.path),
          ]));
    });

    test('publish prepares dependencies of examples (when present)', () async {
      final RepositoryPackage plugin1 = createFakePlugin(
        'plugin_tools_test_package_a',
        packagesDir,
        examples: <String>['example1', 'example2'],
      );
      final RepositoryPackage plugin2 = createFakePlugin(
        'plugin_tools_test_package_b',
        packagesDir,
        examples: <String>[],
      );

      await runCapturingPrint(runner, <String>['publish-check']);

      // For plugin1, these are the expected pub get calls that will happen
      final Iterable<ProcessCall> pubGetCalls =
          plugin1.getExamples().map((RepositoryPackage example) {
        return ProcessCall(
          getFlutterCommand(mockPlatform),
          const <String>['pub', 'get'],
          example.path,
        );
      });

      expect(pubGetCalls, hasLength(2));
      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          // plugin1 has 2 examples, so there's some 'dart pub get' calls.
          ...pubGetCalls,
          ProcessCall(
              'flutter',
              const <String>['pub', 'publish', '--', '--dry-run'],
              plugin1.path),
          // plugin2 has no examples, so there's no extra 'dart pub get' calls.
          ProcessCall(
              'flutter',
              const <String>['pub', 'publish', '--', '--dry-run'],
              plugin2.path),
        ]),
      );
    });

    test('fail on negative test', () async {
      createFakePlugin('plugin_tools_test_package_a', packagesDir);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(exitCode: 1, stdout: 'Some error from pub'),
            <String>['pub', 'publish'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Some error from pub'),
          contains('Unable to publish plugin_tools_test_package_a'),
        ]),
      );
    });

    test('fail on bad pubspec', () async {
      final RepositoryPackage package = createFakePlugin('c', packagesDir);
      await package.pubspecFile.writeAsString('bad-yaml');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No valid pubspec found.'),
        ]),
      );
    });

    test('fails if AUTHORS is missing', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      package.authorsFile.deleteSync();

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'No AUTHORS file found. Packages must include an AUTHORS file.'),
        ]),
      );
    });

    test('does not require AUTHORS for third-party', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir.parent
              .childDirectory('third_party')
              .childDirectory('packages'));
      package.authorsFile.deleteSync();

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package'),
        ]),
      );
    });

    test('pass on prerelease if --allow-pre-release flag is on', () async {
      createFakePlugin('d', packagesDir);

      final MockProcess process = MockProcess(
          exitCode: 1,
          stdout: 'Package has 1 warning.\n'
              'Packages with an SDK constraint on a pre-release of the Dart '
              'SDK should themselves be published as a pre-release version.');
      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(process, <String>['pub', 'publish']),
      ];

      expect(
          runCapturingPrint(
              runner, <String>['publish-check', '--allow-pre-release']),
          completes);
    });

    test('fail on prerelease if --allow-pre-release flag is off', () async {
      createFakePlugin('d', packagesDir);

      final MockProcess process = MockProcess(
          exitCode: 1,
          stdout: 'Package has 1 warning.\n'
              'Packages with an SDK constraint on a pre-release of the Dart '
              'SDK should themselves be published as a pre-release version.');
      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(process, <String>['pub', 'publish']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Packages with an SDK constraint on a pre-release of the Dart SDK'),
          contains('Unable to publish d'),
        ]),
      );
    });

    test('Success message on stderr is not printed as an error', () async {
      createFakePlugin('d', packagesDir);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(stdout: 'Package has 0 warnings.'),
            <String>['pub', 'publish']),
      ];

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(output, isNot(contains(contains('ERROR:'))));
    });

    test(
        'runs validation even for packages that are already published and reports failure',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '0.1.0');

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'a_package.json') {
          return http.Response(
              json.encode(<String, dynamic>{
                'name': 'a_package',
                'versions': <String>[
                  '0.0.1',
                  '0.1.0',
                ],
              }),
              200);
        }
        return http.Response('', 500);
      });

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(PublishCheckCommand(packagesDir,
          platform: mockPlatform,
          processRunner: processRunner,
          httpClient: mockClient));

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1, stdout: 'Some error from pub'),
            <String>['pub', 'publish'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to publish a_package'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          contains(
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                package.path),
          ));
    });

    test('skips packages that are marked as not for publishing', () async {
      createFakePackage('a_package', packagesDir,
          version: '0.1.0', publishTo: 'none');

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: Package is marked as unpublishable.'),
        ]),
      );
      expect(processRunner.recordedCalls, isEmpty);
    });

    test(
        'runs validation even for packages that are already published and reports success',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, version: '0.1.0');

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'a_package.json') {
          return http.Response(
              json.encode(<String, dynamic>{
                'name': 'a_package',
                'versions': <String>[
                  '0.0.1',
                  '0.1.0',
                ],
              }),
              200);
        }
        return http.Response('', 500);
      });

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(PublishCheckCommand(packagesDir,
          platform: mockPlatform,
          processRunner: processRunner,
          httpClient: mockClient));

      final List<String> output =
          await runCapturingPrint(runner, <String>['publish-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
              'Package a_package version: 0.1.0 has already been published on pub.'),
        ]),
      );
      expect(
          processRunner.recordedCalls,
          contains(
            ProcessCall(
                'flutter',
                const <String>['pub', 'publish', '--', '--dry-run'],
                package.path),
          ));
    });

    group('pre-publish script', () {
      test('runs if present', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, examples: <String>[]);
        package.prePublishScript.createSync(recursive: true);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'publish-check',
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

      test('runs before publish --dry-run', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, examples: <String>[]);
        package.prePublishScript.createSync(recursive: true);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'publish-check',
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
                    'run',
                    'tool/pre_publish.dart',
                  ],
                  package.directory.path),
              ProcessCall(
                  'flutter',
                  const <String>[
                    'pub',
                    'publish',
                    '--',
                    '--dry-run',
                  ],
                  package.directory.path),
            ]));
      });

      test('causes command failure if it fails', () async {
        final RepositoryPackage package = createFakePackage(
            'a_package', packagesDir,
            isFlutter: true, examples: <String>[]);
        package.prePublishScript.createSync(recursive: true);

        processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1),
              <String>['run']), // run tool/pre_publish.dart
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'publish-check',
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
                  getFlutterCommand(mockPlatform),
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

    test(
        '--machine: Log JSON with status:no-publish and correct human message, if there are no packages need to be published. ',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
          '0.2.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine']);

      expect(output.first, r'''
{
  "status": "no-publish",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Running pub publish --dry-run:",
    "Package no_publish_a version: 0.1.0 has already been published on pub.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "Running pub publish --dry-run:",
    "Package no_publish_b version: 0.2.0 has already been published on pub.",
    "\n",
    "------------------------------------------------------------",
    "Run overview:",
    "  no_publish_a - ran",
    "  no_publish_b - ran",
    "",
    "Ran for 2 package(s)",
    "\n",
    "No issues found!"
  ]
}''');
    });

    test(
        '--machine: Log JSON with status:needs-publish and correct human message, if there is at least 1 plugin needs to be published.',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine']);

      expect(output.first, r'''
{
  "status": "needs-publish",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Running pub publish --dry-run:",
    "Package no_publish_a version: 0.1.0 has already been published on pub.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "Running pub publish --dry-run:",
    "Package no_publish_b is able to be published.",
    "\n",
    "------------------------------------------------------------",
    "Run overview:",
    "  no_publish_a - ran",
    "  no_publish_b - ran",
    "",
    "Ran for 2 package(s)",
    "\n",
    "No issues found!"
  ]
}''');
    });

    test(
        '--machine: Log correct JSON, if there is at least 1 plugin contains error.',
        () async {
      const Map<String, dynamic> httpResponseA = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      const Map<String, dynamic> httpResponseB = <String, dynamic>{
        'name': 'b',
        'versions': <String>[
          '0.0.1',
          '0.1.0',
        ],
      };

      final MockClient mockClient = MockClient((http.Request request) async {
        print('url ${request.url}');
        print(request.url.pathSegments.last);
        if (request.url.pathSegments.last == 'no_publish_a.json') {
          return http.Response(json.encode(httpResponseA), 200);
        } else if (request.url.pathSegments.last == 'no_publish_b.json') {
          return http.Response(json.encode(httpResponseB), 200);
        }
        return http.Response('', 500);
      });
      final PublishCheckCommand command = PublishCheckCommand(packagesDir,
          processRunner: processRunner, httpClient: mockClient);

      runner = CommandRunner<void>(
        'publish_check_command',
        'Test for publish-check command.',
      );
      runner.addCommand(command);

      final RepositoryPackage plugin =
          createFakePlugin('no_publish_a', packagesDir, version: '0.1.0');
      createFakePlugin('no_publish_b', packagesDir, version: '0.2.0');

      await plugin.pubspecFile.writeAsString('bad-yaml');

      bool hasError = false;
      final List<String> output = await runCapturingPrint(
          runner, <String>['publish-check', '--machine'],
          errorHandler: (Error error) {
        expect(error, isA<ToolExit>());
        hasError = true;
      });
      expect(hasError, isTrue);

      expect(output.first, contains(r'''
{
  "status": "error",
  "humanMessage": [
    "\n============================================================\n|| Running for no_publish_a\n============================================================\n",
    "Failed to parse `pubspec.yaml` at /packages/no_publish_a/pubspec.yaml: ParsedYamlException:'''));
      // This is split into two checks since the details of the YamlException
      // aren't controlled by this package, so asserting its exact format would
      // make the test fragile to irrelevant changes in those details.
      expect(output.first, contains(r'''
    "No valid pubspec found.",
    "\n============================================================\n|| Running for no_publish_b\n============================================================\n",
    "url https://pub.dev/packages/no_publish_b.json",
    "no_publish_b.json",
    "Running pub publish --dry-run:",
    "Package no_publish_b is able to be published.",
    "\n",
    "The following packages had errors:",
    "  no_publish_a",
    "See above for full details."
  ]
}'''));
    });
  });
}
