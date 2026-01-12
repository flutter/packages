// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/update_dependency_command.dart';
import 'package:git/git.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;
  Future<http.Response> Function(http.Request request)? mockHttpResponse;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks();
    final UpdateDependencyCommand command = UpdateDependencyCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
      httpClient:
          MockClient((http.Request request) => mockHttpResponse!(request)),
    );

    runner = CommandRunner<void>(
        'update_dependency_command', 'Test for update-dependency command.');
    runner.addCommand(command);
  });

  /// Adds a dummy 'dependencies:' entries for [dependency] to [package].
  void addDependency(RepositoryPackage package, String dependency,
      {String version = '^1.0.0'}) {
    final List<String> lines = package.pubspecFile.readAsLinesSync();
    final int dependenciesStartIndex = lines.indexOf('dependencies:');
    assert(dependenciesStartIndex != -1);
    lines.insert(dependenciesStartIndex + 1, '  $dependency: $version');
    package.pubspecFile.writeAsStringSync(lines.join('\n'));
  }

  /// Adds a 'dev_dependencies:' section with an entry for [dependency] to
  /// [package].
  void addDevDependency(RepositoryPackage package, String dependency,
      {String version = '^1.0.0'}) {
    final String originalContent = package.pubspecFile.readAsStringSync();
    package.pubspecFile.writeAsStringSync('''
$originalContent

dev_dependencies:
  $dependency: $version
''');
  }

  test('throws if no target is provided', () async {
    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['update-dependency'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Exactly one of the target flags must be provided:'),
      ]),
    );
  });

  test('throws if multiple dependencies specified', () async {
    Error? commandError;
    final List<String> output = await runCapturingPrint(runner, <String>[
      'update-dependency',
      '--pub-package',
      'target_package',
      '--android-dependency',
      'gradle'
    ], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Exactly one of the target flags must be provided:'),
      ]),
    );
  });

  group('pub dependencies', () {
    test('throws if no version is given for an unpublished target', () async {
      mockHttpResponse = (http.Request request) async {
        return http.Response('', 404);
      };

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package'
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('target_package does not exist on pub'),
        ]),
      );
    });

    test('skips if there is no dependency', () async {
      createFakePackage('a_package', packagesDir, examples: <String>[]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: Does not depend on target_package'),
        ]),
      );
    });

    test('skips if the dependency is already the target version', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package', version: '^1.5.0');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: Already depends on ^1.5.0'),
        ]),
      );
    });

    test('logs updates', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Updating to "^1.5.0"'),
        ]),
      );
    });

    test('updates normal dependency', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '^1.5.0');
    });

    test('updates dev dependency', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDevDependency(package, 'target_package');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      final Dependency? dep =
          package.parsePubspec().devDependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '^1.5.0');
    });

    test('updates dependency in example', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      addDevDependency(example, 'target_package');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      final Dependency? dep =
          example.parsePubspec().devDependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '^1.5.0');
    });

    test('uses provided constraint as-is', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package');

      const String providedConstraint = '>=1.6.0 <3.0.0';
      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        providedConstraint
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), providedConstraint);
    });

    test('uses provided version as lower bound for unpinned', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '^1.5.0');
    });

    test('uses provided version as exact version for pinned', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package', version: '1.0.0');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
        '--version',
        '1.5.0'
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '1.5.0');
    });

    test('uses latest pub version as lower bound for unpinned', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package');

      const Map<String, dynamic> targetPackagePubResponse = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '1.0.0',
          '1.5.0',
        ],
      };
      mockHttpResponse = (http.Request request) async {
        if (request.url.pathSegments.last == 'target_package.json') {
          return http.Response(json.encode(targetPackagePubResponse), 200);
        }
        return http.Response('', 500);
      };

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '^1.5.0');
    });

    test('uses latest pub version as exact version for pinned', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, examples: <String>[]);
      addDependency(package, 'target_package', version: '1.0.0');

      const Map<String, dynamic> targetPackagePubResponse = <String, dynamic>{
        'name': 'a',
        'versions': <String>[
          '0.0.1',
          '1.0.0',
          '1.5.0',
        ],
      };
      mockHttpResponse = (http.Request request) async {
        if (request.url.pathSegments.last == 'target_package.json') {
          return http.Response(json.encode(targetPackagePubResponse), 200);
        }
        return http.Response('', 500);
      };

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'target_package',
      ]);

      final Dependency? dep =
          package.parsePubspec().dependencies['target_package'];
      expect(dep, isA<HostedDependency>());
      expect((dep! as HostedDependency).version.toString(), '1.5.0');
    });

    test('regenerates all pigeon files when updating pigeon', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'pigeons/foo.dart',
        'pigeons/bar.dart',
      ]);
      addDependency(package, 'pigeon', version: '1.0.0');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'pigeon',
        '--version',
        '1.5.0',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            'dart',
            const <String>['pub', 'get'],
            package.path,
          ),
          ProcessCall(
            'dart',
            const <String>['run', 'pigeon', '--input', 'pigeons/foo.dart'],
            package.path,
          ),
          ProcessCall(
            'dart',
            const <String>['run', 'pigeon', '--input', 'pigeons/bar.dart'],
            package.path,
          ),
        ]),
      );
    });

    test('warns when regenerating pigeon if there are no pigeon files',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      addDependency(package, 'pigeon', version: '1.0.0');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'pigeon',
        '--version',
        '1.5.0',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No pigeon input files found'),
        ]),
      );
    });

    test('updating pigeon fails if pub get fails', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['pigeons/foo.dart']);
      addDependency(package, 'pigeon', version: '1.0.0');

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'pigeon',
        '--version',
        '1.5.0',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Fetching dependencies failed'),
          contains('Failed to update pigeon files'),
        ]),
      );
    });

    test('updating pigeon fails if running pigeon fails', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['pigeons/foo.dart']);
      addDependency(package, 'pigeon', version: '1.0.0');

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['run', 'pigeon']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'pigeon',
        '--version',
        '1.5.0',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('dart run pigeon failed'),
          contains('Failed to update pigeon files'),
        ]),
      );
    });

    test('regenerates mocks when updating mockito if necessary', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      addDependency(package, 'mockito', version: '1.0.0');
      addDevDependency(package, 'build_runner');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'mockito',
        '--version',
        '1.5.0',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            'dart',
            const <String>['pub', 'get'],
            package.path,
          ),
          ProcessCall(
            'dart',
            const <String>[
              'run',
              'build_runner',
              'build',
              '--delete-conflicting-outputs'
            ],
            package.path,
          ),
        ]),
      );
    });

    test('skips regenerating mocks when there is no build_runner dependency',
        () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      addDependency(package, 'mockito', version: '1.0.0');

      await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'mockito',
        '--version',
        '1.5.0',
      ]);

      expect(processRunner.recordedCalls.isEmpty, true);
    });

    test('updating mockito fails if pub get fails', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      addDependency(package, 'mockito', version: '1.0.0');
      addDevDependency(package, 'build_runner');

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'mockito',
        '--version',
        '1.5.0',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Fetching dependencies failed'),
          contains('Failed to update mocks'),
        ]),
      );
    });

    test('updating mockito fails if running build_runner fails', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      addDependency(package, 'mockito', version: '1.0.0');
      addDevDependency(package, 'build_runner');

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(
            MockProcess(exitCode: 1), <String>['run', 'build_runner']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'update-dependency',
        '--pub-package',
        'mockito',
        '--version',
        '1.5.0',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('"dart run build_runner build" failed'),
          contains('Failed to update mocks'),
        ]),
      );
    });
  });

  group('Android dependencies', () {
    group('gradle', () {
      test('throws if version format is invalid', () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--android-dependency',
          'gradle',
          '--version',
          '83',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'A version with a valid format (maximum 2-3 numbers separated by period) must be provided.'),
          ]),
        );
      });

      test('skips if example app does not run on Android', () async {
        final RepositoryPackage package =
            createFakePlugin('fake_plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          '8.8.8',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('SKIPPING: No example apps run on Android.'),
          ]),
        );
      });

      test(
          'throws if wrapper does not have distribution URL with expected format',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'example/android/app/gradle/wrapper/gradle-wrapper.properties'
        ]);

        final File gradleWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        gradleWrapperPropertiesFile.writeAsStringSync('''
How is it even possible that I didn't specify a Gradle distribution?
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          '8.8.8',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Unable to find a gradle version entry to update for ${package.displayName}/example.'),
          ]),
        );
      });

      test('succeeds if example app has android/app/gradle directory structure',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'example/android/app/gradle/wrapper/gradle-wrapper.properties'
        ]);
        const String newGradleVersion = '8.8.8';

        final File gradleWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        gradleWrapperPropertiesFile.writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

        await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          newGradleVersion,
        ]);

        final String updatedGradleWrapperPropertiesContents =
            gradleWrapperPropertiesFile.readAsStringSync();
        expect(
            updatedGradleWrapperPropertiesContents,
            contains(
                r'distributionUrl=https\://services.gradle.org/distributions/'
                'gradle-$newGradleVersion-all.zip'));
      });

      test('succeeds if example app has android/gradle directory structure',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'example/android/gradle/wrapper/gradle-wrapper.properties'
        ]);
        const String newGradleVersion = '9.9';

        final File gradleWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        gradleWrapperPropertiesFile.writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

        await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          newGradleVersion,
        ]);

        final String updatedGradleWrapperPropertiesContents =
            gradleWrapperPropertiesFile.readAsStringSync();
        expect(
            updatedGradleWrapperPropertiesContents,
            contains(
                r'distributionUrl=https\://services.gradle.org/distributions/'
                'gradle-$newGradleVersion-all.zip'));
      });

      test(
          'succeeds if example app has android/gradle and android/app/gradle directory structure',
          () async {
        final RepositoryPackage package =
            createFakePlugin('fake_plugin', packagesDir, extraFiles: <String>[
          'example/android/gradle/wrapper/gradle-wrapper.properties',
          'example/android/app/gradle/wrapper/gradle-wrapper.properties'
        ]);
        const String newGradleVersion = '9.9';

        final File gradleWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        final File gradleAppWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        gradleWrapperPropertiesFile.writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

        gradleAppWrapperPropertiesFile.writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

        await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          newGradleVersion,
        ]);

        final String updatedGradleWrapperPropertiesContents =
            gradleWrapperPropertiesFile.readAsStringSync();
        final String updatedGradleAppWrapperPropertiesContents =
            gradleAppWrapperPropertiesFile.readAsStringSync();
        expect(
            updatedGradleWrapperPropertiesContents,
            contains(
                r'distributionUrl=https\://services.gradle.org/distributions/'
                'gradle-$newGradleVersion-all.zip'));
        expect(
            updatedGradleAppWrapperPropertiesContents,
            contains(
                r'distributionUrl=https\://services.gradle.org/distributions/'
                'gradle-$newGradleVersion-all.zip'));
      });

      test('succeeds if one example app runs on Android and another does not',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, examples: <String>[
          'example_1',
          'example_2'
        ], extraFiles: <String>[
          'example/example_2/android/app/gradle/wrapper/gradle-wrapper.properties'
        ]);
        const String newGradleVersion = '8.8.8';

        final File gradleWrapperPropertiesFile = package.directory
            .childDirectory('example')
            .childDirectory('example_2')
            .childDirectory('android')
            .childDirectory('app')
            .childDirectory('gradle')
            .childDirectory('wrapper')
            .childFile('gradle-wrapper.properties');

        gradleWrapperPropertiesFile.writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

        await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'gradle',
          '--version',
          newGradleVersion,
        ]);

        final String updatedGradleWrapperPropertiesContents =
            gradleWrapperPropertiesFile.readAsStringSync();
        expect(
            updatedGradleWrapperPropertiesContents,
            contains(
                r'distributionUrl=https\://services.gradle.org/distributions/'
                'gradle-$newGradleVersion-all.zip'));
      });
    });

    group('compileSdk/compileSdkForExamples', () {
      // Tests if the compileSdk version is updated for the provided
      // build.gradle file and new compileSdk version to update to.
      Future<void> testCompileSdkVersionUpdated(
          {required RepositoryPackage package,
          required File buildGradleFile,
          required String oldCompileSdkVersion,
          required String newCompileSdkVersion,
          bool runForExamples = false,
          bool checkForDeprecatedCompileSdkVersion = false}) async {
        buildGradleFile.writeAsStringSync('''
android {
    // Conditional for compatibility with AGP <4.2.
    if (project.android.hasProperty("namespace")) {
        namespace 'io.flutter.plugins.pathprovider'
    }
    ${checkForDeprecatedCompileSdkVersion ? 'compileSdkVersion' : 'compileSdk'} $oldCompileSdkVersion
''');

        await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          if (runForExamples) 'compileSdkForExamples' else 'compileSdk',
          '--version',
          newCompileSdkVersion,
        ]);

        final String updatedBuildGradleContents =
            buildGradleFile.readAsStringSync();
        // compileSdkVersion is now deprecated, so if the tool finds any
        // instances of compileSdk OR compileSdkVersion, it should change it
        // to compileSdk. See https://developer.android.com/reference/tools/gradle-api/7.2/com/android/build/api/dsl/CommonExtension#compileSdkVersion(kotlin.Int).
        expect(updatedBuildGradleContents,
            contains('compileSdk $newCompileSdkVersion'));
      }

      test('throws if version format is invalid for compileSdk', () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--android-dependency',
          'compileSdk',
          '--version',
          '834',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'A valid Android SDK version number (1-2 digit numbers) must be provided.'),
          ]),
        );
      });

      test('throws if version format is invalid for compileSdkForExamples',
          () async {
        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--android-dependency',
          'compileSdkForExamples',
          '--version',
          '438',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'A valid Android SDK version number (1-2 digit numbers) must be provided.'),
          ]),
        );
      });

      test('skips if plugin does not run on Android', () async {
        final RepositoryPackage package =
            createFakePlugin('fake_plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'compileSdk',
          '--version',
          '34',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'SKIPPING: Package ${package.displayName} does not run on Android.'),
          ]),
        );
      });

      test('skips if plugin example does not run on Android', () async {
        final RepositoryPackage package =
            createFakePlugin('fake_plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'compileSdkForExamples',
          '--version',
          '34',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('SKIPPING: No example apps run on Android.'),
          ]),
        );
      });

      test(
          'throws if build configuration file does not have compileSdk version with expected format for compileSdk',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir,
            extraFiles: <String>['android/build.gradle']);

        final File buildGradleFile = package.directory
            .childDirectory('android')
            .childFile('build.gradle');

        buildGradleFile.writeAsStringSync('''
How is it even possible that I didn't specify a compileSdk version?
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'compileSdk',
          '--version',
          '34',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Unable to find a compileSdk version entry to update for ${package.displayName}.'),
          ]),
        );
      });

      test(
          'throws if build configuration file does not have compileSdk version with expected format for compileSdkForExamples',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir,
            extraFiles: <String>['example/android/app/build.gradle']);

        final File buildGradleFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childFile('build.gradle');

        buildGradleFile.writeAsStringSync('''
How is it even possible that I didn't specify a compileSdk version?
''');

        Error? commandError;
        final List<String> output = await runCapturingPrint(runner, <String>[
          'update-dependency',
          '--packages',
          package.displayName,
          '--android-dependency',
          'compileSdkForExamples',
          '--version',
          '34',
        ], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Unable to find a compileSdkForExamples version entry to update for ${package.displayName}/example.'),
          ]),
        );
      });

      test(
          'succeeds if plugin runs on Android and valid version is supplied for compileSdkVersion entry',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'android/build.gradle',
          'example/android/app/build.gradle'
        ]);
        final File buildGradleFile = package.directory
            .childDirectory('android')
            .childFile('build.gradle');

        await testCompileSdkVersionUpdated(
            package: package,
            buildGradleFile: buildGradleFile,
            oldCompileSdkVersion: '8',
            newCompileSdkVersion: '16',
            checkForDeprecatedCompileSdkVersion: true);
      });

      test(
          'succeeds if plugin example runs on Android and valid version is supplied for compileSdkVersion entry',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'android/build.gradle',
          'example/android/app/build.gradle'
        ]);
        final File exampleBuildGradleFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childFile('build.gradle');

        await testCompileSdkVersionUpdated(
            package: package,
            buildGradleFile: exampleBuildGradleFile,
            oldCompileSdkVersion: '8',
            newCompileSdkVersion: '16',
            runForExamples: true,
            checkForDeprecatedCompileSdkVersion: true);
      });

      test(
          'succeeds if plugin runs on Android and valid version is supplied for compileSdk entry',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'android/build.gradle',
          'example/android/app/build.gradle'
        ]);

        final File buildGradleFile = package.directory
            .childDirectory('android')
            .childFile('build.gradle');
        await testCompileSdkVersionUpdated(
            package: package,
            buildGradleFile: buildGradleFile,
            oldCompileSdkVersion: '8',
            newCompileSdkVersion: '16');
      });

      test(
          'succeeds if plugin example runs on Android and valid version is supplied for compileSdk entry',
          () async {
        final RepositoryPackage package = createFakePlugin(
            'fake_plugin', packagesDir, extraFiles: <String>[
          'android/build.gradle',
          'example/android/app/build.gradle'
        ]);

        final File exampleBuildGradleFile = package.directory
            .childDirectory('example')
            .childDirectory('android')
            .childDirectory('app')
            .childFile('build.gradle');
        await testCompileSdkVersionUpdated(
            package: package,
            buildGradleFile: exampleBuildGradleFile,
            oldCompileSdkVersion: '33',
            newCompileSdkVersion: '34',
            runForExamples: true);
      });
    });
  });
}
