// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/update_min_sdk_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late FileSystem fileSystem;
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = createPackagesDirectory(fileSystem: fileSystem);

    final UpdateMinSdkCommand command = UpdateMinSdkCommand(
      packagesDir,
    );
    runner = CommandRunner<void>(
        'update_min_sdk_command', 'Test for update_min_sdk_command');
    runner.addCommand(command);
  });

  test('fails if --flutter-min is missing', () async {
    Exception? commandError;
    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
    ], exceptionHandler: (Exception e) {
      commandError = e;
    });

    expect(commandError, isA<UsageException>());
  });

  test('updates Dart when only Dart is present', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        dartConstraint: '>=2.12.0 <4.0.0');

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.3.0', // Corresponds to Dart 2.18.0
    ]);

    final String dartVersion =
        package.parsePubspec().environment?['sdk'].toString() ?? '';
    expect(dartVersion, '>=2.18.0 <4.0.0');
  });

  test('does not update Dart if it is already higher', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        dartConstraint: '>=2.19.0 <4.0.0');

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.3.0', // Corresponds to Dart 2.18.0
    ]);

    final String dartVersion =
        package.parsePubspec().environment?['sdk'].toString() ?? '';
    expect(dartVersion, '>=2.19.0 <4.0.0');
  });

  test('updates both Dart and Flutter when both are present', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        isFlutter: true,
        dartConstraint: '>=2.12.0 <4.0.0',
        flutterConstraint: '>=2.10.0');

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.3.0', // Corresponds to Dart 2.18.0
    ]);

    final String dartVersion =
        package.parsePubspec().environment?['sdk'].toString() ?? '';
    final String flutterVersion =
        package.parsePubspec().environment?['flutter'].toString() ?? '';
    expect(dartVersion, '>=2.18.0 <4.0.0');
    expect(flutterVersion, '>=3.3.0');
  });

  test('does not update Flutter if it is already higher', () async {
    final RepositoryPackage package = createFakePackage(
        'a_package', packagesDir,
        isFlutter: true,
        dartConstraint: '>=2.19.0 <4.0.0',
        flutterConstraint: '>=3.7.0');

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.3.0', // Corresponds to Dart 2.18.0
    ]);

    final String dartVersion =
        package.parsePubspec().environment?['sdk'].toString() ?? '';
    final String flutterVersion =
        package.parsePubspec().environment?['flutter'].toString() ?? '';
    expect(dartVersion, '>=2.19.0 <4.0.0');
    expect(flutterVersion, '>=3.7.0');
  });
}
