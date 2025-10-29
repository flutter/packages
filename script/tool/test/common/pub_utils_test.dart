// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/pub_utils.dart';
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

  test('runs with Dart for a non-Flutter package by default', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    final MockPlatform platform = MockPlatform();

    await runPubGet(package, processRunner, platform);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
        ]));
  });

  test('runs with Flutter for a Flutter package by default', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir, isFlutter: true);
    final MockPlatform platform = MockPlatform();

    await runPubGet(package, processRunner, platform);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], package.path),
        ]));
  });

  test('runs with Flutter for a Dart package when requested', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    final MockPlatform platform = MockPlatform();

    await runPubGet(package, processRunner, platform, alwaysUseFlutter: true);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['pub', 'get'], package.path),
        ]));
  });

  test('uses the correct Flutter command on Windows', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir, isFlutter: true);
    final MockPlatform platform = MockPlatform(isWindows: true);

    await runPubGet(package, processRunner, platform);

    expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
              'flutter.bat', const <String>['pub', 'get'], package.path),
        ]));
  });

  test('reports success', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    final MockPlatform platform = MockPlatform();

    final bool result = await runPubGet(package, processRunner, platform);

    expect(result, true);
  });

  test('reports failure', () async {
    final RepositoryPackage package =
        createFakePackage('a_package', packagesDir);
    final MockPlatform platform = MockPlatform();

    processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
    ];

    final bool result = await runPubGet(package, processRunner, platform);

    expect(result, false);
  });
}
