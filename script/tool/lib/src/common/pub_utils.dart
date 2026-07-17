// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:platform/platform.dart';

import 'process_runner.dart';
import 'repository_package.dart';

/// Runs either `dart pub get` or `flutter pub get` in [package], depending on
/// the package type.
///
/// If [streamOutput] is false, output will only be printed if the command
/// fails.
Future<bool> runPubGet(
  RepositoryPackage package,
  ProcessRunner processRunner,
  Platform platform, {
  bool streamOutput = true,
}) async {
  return runPubCommand(
    <String>['get'],
    package,
    processRunner,
    platform,
    streamOutput: streamOutput,
    recursiveFlutterCheck: true,
  );
}

/// Runs a pub command with the given arguments in [package],
/// using either 'dart' or 'flutter' depending on the package type.
///
/// If [streamOutput] is false, output will only be printed if the command
/// fails.
Future<bool> runPubCommand(
  List<String> commandArgs,
  RepositoryPackage package,
  ProcessRunner processRunner,
  Platform platform, {
  bool streamOutput = true,
  String? dartSdkPathOverride,
  bool recursiveFlutterCheck = false,
}) async {
  final String command = _pubCommand(
    package,
    platform,
    dartSdkPathOverride: dartSdkPathOverride,
    recursiveFlutterCheck: recursiveFlutterCheck,
  );
  final args = <String>['pub', ...commandArgs];
  final int exitCode;
  if (streamOutput) {
    exitCode = await processRunner.runAndStream(command, args, workingDir: package.directory);
  } else {
    final io.ProcessResult result = await processRunner.run(
      command,
      args,
      workingDir: package.directory,
    );
    exitCode = result.exitCode;
    if (exitCode != 0) {
      print('${result.stdout}\n${result.stderr}\n');
    }
  }
  return exitCode == 0;
}

/// Starts a pub command with the given arguments in [package],
/// using either 'dart' or 'flutter' depending on the package type, and returns
/// a process that can be used to wait for completion and stream output.
///
/// If no output capturing is necessary, prefer [runPubCommand].
Future<io.Process> startPubCommand(
  List<String> commandArgs,
  RepositoryPackage package,
  ProcessRunner processRunner,
  Platform platform,
) async {
  return processRunner.start(_pubCommand(package, platform), <String>[
    'pub',
    ...commandArgs,
  ], workingDirectory: package.directory);
}

String _pubCommand(
  RepositoryPackage package,
  Platform platform, {
  String? dartSdkPathOverride,
  bool recursiveFlutterCheck = false,
}) {
  // Running `dart pub get` on a Flutter package can fail if a non-Flutter Dart
  // is first in the path, so use `flutter pub get` for any Flutter package.
  bool useFlutter = package.requiresFlutter();
  if (!useFlutter && recursiveFlutterCheck) {
    for (final RepositoryPackage example in package.getExamples()) {
      if (example.requiresFlutter()) {
        useFlutter = true;
        break;
      }
    }
  }
  return useFlutter
      ? (platform.isWindows ? 'flutter.bat' : 'flutter')
      : (dartSdkPathOverride ?? 'dart');
}
