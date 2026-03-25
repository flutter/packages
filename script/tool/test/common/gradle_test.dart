// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/gradle.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../util.dart';

void main() {
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;

  setUp(() {
    (:packagesDir, :processRunner, gitProcessRunner: _, gitDir: _) =
        configureBaseCommandMocks();
  });

  group('isConfigured', () {
    test('reports true when configured on Windows', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew.bat'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      expect(project.isConfigured(), true);
    });

    test('reports true when configured on non-Windows', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      expect(project.isConfigured(), true);
    });

    test('reports false when not configured on Windows', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/foo'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      expect(project.isConfigured(), false);
    });

    test('reports true when configured on non-Windows', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/foo'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      expect(project.isConfigured(), false);
    });
  });

  group('runCommand', () {
    test('runs without arguments', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 0);
      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            plugin
                .platformDirectory(FlutterPlatform.android)
                .childFile('gradlew')
                .path,
            const <String>['foo'],
            plugin.platformDirectory(FlutterPlatform.android).path,
          ),
        ]),
      );
    });

    test('runs with arguments', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );

      final int exitCode = await project.runCommand(
        'foo',
        arguments: <String>['--bar', '--baz'],
      );

      expect(exitCode, 0);
      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            plugin
                .platformDirectory(FlutterPlatform.android)
                .childFile('gradlew')
                .path,
            const <String>['foo', '--bar', '--baz'],
            plugin.platformDirectory(FlutterPlatform.android).path,
          ),
        ]),
      );
    });

    test('runs with the correct wrapper on Windows', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew.bat'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 0);
      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            plugin
                .platformDirectory(FlutterPlatform.android)
                .childFile('gradlew.bat')
                .path,
            const <String>['foo'],
            plugin.platformDirectory(FlutterPlatform.android).path,
          ),
        ]),
      );
    });

    test('returns error codes', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>['android/gradlew.bat'],
      );
      final project = GradleProject(
        plugin,
        processRunner: processRunner,
        platform: MockPlatform(isWindows: true),
      );

      processRunner.mockProcessesForExecutable[project.gradleWrapper.path] =
          <FakeProcessInfo>[FakeProcessInfo(MockProcess(exitCode: 1))];

      final int exitCode = await project.runCommand('foo');

      expect(exitCode, 1);
    });
  });
}
