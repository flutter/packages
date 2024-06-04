// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as path;

import 'flutter_utils.dart';
import 'process_utils.dart';

Future<int> runFlutterCommand(
  String projectDirectory,
  String command, [
  List<String> commandArguments = const <String>[],
]) {
  return runProcess(
    getFlutterCommand(),
    <String>[
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
  String nativeProjectDirectory,
  String platform, {
  String? sdk,
  String? destination,
  String? configuration,
  List<String> extraArguments = const <String>[],
}) {
  File? disabledSandboxEntitlementFile;
  if (extraArguments.contains('test') &&
      platform.toLowerCase() == 'macos' &&
      Platform.environment['LUCI_CI'] == 'True') {
    disabledSandboxEntitlementFile = _createDisabledSandboxEntitlementFile(
      nativeProjectDirectory,
      configuration ?? 'Debug',
    );
  }

  return runProcess(
    'xcodebuild',
    <String>[
      '-workspace',
      'Runner.xcworkspace',
      '-scheme',
      'Runner',
      if (sdk != null) ...<String>['-sdk', sdk],
      if (destination != null) ...<String>['-destination', destination],
      if (configuration != null) ...<String>['-configuration', configuration],
      ...extraArguments,
      if (disabledSandboxEntitlementFile != null)
        'CODE_SIGN_ENTITLEMENTS=${disabledSandboxEntitlementFile.path}',
    ],
    workingDirectory: nativeProjectDirectory,
  );
}

/// Finds and copies macOS entitlements file. In the copy, disables sandboxing.
/// If entitlements file is not found, returns null.
///
/// As of macOS 14, testing a macOS sandbox app may prompt the user to grant
/// access to the app. To workaround this in CI, we create and use a entitlements
/// file with sandboxing disabled. See
/// https://developer.apple.com/documentation/security/app_sandbox/accessing_files_from_the_macos_app_sandbox.
File? _createDisabledSandboxEntitlementFile(
  String platformDirectory,
  String configuration,
) {
  String entitlementDefaultFileName;
  if (configuration == 'Release') {
    entitlementDefaultFileName = 'Release';
  } else {
    entitlementDefaultFileName = 'DebugProfile';
  }

  final String entitlementFilePath = path.join(
    platformDirectory,
    'Runner',
    '$entitlementDefaultFileName.entitlements',
  );
  final File entitlementFile = File(entitlementFilePath);

  if (!entitlementFile.existsSync()) {
    print('Unable to find entitlements file at ${entitlementFile.path}');
    return null;
  }

  final String originalEntitlementFileContents =
      entitlementFile.readAsStringSync();
  final String tempEntitlementPath = Directory.systemTemp
      .createTempSync('flutter_disable_sandbox_entitlement.')
      .path;
  final File disabledSandboxEntitlementFile = File(path.join(
    tempEntitlementPath,
    '${entitlementDefaultFileName}WithDisabledSandboxing.entitlements',
  ));
  disabledSandboxEntitlementFile.createSync(recursive: true);
  disabledSandboxEntitlementFile.writeAsStringSync(
    originalEntitlementFileContents.replaceAll(
      RegExp(r'<key>com\.apple\.security\.app-sandbox<\/key>[\S\s]*?<true\/>'),
      '''
<key>com.apple.security.app-sandbox</key>
	<false/>''',
    ),
  );

  return disabledSandboxEntitlementFile;
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
