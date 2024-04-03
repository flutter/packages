// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io' show Directory, File;

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'flutter_utils.dart';
import 'generation.dart';
import 'native_project_runners.dart';
import 'process_utils.dart';

const int _noDeviceAvailableExitCode = 100;

const String _testPluginRelativePath = 'platform_tests/test_plugin';
const String _alternateLanguageTestPluginRelativePath =
    'platform_tests/alternate_language_test_plugin';
const String _integrationTestFileRelativePath = 'integration_test/test.dart';

/// Information about a test suite.
@immutable
class TestInfo {
  const TestInfo({required this.function, this.description});

  /// The function to run the test suite.
  final Future<int> Function() function;

  /// A user-facing description of the test suite.
  final String? description;
}

// Test suite names.
const String androidJavaUnitTests = 'android_java_unittests';
const String androidJavaLint = 'android_java_lint';
const String androidJavaIntegrationTests = 'android_java_integration_tests';
const String androidKotlinUnitTests = 'android_kotlin_unittests';
const String androidKotlinIntegrationTests = 'android_kotlin_integration_tests';
const String iOSObjCUnitTests = 'ios_objc_unittests';
const String iOSObjCIntegrationTests = 'ios_objc_integration_tests';
const String iOSSwiftUnitTests = 'ios_swift_unittests';
const String iOSSwiftIntegrationTests = 'ios_swift_integration_tests';
const String macOSObjCIntegrationTests = 'macos_objc_integration_tests';
const String macOSSwiftUnitTests = 'macos_swift_unittests';
const String macOSSwiftIntegrationTests = 'macos_swift_integration_tests';
const String windowsUnitTests = 'windows_unittests';
const String windowsIntegrationTests = 'windows_integration_tests';
const String dartUnitTests = 'dart_unittests';
const String flutterUnitTests = 'flutter_unittests';
const String commandLineTests = 'command_line_tests';

const Map<String, TestInfo> testSuites = <String, TestInfo>{
  windowsUnitTests: TestInfo(
      function: _runWindowsUnitTests,
      description: 'Unit tests on generated Windows C++ code.'),
  windowsIntegrationTests: TestInfo(
      function: _runWindowsIntegrationTests,
      description: 'Integration tests on generated Windows C++ code.'),
  androidJavaUnitTests: TestInfo(
      function: _runAndroidJavaUnitTests,
      description: 'Unit tests on generated Java code.'),
  androidJavaIntegrationTests: TestInfo(
      function: _runAndroidJavaIntegrationTests,
      description: 'Integration tests on generated Java code.'),
  androidJavaLint: TestInfo(
      function: _runAndroidJavaLint, description: 'Lint generated Java code.'),
  androidKotlinUnitTests: TestInfo(
      function: _runAndroidKotlinUnitTests,
      description: 'Unit tests on generated Kotlin code.'),
  androidKotlinIntegrationTests: TestInfo(
      function: _runAndroidKotlinIntegrationTests,
      description: 'Integration tests on generated Kotlin code.'),
  dartUnitTests: TestInfo(
      function: _runDartUnitTests,
      description: "Unit tests on and analysis on Pigeon's implementation."),
  flutterUnitTests: TestInfo(
      function: _runFlutterUnitTests,
      description: 'Unit tests on generated Dart code.'),
  iOSObjCUnitTests: TestInfo(
      function: _runIOSObjCUnitTests,
      description: 'Unit tests on generated Objective-C code.'),
  iOSObjCIntegrationTests: TestInfo(
      function: _runIOSObjCIntegrationTests,
      description: 'Integration tests on generated Objective-C code.'),
  iOSSwiftUnitTests: TestInfo(
      function: _runIOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code.'),
  iOSSwiftIntegrationTests: TestInfo(
      function: _runIOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code.'),
  macOSObjCIntegrationTests: TestInfo(
      function: _runMacOSObjCIntegrationTests,
      description: 'Integration tests on generated Objective-C code on macOS.'),
  macOSSwiftUnitTests: TestInfo(
      function: _runMacOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code on macOS.'),
  macOSSwiftIntegrationTests: TestInfo(
      function: _runMacOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code on macOS.'),
  commandLineTests: TestInfo(
      function: _runCommandLineTests,
      description: 'Tests running pigeon with various command-line options.'),
};

Future<int> _runAndroidJavaUnitTests() async {
  return _runAndroidUnitTests(_alternateLanguageTestPluginRelativePath);
}

Future<int> _runAndroidJavaIntegrationTests() async {
  return _runMobileIntegrationTests(
      'Android', _alternateLanguageTestPluginRelativePath);
}

Future<int> _runAndroidJavaLint() async {
  const String examplePath =
      './$_alternateLanguageTestPluginRelativePath/example';
  const String androidProjectPath = '$examplePath/android';
  final File gradleFile = File(p.join(androidProjectPath, 'gradlew'));
  if (!gradleFile.existsSync()) {
    final int compileCode = await runFlutterBuild(examplePath, 'apk',
        flags: <String>['--config-only']);
    if (compileCode != 0) {
      return compileCode;
    }
  }

  return runGradleBuild(
      androidProjectPath, 'alternate_language_test_plugin:lintDebug');
}

Future<int> _runAndroidKotlinUnitTests() async {
  return _runAndroidUnitTests(_testPluginRelativePath);
}

Future<int> _runAndroidUnitTests(String testPluginPath) async {
  final String examplePath = './$testPluginPath/example';
  final String androidProjectPath = '$examplePath/android';
  final File gradleFile = File(p.join(androidProjectPath, 'gradlew'));
  if (!gradleFile.existsSync()) {
    final int compileCode = await runFlutterBuild(examplePath, 'apk');
    if (compileCode != 0) {
      return compileCode;
    }
  }

  return runGradleBuild(androidProjectPath, 'testDebugUnitTest');
}

Future<int> _runAndroidKotlinIntegrationTests() async {
  return _runMobileIntegrationTests('Android', _testPluginRelativePath);
}

Future<int> _runMobileIntegrationTests(
    String platform, String testPluginPath) async {
  final String? device = await getDeviceForPlatform(platform.toLowerCase());
  if (device == null) {
    print('No $platform device available. Attach an $platform device or start '
        'an emulator/simulator to run integration tests');
    return _noDeviceAvailableExitCode;
  }

  final String examplePath = './$testPluginPath/example';
  return runFlutterCommand(
    examplePath,
    'test',
    <String>[_integrationTestFileRelativePath, '-d', device],
  );
}

Future<int> _runDartUnitTests() async {
  int exitCode = await runProcess('dart', <String>['analyze', 'bin']);
  if (exitCode != 0) {
    return exitCode;
  }
  exitCode = await runProcess('dart', <String>['analyze', 'lib']);
  if (exitCode != 0) {
    return exitCode;
  }
  exitCode = await runProcess('dart', <String>['test']);
  return exitCode;
}

Future<int> _analyzeFlutterUnitTests(String flutterUnitTestsPath) async {
  final String messagePath = '$flutterUnitTestsPath/lib/message.gen.dart';
  final String messageTestPath = '$flutterUnitTestsPath/test/message_test.dart';
  final int generateTestCode = await runPigeon(
    input: 'pigeons/message.dart',
    dartOut: messagePath,
    dartTestOut: messageTestPath,
  );
  if (generateTestCode != 0) {
    return generateTestCode;
  }

  final int analyzeCode =
      await runFlutterCommand(flutterUnitTestsPath, 'analyze');
  if (analyzeCode != 0) {
    return analyzeCode;
  }

  // Delete these files that were just generated to help with the analyzer step.
  File(messagePath).deleteSync();
  File(messageTestPath).deleteSync();
  return 0;
}

Future<int> _runFlutterUnitTests() async {
  const String flutterUnitTestsPath = 'platform_tests/shared_test_plugin_code';
  final int analyzeCode = await _analyzeFlutterUnitTests(flutterUnitTestsPath);
  if (analyzeCode != 0) {
    return analyzeCode;
  }

  final int testCode = await runFlutterCommand(flutterUnitTestsPath, 'test');
  if (testCode != 0) {
    return testCode;
  }

  return 0;
}

Future<int> _runIOSObjCUnitTests() async {
  return _runIOSPluginUnitTests(_alternateLanguageTestPluginRelativePath);
}

Future<int> _runIOSObjCIntegrationTests() async {
  final String? device = await getDeviceForPlatform('ios');
  if (device == null) {
    print('No iOS device available. Attach an iOS device or start '
        'a simulator to run integration tests');
    return _noDeviceAvailableExitCode;
  }

  const String examplePath =
      './$_alternateLanguageTestPluginRelativePath/example';
  return runFlutterCommand(
    examplePath,
    'test',
    <String>[_integrationTestFileRelativePath, '-d', device],
  );
}

Future<int> _runMacOSObjCIntegrationTests() async {
  const String examplePath =
      './$_alternateLanguageTestPluginRelativePath/example';
  return runFlutterCommand(
    examplePath,
    'test',
    <String>[_integrationTestFileRelativePath, '-d', 'macos'],
  );
}

Future<int> _runMacOSSwiftUnitTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  final int compileCode = await runFlutterBuild(examplePath, 'macos');
  if (compileCode != 0) {
    return compileCode;
  }

  return runXcodeBuild(
    '$examplePath/macos',
    extraArguments: <String>[
      '-configuration',
      'Debug',
      'test',
    ],
  );
}

Future<int> _runMacOSSwiftIntegrationTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  return runFlutterCommand(
    examplePath,
    'test',
    <String>[_integrationTestFileRelativePath, '-d', 'macos'],
  );
}

Future<int> _runIOSSwiftUnitTests() async {
  return _runIOSPluginUnitTests(_testPluginRelativePath);
}

Future<int> _runIOSPluginUnitTests(String testPluginPath) async {
  final String examplePath = './$testPluginPath/example';
  final int compileCode = await runFlutterBuild(
    examplePath,
    'ios',
    flags: <String>['--simulator', '--no-codesign'],
  );
  if (compileCode != 0) {
    return compileCode;
  }

  const String deviceName = 'Pigeon-Test-iPhone';
  const String deviceType = 'com.apple.CoreSimulator.SimDeviceType.iPhone-14';
  const String deviceRuntime = 'com.apple.CoreSimulator.SimRuntime.iOS-17-0';
  const String deviceOS = '17.0';
  await _createSimulator(deviceName, deviceType, deviceRuntime);
  return runXcodeBuild(
    '$examplePath/ios',
    sdk: 'iphonesimulator',
    destination: 'platform=iOS Simulator,name=$deviceName,OS=$deviceOS',
    extraArguments: <String>['test'],
  ).whenComplete(() => _deleteSimulator(deviceName));
}

Future<int> _createSimulator(
  String deviceName,
  String deviceType,
  String deviceRuntime,
) async {
  // Delete any existing simulators with the same name until it fails. It will
  // fail once there are no simulators with the name. Having more than one may
  // cause issues when builds target the device.
  int deleteResult = 0;
  while (deleteResult == 0) {
    deleteResult = await _deleteSimulator(deviceName);
  }
  return runProcess(
    'xcrun',
    <String>[
      'simctl',
      'create',
      deviceName,
      deviceType,
      deviceRuntime,
    ],
    streamOutput: false,
    logFailure: true,
  );
}

Future<int> _deleteSimulator(String deviceName) async {
  return runProcess(
    'xcrun',
    <String>[
      'simctl',
      'delete',
      deviceName,
    ],
    streamOutput: false,
  );
}

Future<int> _runIOSSwiftIntegrationTests() async {
  return _runMobileIntegrationTests('iOS', _testPluginRelativePath);
}

Future<int> _runWindowsUnitTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  final int compileCode = await runFlutterBuild(examplePath, 'windows');
  if (compileCode != 0) {
    return compileCode;
  }

  // Depending on the Flutter version, the build output path is different. To
  // handle both master and stable, and to future-proof against the changes
  // that will happen in https://github.com/flutter/flutter/issues/129807
  // - Try arm64, to future-proof against arm64 support.
  // - Try x64, to cover pre-arm64 support on arm64 hosts, as well as x64 hosts
  //   running newer versions of Flutter.
  // - Fall back to the pre-arch path, to support running against stable.
  // TODO(stuartmorgan): Remove all this when these tests no longer need to
  // support a version of Flutter without
  // https://github.com/flutter/flutter/issues/129807, and just construct the
  // version of the path with the current architecture.
  const String buildDirBase = '$examplePath/build/windows';
  const String buildRelativeBinaryPath =
      'plugins/test_plugin/Debug/test_plugin_test.exe';
  const String arm64Path = '$buildDirBase/arm64/$buildRelativeBinaryPath';
  const String x64Path = '$buildDirBase/x64/$buildRelativeBinaryPath';
  const String oldPath = '$buildDirBase/$buildRelativeBinaryPath';
  if (File(arm64Path).existsSync()) {
    return runProcess(arm64Path, <String>[]);
  } else if (File(x64Path).existsSync()) {
    return runProcess(x64Path, <String>[]);
  } else {
    return runProcess(oldPath, <String>[]);
  }
}

Future<int> _runWindowsIntegrationTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  return runFlutterCommand(
    examplePath,
    'test',
    <String>[_integrationTestFileRelativePath, '-d', 'windows'],
  );
}

Future<int> _runCommandLineTests() async {
  final Directory tempDir = Directory.systemTemp.createTempSync('pigeon');
  final String tempOutput = p.join(tempDir.path, 'pigeon_output');
  const String pigeonScript = 'bin/pigeon.dart';
  final String snapshot = p.join(tempDir.path, 'pigeon.dart.dill');

  // Precompile to make the repeated calls faster.
  if (await runProcess('dart', <String>[
        '--snapshot-kind=kernel',
        '--snapshot=$snapshot',
        pigeonScript
      ]) !=
      0) {
    print('Unable to generate $snapshot from $pigeonScript');
    return 1;
  }

  final List<List<String>> testArguments = <List<String>>[
    // Test with no arguments.
    <String>[],
    // Test one_language flag. With this flag specified, java_out can be
    // generated without dart_out.
    <String>[
      '--input',
      'pigeons/message.dart',
      '--one_language',
      '--java_out',
      tempOutput
    ],
    // Test dartOut in ConfigurePigeon overrides output.
    <String>['--input', 'pigeons/configure_pigeon_dart_out.dart'],
    // Make sure AST generation exits correctly.
    <String>[
      '--input',
      'pigeons/message.dart',
      '--one_language',
      '--ast_out',
      tempOutput
    ],
    // Test writing a file in a directory that doesn't exist.
    <String>[
      '--input',
      'pigeons/message.dart',
      '--dart_out',
      '$tempDir/subdirectory/does/not/exist/message.g.dart',
    ],
  ];

  int exitCode = 0;
  for (final List<String> arguments in testArguments) {
    print('Testing dart $pigeonScript ${arguments.join(', ')}');
    exitCode = await runProcess('dart', <String>[snapshot, ...arguments],
        streamOutput: false, logFailure: true);
    if (exitCode != 0) {
      break;
    }
  }

  tempDir.deleteSync(recursive: true);
  return exitCode;
}
