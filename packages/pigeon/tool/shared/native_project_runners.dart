// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'flutter_utils.dart';
import 'process_utils.dart';

Future<int> runFlutterCommand(
  String projectDirectory,
  String command,
  List<String> commandArguments, {
  String? wrapperCommand,
}) {
  final String flutterCommand = getFlutterCommand();
  return runProcess(
    wrapperCommand ?? flutterCommand,
    <String>[
      if (wrapperCommand != null) flutterCommand,
      command,
      ...commandArguments,
    ],
    workingDirectory: projectDirectory,
  );
}

Future<int> runFlutterBuild(
  String projectDirectory,
  String target, {
  bool debug = true,
  List<String> flags = const <String>[],
}) {
  return runFlutterCommand(
    projectDirectory,
    'build',
    <String>[
      target,
      if (debug) '--debug',
      ...flags,
    ],
  );
}

Future<int> runXcodeBuild(
  String nativeProjectDirectory, {
  String? sdk,
  String? destination,
  List<String> extraArguments = const <String>[],
}) {
  return runProcess(
    'xcodebuild',
    <String>[
      '-workspace',
      'Runner.xcworkspace',
      '-scheme',
      'Runner',
      if (sdk != null) ...<String>['-sdk', sdk],
      if (destination != null) ...<String>['-destination', destination],
      ...extraArguments,
    ],
    workingDirectory: nativeProjectDirectory,
  );
}

Future<int> runGradleBuild(String nativeProjectDirectory, [String? command]) {
  return runProcess(
    './gradlew',
    <String>[
      if (command != null) command,
    ],
    workingDirectory: nativeProjectDirectory,
  );
}
