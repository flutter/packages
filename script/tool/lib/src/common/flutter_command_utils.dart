// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:platform/platform.dart';

import 'process_runner.dart';
import 'repository_package.dart';

/// Runs the appropriate `flutter build --config-only` command for the given
/// target platform and build mode, to ensure that all of the native build files
/// are present for that mode.
///
/// If [streamOutput] is false, output will only be printed if the command
/// fails.
Future<bool> runConfigOnlyBuild(
  RepositoryPackage package,
  ProcessRunner processRunner,
  Platform platform,
  FlutterPlatform targetPlatform, {
  bool buildDebug = false,
  List<String> extraArgs = const <String>[],
}) async {
  final String flutterCommand = platform.isWindows ? 'flutter.bat' : 'flutter';

  final String target = switch (targetPlatform) {
    FlutterPlatform.android => 'apk',
    FlutterPlatform.ios => 'ios',
    FlutterPlatform.linux => 'linux',
    FlutterPlatform.macos => 'macos',
    FlutterPlatform.web => 'web',
    FlutterPlatform.windows => 'windows',
  };

  final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'build',
        target,
        if (buildDebug) '--debug',
        '--config-only',
        ...extraArgs,
      ],
      workingDir: package.directory);
  return exitCode == 0;
}
