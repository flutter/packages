// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/firebase_test_lab_command.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('FirebaseTestLabCommand', () {
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late RecordingProcessRunner gitProcessRunner;

    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final FirebaseTestLabCommand command = FirebaseTestLabCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>(
          'firebase_test_lab_command', 'Test for $FirebaseTestLabCommand');
      runner.addCommand(command);
    });

    void writeJavaTestFile(RepositoryPackage plugin, String relativeFilePath,
        {String runnerClass = 'FlutterTestRunner'}) {
      childFileWithSubcomponents(
              plugin.directory, p.posix.split(relativeFilePath))
          .writeAsStringSync('''
@DartIntegrationTest
@RunWith($runnerClass.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<FlutterActivity> rule = new ActivityTestRule<>(FlutterActivity.class);
}
''');
    }

    test('fails if gcloud auth fails', () async {
      processRunner.mockProcessesForExecutable['gcloud'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['auth'])
      ];

      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      Error? commandError;
      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--service-key=/path/to/key',
      ], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to activate gcloud account.'),
          ]));
    });

    test('retries gcloud set', () async {
      processRunner.mockProcessesForExecutable['gcloud'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['auth']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['config']),
      ];

      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--service-key=/path/to/key',
        '--project=a-project'
      ]);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                'Warning: gcloud config set returned a non-zero exit code. Continuing anyway.'),
          ]));
    });

    test('only runs gcloud configuration once', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin1 =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin1, javaTestFileRelativePath);
      final RepositoryPackage plugin2 =
          createFakePlugin('plugin2', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin2, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--project=a-project',
        '--service-key=/path/to/key',
        '--device',
        'model=redfin,version=30',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin1'),
          contains('Firebase project configured.'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('Running for plugin2'),
          contains('Testing example/integration_test/bar_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>['build', 'apk', '--debug', '--config-only'],
              plugin1.getExamples().first.directory.path),
          ProcessCall(
              'gcloud',
              'auth activate-service-account --key-file=/path/to/key'
                  .split(' '),
              null),
          ProcessCall(
              'gcloud', 'config set project a-project'.split(' '), null),
          ProcessCall(
              '/packages/plugin1/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin1/example/android'),
          ProcessCall(
              '/packages/plugin1/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin1/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin1/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin1/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin1/example'),
          ProcessCall(
              'flutter',
              const <String>['build', 'apk', '--debug', '--config-only'],
              plugin2.getExamples().first.directory.path),
          ProcessCall(
              '/packages/plugin2/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin2/example/android'),
          ProcessCall(
              '/packages/plugin2/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin2/example/integration_test/bar_test.dart'
                  .split(' '),
              '/packages/plugin2/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin2/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin2/example'),
        ]),
      );
    });

    test('runs integration tests', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/integration_test/should_not_run.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('Testing example/integration_test/foo_test.dart...'),
        ]),
      );
      expect(output, isNot(contains('test/plugin_test.dart')));
      expect(output,
          isNot(contains('example/integration_test/should_not_run.dart')));

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>['build', 'apk', '--debug', '--config-only'],
              plugin.getExamples().first.directory.path),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/bar_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example/1/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('runs for all examples', () async {
      const List<String> examples = <String>['example1', 'example2'];
      const String javaTestFileExampleRelativePath =
          'android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          examples: examples,
          extraFiles: <String>[
            for (final String example in examples) ...<String>[
              'example/$example/integration_test/a_test.dart',
              'example/$example/android/gradlew',
              'example/$example/$javaTestFileExampleRelativePath',
            ],
          ]);
      for (final String example in examples) {
        writeJavaTestFile(
            plugin, 'example/$example/$javaTestFileExampleRelativePath');
      }

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
        '--device',
        'model=seoul,version=26',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Testing example/example1/integration_test/a_test.dart...'),
          contains('Testing example/example2/integration_test/a_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        containsAll(<ProcessCall>[
          ProcessCall(
              '/packages/plugin/example/example1/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/example1/integration_test/a_test.dart'
                  .split(' '),
              '/packages/plugin/example/example1/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example1/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example/example1'),
          ProcessCall(
              '/packages/plugin/example/example2/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/example2/integration_test/a_test.dart'
                  .split(' '),
              '/packages/plugin/example/example2/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example2/0/ --device model=redfin,version=30 --device model=seoul,version=26'
                  .split(' '),
              '/packages/plugin/example/example2'),
        ]),
      );
    });

    test('fails if a test fails twice', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['gcloud'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1),
            <String>['firebase', 'test']), // integration test #1
        FakeProcessInfo(MockProcess(exitCode: 1),
            <String>['firebase', 'test']), // integration test #1 retry
        FakeProcessInfo(
            MockProcess(), <String>['firebase', 'test']), // integration test #2
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('plugin:\n'
              '    example/integration_test/bar_test.dart failed tests'),
        ]),
      );
    });

    test('passes with warning if a test fails once, then passes on retry',
        () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['gcloud'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1),
            <String>['firebase', 'test']), // integration test #1
        FakeProcessInfo(MockProcess(),
            <String>['firebase', 'test']), // integration test #1 retry
        FakeProcessInfo(
            MockProcess(), <String>['firebase', 'test']), // integration test #2
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Testing example/integration_test/bar_test.dart...'),
          contains('bar_test.dart failed on attempt 1. Retrying...'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('Ran for 1 package(s) (1 with warnings)'),
        ]),
      );
    });

    test('fails for plugins with no androidTest directory', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
      ]);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No androidTest directory found.'),
          contains('The following packages had errors:'),
          contains('plugin:\n'
              '    No tests ran (use --exclude if this is intentional).'),
        ]),
      );
    });

    test('skips for non-plugin packages with no androidTest directory',
        () async {
      createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_package'),
          contains('No androidTest directory found.'),
          contains('No examples support Android.'),
          contains('Skipped 1 package'),
        ]),
      );
    });

    test('fails for packages with no integration test files', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No integration tests were run'),
          contains('The following packages had errors:'),
          contains('plugin:\n'
              '    No tests ran (use --exclude if this is intentional).'),
        ]),
      );
    });

    test('fails for packages with no integration_test runner', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/bar_test.dart',
        'example/integration_test/foo_test.dart',
        'example/integration_test/should_not_run.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      // Use the wrong @RunWith annotation.
      writeJavaTestFile(plugin, javaTestFileRelativePath,
          runnerClass: 'AndroidJUnit4.class');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No integration_test runner found. '
              'See the integration_test package README for setup instructions.'),
          contains('plugin:\n'
              '    No integration_test runner.'),
        ]),
      );
    });

    test('supports kotlin implementation of integration_test runner', () async {
      const String kotlinTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.kt';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'test/plugin_test.dart',
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        kotlinTestFileRelativePath,
      ]);

      // Kotlin equivalent of the test runner
      childFileWithSubcomponents(
              plugin.directory, p.posix.split(kotlinTestFileRelativePath))
          .writeAsStringSync('''
@DartIntegrationTest
@RunWith(FlutterTestRunner::class)
class MainActivityTest {
  @JvmField @Rule var rule = ActivityTestRule(MainActivity::class.java)
}
''');

      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
      );

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Testing example/integration_test/foo_test.dart...'),
          contains('Ran for 1 package')
        ]),
      );
    });

    test('skips packages with no android directory', () async {
      createFakePackage('package', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package'),
          contains('No examples support Android'),
        ]),
      );
      expect(output,
          isNot(contains('Testing example/integration_test/foo_test.dart...')));

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[]),
      );
    });

    test('builds if gradlew is missing', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Running flutter build apk...'),
          contains('Testing example/integration_test/foo_test.dart...'),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            'flutter',
            'build apk --debug --config-only'.split(' '),
            plugin.getExamples().first.directory.path,
          ),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true'.split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    test('fails if building to generate gradlew fails', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['build'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to build example apk'),
          ]));
    });

    test('fails if assembleAndroidTest fails', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <FakeProcessInfo>[
        FakeProcessInfo(
            MockProcess(exitCode: 1), <String>['app:assembleAndroidTest']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Unable to assemble androidTest'),
          ]));
    });

    test('fails if assembleDebug fails', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['app:assembleAndroidTest']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['app:assembleDebug'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Could not build example/integration_test/foo_test.dart'),
            contains('The following packages had errors:'),
            contains('  plugin:\n'
                '    example/integration_test/foo_test.dart failed to build'),
          ]));
    });

    test('experimental flag', () async {
      const String javaTestFileRelativePath =
          'example/android/app/src/androidTest/MainActivityTest.java';
      final RepositoryPackage plugin =
          createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/foo_test.dart',
        'example/android/gradlew',
        javaTestFileRelativePath,
      ]);
      writeJavaTestFile(plugin, javaTestFileRelativePath);

      await runCapturingPrint(runner, <String>[
        'firebase-test-lab',
        '--results-bucket=a_bucket',
        '--device',
        'model=redfin,version=30',
        '--test-run-id',
        'testRunId',
        '--build-id',
        'buildId',
        '--enable-experiment=exp1',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter',
              const <String>[
                'build',
                'apk',
                '--debug',
                '--config-only',
                '--enable-experiment=exp1'
              ],
              plugin.getExamples().first.directory.path),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleAndroidTest -Pverbose=true -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              '/packages/plugin/example/android/gradlew',
              'app:assembleDebug -Pverbose=true -Ptarget=/packages/plugin/example/integration_test/foo_test.dart -Pextra-front-end-options=--enable-experiment%3Dexp1 -Pextra-gen-snapshot-options=--enable-experiment%3Dexp1'
                  .split(' '),
              '/packages/plugin/example/android'),
          ProcessCall(
              'gcloud',
              'firebase test android run --type instrumentation --app build/app/outputs/apk/debug/app-debug.apk --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --timeout 7m --results-bucket=gs://a_bucket --results-dir=plugins_android_test/plugin/buildId/testRunId/example/0/ --device model=redfin,version=30'
                  .split(' '),
              '/packages/plugin/example'),
        ]),
      );
    });

    group('file filtering', () {
      const List<String> files = <String>[
        'pubspec.yaml',
        'foo.dart',
        'foo.java',
        'foo.kt',
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

          final List<String> output = await runCapturingPrint(runner, <String>[
            'firebase-test-lab',
            '--results-bucket=a_bucket',
            '--device',
            'model=redfin,version=30',
          ]);

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
''')),
        ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'firebase-test-lab',
          '--results-bucket=a_bucket',
          '--device',
          'model=redfin,version=30',
        ]);

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
