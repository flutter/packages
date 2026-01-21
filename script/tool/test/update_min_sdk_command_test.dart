// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/update_min_sdk_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late Directory packagesDir;
  late CommandRunner<void> runner;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks();

    final command = UpdateMinSdkCommand(packagesDir, gitDir: gitDir);
    runner = CommandRunner<void>(
      'update_min_sdk_command',
      'Test for update_min_sdk_command',
    );
    runner.addCommand(command);
  });

  test('fails if --flutter-min is missing', () async {
    Error? commandError;
    await runCapturingPrint(
      runner,
      <String>['update-min-sdk'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ArgumentError>());
  });

  test('updates Dart when only Dart is present, with manual range', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      dartConstraint: '>=3.0.0 <4.0.0',
    );

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.13.0', // Corresponds to Dart 3.1.0
    ]);

    final dartVersion = package.parsePubspec().environment['sdk'].toString();
    expect(dartVersion, '^3.1.0');
  });

  test('updates Dart when only Dart is present, with carrot', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      dartConstraint: '^3.0.0',
    );

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.13.0', // Corresponds to Dart 3.1.0
    ]);

    final dartVersion = package.parsePubspec().environment['sdk'].toString();
    expect(dartVersion, '^3.1.0');
  });

  test('does not update Dart if it is already higher', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      dartConstraint: '^3.2.0',
    );

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.13.0', // Corresponds to Dart 3.1.0
    ]);

    final dartVersion = package.parsePubspec().environment['sdk'].toString();
    expect(dartVersion, '^3.2.0');
  });

  test('updates both Dart and Flutter when both are present', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      isFlutter: true,
      dartConstraint: '>=3.0.0 <4.0.0',
      flutterConstraint: '>=3.10.0',
    );

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.13.0', // Corresponds to Dart 3.1.0
    ]);

    final dartVersion = package.parsePubspec().environment['sdk'].toString();
    final flutterVersion = package
        .parsePubspec()
        .environment['flutter']
        .toString();
    expect(dartVersion, '^3.1.0');
    expect(flutterVersion, '>=3.13.0');
  });

  test('does not update Flutter if it is already higher', () async {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
      isFlutter: true,
      dartConstraint: '^3.2.0',
      flutterConstraint: '>=3.16.0',
    );

    await runCapturingPrint(runner, <String>[
      'update-min-sdk',
      '--flutter-min',
      '3.13.0', // Corresponds to Dart 3.1.0
    ]);

    final dartVersion = package.parsePubspec().environment['sdk'].toString();
    final flutterVersion = package
        .parsePubspec()
        .environment['flutter']
        .toString();
    expect(dartVersion, '^3.2.0');
    expect(flutterVersion, '>=3.16.0');
  });
}
