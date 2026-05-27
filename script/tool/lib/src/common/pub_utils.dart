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
  // Running `dart pub get` on a Flutter package can fail if a non-Flutter Dart
  // is first in the path, so use `flutter pub get` for any Flutter package.
  final bool useFlutter = package.requiresFlutter();
  final command = useFlutter
      ? (platform.isWindows ? 'flutter.bat' : 'flutter')
      : 'dart';
  final args = <String>['pub', 'get'];

  final int exitCode;
  if (streamOutput) {
    exitCode = await processRunner.runAndStream(
      command,
      args,
      workingDir: package.directory,
    );
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
