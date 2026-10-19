// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Runs the example app's integration tests in release mode to verify that R8
// minification does not strip or rename classes referenced over JNI.
//
// Called from the custom-tests CI action.
//
// usage: dart run tool/run_tests.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const int _noDeviceAvailableExitCode = 100;

Future<void> main(List<String> args) async {
  // The Android emulator custom_package_tests shard runs on Linux in CI.
  if (!Platform.isLinux) {
    print('Skipping for non-Linux host');
    exit(0);
  }

  final String? device = await _getAndroidDevice();
  if (device == null) {
    print(
      'No Android device available. Attach an Android device or start '
      'an emulator to run integration tests.',
    );
    exit(_noDeviceAvailableExitCode);
  }

  final Directory packageDir = Directory(p.dirname(Platform.script.toFilePath())).parent;
  final String examplePath = p.join(packageDir.path, 'example');

  final int exitCode = await _runIntegrationTestsInReleaseMode(
    examplePath,
    'integration_test/shared_preferences_test.dart',
    device: device,
  );
  exit(exitCode);
}

String _getFlutterCommand() => Platform.isWindows ? 'flutter.bat' : 'flutter';

/// Returns the first Android device listed by `flutter devices`, or null if
/// there is no such device.
Future<String?> _getAndroidDevice() async {
  final ProcessResult result = await Process.run(_getFlutterCommand(), <String>[
    'devices',
    '--machine',
  ], stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    return null;
  }

  var output = result.stdout as String;
  // --machine doesn't currently prevent the tool from printing banners;
  // see https://github.com/flutter/flutter/issues/86055. This workaround
  // can be removed once that is fixed.
  final int jsonStart = output.indexOf('[');
  if (jsonStart == -1) {
    return null;
  }
  output = output.substring(jsonStart);

  final List<Map<String, dynamic>> devices = (jsonDecode(output) as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (final deviceInfo in devices) {
    final String targetPlatform = (deviceInfo['targetPlatform'] as String?) ?? '';
    if (targetPlatform.startsWith('android')) {
      final deviceId = deviceInfo['id'] as String?;
      if (deviceId != null) {
        return deviceId;
      }
    }
  }
  return null;
}

/// Runs the tests in [testFile] in a release build on [device], and returns 0
/// if they all pass.
///
/// Only release builds are minified, but neither `flutter test` nor
/// `flutter drive` supports release mode on mobile devices. Instead, this runs
/// [testFile] as the app's entrypoint with `flutter run`. Without a test
/// runner, `flutter_test` runs the tests itself and prints a summary when they
/// finish, which this waits for.
Future<int> _runIntegrationTestsInReleaseMode(
  String projectDirectory,
  String testFile, {
  required String device,
  Duration timeout = const Duration(minutes: 20),
}) async {
  final Process process = await Process.start(_getFlutterCommand(), <String>[
    'run',
    '--release',
    '--target',
    testFile,
    '--device-id',
    device,
  ], workingDirectory: projectDirectory);

  final result = Completer<int>();
  void checkForSummary(String line) {
    print(line);
    if (result.isCompleted) {
      return;
    }
    if (line.contains('All tests passed!')) {
      result.complete(0);
    } else if (line.contains('Some tests failed.') || line.contains('All tests skipped.')) {
      result.complete(1);
    }
  }

  final List<StreamSubscription<String>> subscriptions =
      <Stream<List<int>>>[process.stdout, process.stderr].map((Stream<List<int>> output) {
        return output
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(checkForSummary);
      }).toList();
  unawaited(
    process.exitCode.then((int exitCode) {
      if (!result.isCompleted) {
        print('flutter run exited with code $exitCode before the tests finished.');
        result.complete(exitCode == 0 ? 1 : exitCode);
      }
    }),
  );

  try {
    return await result.future.timeout(
      timeout,
      onTimeout: () {
        print('Timed out after $timeout waiting for the tests to finish.');
        return 1;
      },
    );
  } finally {
    // `flutter run` stays attached to the app until it's stopped.
    process.kill();
    await process.exitCode.timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        process.kill(ProcessSignal.sigkill);
        return process.exitCode;
      },
    );
    await Future.wait(subscriptions.map((StreamSubscription<String> s) => s.cancel()));
  }
}
