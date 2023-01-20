// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// usage: dart run tool/run_tests.dart
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show File, Directory, Platform, exit;
import 'dart:math';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'shared/flutter_utils.dart';
import 'shared/generation.dart';
import 'shared/native_project_runners.dart';
import 'shared/process_utils.dart';

const String _testFlag = 'test';
const String _listFlag = 'list';
const String _skipGenerationFlag = 'skip-generation';

const int _noDeviceAvailableExitCode = 100;

const String _testPluginRelativePath = 'platform_tests/test_plugin';
const String _alternateLanguageTestPluginRelativePath =
    'platform_tests/alternate_language_test_plugin';
const String _integrationTestFileRelativePath = 'integration_test/test.dart';

@immutable
class _TestInfo {
  const _TestInfo({required this.function, this.description});
  final Future<int> Function() function;
  final String? description;
}

// Test suite names.
const String androidJavaUnitTests = 'android_java_unittests';
const String androidJavaIntegrationTests = 'android_java_integration_tests';
const String androidKotlinUnitTests = 'android_kotlin_unittests';
const String androidKotlinIntegrationTests = 'android_kotlin_integration_tests';
const String iOSObjCUnitTests = 'ios_objc_unittests';
const String iOSObjCUnitTestsLegacy = 'ios_objc_legacy_unittests';
const String iOSObjCIntegrationTests = 'ios_objc_integration_tests';
const String iOSSwiftUnitTests = 'ios_swift_unittests';
const String iOSSwiftIntegrationTests = 'ios_swift_integration_tests';
const String macOSSwiftUnitTests = 'macos_swift_unittests';
const String macOSSwiftIntegrationTests = 'macos_swift_integration_tests';
const String windowsUnitTests = 'windows_unittests';
const String windowsIntegrationTests = 'windows_integration_tests';
const String dartUnitTests = 'dart_unittests';
const String flutterUnitTests = 'flutter_unittests';
const String mockHandlerTests = 'mock_handler_tests';
const String commandLineTests = 'command_line_tests';

const Map<String, _TestInfo> _tests = <String, _TestInfo>{
  windowsUnitTests: _TestInfo(
      function: _runWindowsUnitTests,
      description: 'Unit tests on generated Windows C++ code.'),
  windowsIntegrationTests: _TestInfo(
      function: _runWindowsIntegrationTests,
      description: 'Integration tests on generated Windows C++ code.'),
  androidJavaUnitTests: _TestInfo(
      function: _runAndroidJavaUnitTests,
      description: 'Unit tests on generated Java code.'),
  androidJavaIntegrationTests: _TestInfo(
      function: _runAndroidJavaIntegrationTests,
      description: 'Integration tests on generated Java code.'),
  androidKotlinUnitTests: _TestInfo(
      function: _runAndroidKotlinUnitTests,
      description: 'Unit tests on generated Kotlin code.'),
  androidKotlinIntegrationTests: _TestInfo(
      function: _runAndroidKotlinIntegrationTests,
      description: 'Integration tests on generated Kotlin code.'),
  dartUnitTests: _TestInfo(
      function: _runDartUnitTests,
      description: "Unit tests on and analysis on Pigeon's implementation."),
  flutterUnitTests: _TestInfo(
      function: _runFlutterUnitTests,
      description: 'Unit tests on generated Dart code.'),
  iOSObjCUnitTests: _TestInfo(
      function: _runIOSObjCUnitTests,
      description: 'Unit tests on generated Objective-C code.'),
  iOSObjCUnitTestsLegacy: _TestInfo(
      function: _runIOSObjCLegacyUnitTests,
      description:
          'Unit tests on generated Objective-C code (legacy test harness).'),
  iOSObjCIntegrationTests: _TestInfo(
      function: _runIOSObjCIntegrationTests,
      description: 'Integration tests on generated Objective-C code.'),
  iOSSwiftUnitTests: _TestInfo(
      function: _runIOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code.'),
  iOSSwiftIntegrationTests: _TestInfo(
      function: _runIOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code.'),
  macOSSwiftUnitTests: _TestInfo(
      function: _runMacOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code on macOS.'),
  macOSSwiftIntegrationTests: _TestInfo(
      function: _runMacOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code on macOS.'),
  mockHandlerTests: _TestInfo(
      function: _runMockHandlerTests,
      description: 'Unit tests on generated Dart mock handler code.'),
  commandLineTests: _TestInfo(
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

/// Generates multiple dart files based on the jobs defined in [jobs] which is
/// in the format of (key: input pigeon file path, value: output dart file
/// path).
Future<int> _generateDart(Map<String, String> jobs) async {
  for (final MapEntry<String, String> job in jobs.entries) {
    // TODO(gaaclarke): Make this run the jobs in parallel.  A bug in Dart
    // blocked this (https://github.com/dart-lang/pub/pull/3285).
    final int result = await runPigeon(input: job.key, dartOut: job.value);
    if (result != 0) {
      return result;
    }
  }
  return 0;
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
  // TODO(stuartmorgan): Migrate Dart unit tests to use the generated output in
  // shared_test_plugin_code instead of having multiple copies of generation.
  const String flutterUnitTestsPath =
      'platform_tests/flutter_null_safe_unit_tests';
  // Files from the pigeons/ directory to generate output for.
  const List<String> inputPigeons = <String>[
    'flutter_unittests',
    'core_tests',
    'primitive',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    // TODO(stuartmorgan): Eliminate these files by ensuring that everything
    // they are intended to cover is in core_tests.dart (or, if necessary in
    // the short term due to limitations in non-Dart generators, a single other
    // file). They aren't being unit tested, only analyzed.
    'async_handlers',
    'host2flutter',
    'list',
    'message',
    'void_arg_flutter',
    'void_arg_host',
    'voidflutter',
    'voidhost',
  ];
  final int generateCode = await _generateDart(<String, String>{
    for (final String name in inputPigeons)
      'pigeons/$name.dart': '$flutterUnitTestsPath/lib/$name.gen.dart'
  });
  if (generateCode != 0) {
    return generateCode;
  }

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

// TODO(stuartmorgan): Remove this, and the ios_unit_tests directory, once
// _runIOSObjCUnitTests works in CI; see
// https://github.com/flutter/packages/pull/2816.
Future<int> _runIOSObjCLegacyUnitTests() async {
  return _runIOSProjectUnitTests('platform_tests/ios_unit_tests');
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

Future<int> _runMacOSSwiftUnitTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  final int compileCode = await runFlutterBuild(examplePath, 'macos');
  if (compileCode != 0) {
    return compileCode;
  }

  return runXcodeBuild(
    '$examplePath/macos',
    extraArguments: <String>['test'],
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
  return _runIOSProjectUnitTests(examplePath);
}

Future<int> _runIOSProjectUnitTests(String testProjectPath) async {
  final int compileCode = await runFlutterBuild(
    testProjectPath,
    'ios',
    flags: <String>['--simulator', '--no-codesign'],
  );
  if (compileCode != 0) {
    return compileCode;
  }

  return runXcodeBuild(
    '$testProjectPath/ios',
    sdk: 'iphonesimulator',
    destination: 'platform=iOS Simulator,name=iPhone 8',
    extraArguments: <String>['test'],
  );
}

Future<int> _runIOSSwiftIntegrationTests() async {
  return _runMobileIntegrationTests('iOS', _testPluginRelativePath);
}

Future<int> _runMockHandlerTests() async {
  const String unitTestsPath = './mock_handler_tester';
  final int generateCode = await runPigeon(
    input: './pigeons/message.dart',
    dartOut: './mock_handler_tester/test/message.dart',
    dartTestOut: './mock_handler_tester/test/test.dart',
  );
  if (generateCode != 0) {
    return generateCode;
  }

  final int testCode = await runFlutterCommand(unitTestsPath, 'test');
  if (testCode != 0) {
    return testCode;
  }
  return 0;
}

Future<int> _runWindowsUnitTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  final int compileCode = await runFlutterBuild(examplePath, 'windows');
  if (compileCode != 0) {
    return compileCode;
  }

  return runProcess(
      '$examplePath/build/windows/plugins/test_plugin/Debug/test_plugin_test.exe',
      <String>[]);
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

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addMultiOption(_testFlag, abbr: 't', help: 'Only run specified tests.')
    ..addFlag(_listFlag,
        negatable: false, abbr: 'l', help: 'List available tests.')
    // Temporarily provide a way for run_test.sh to bypass generation, since
    // it generates before doing anything else.
    // TODO(stuartmorgan): Remove this once run_test.sh is fully migrated to
    // this script.
    ..addFlag(_skipGenerationFlag, negatable: false, hide: true)
    ..addFlag('help',
        negatable: false, abbr: 'h', help: 'Print this reference.');

  final ArgResults argResults = parser.parse(args);
  List<String> testsToRun = <String>[];
  if (argResults.wasParsed(_listFlag)) {
    print('available tests:');

    final int columnWidth =
        _tests.keys.map((String key) => key.length).reduce(max) + 4;

    for (final MapEntry<String, _TestInfo> info in _tests.entries) {
      print('${info.key.padRight(columnWidth)}- ${info.value.description}');
    }
    exit(0);
  } else if (argResults.wasParsed('help')) {
    print('''
Pigeon run_tests
usage: dart run tool/run_tests.dart [-l | -t <test name>]

${parser.usage}''');
    exit(0);
  } else if (argResults.wasParsed(_testFlag)) {
    testsToRun = argResults[_testFlag];
  }

  if (!argResults.wasParsed(_skipGenerationFlag)) {
    final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
    print('# Generating platform_test/ output...');
    final int generateExitCode = await generatePigeons(baseDir: baseDir);
    if (generateExitCode == 0) {
      print('Generation complete!');
    } else {
      print('Generation failed; see above for errors.');
    }
  }

  // If no tests are provided, run a default based on the host platform. This is
  // the mode used by CI.
  if (testsToRun.isEmpty) {
    const List<String> androidTests = <String>[
      androidJavaUnitTests,
      androidKotlinUnitTests,
      // TODO(stuartmorgan): Include these once CI supports running simulator
      // tests. Currently these tests aren't run in CI.
      // See https://github.com/flutter/flutter/issues/111505.
      // androidJavaIntegrationTests,
      // androidKotlinIntegrationTests,
    ];
    const List<String> macOSTests = <String>[
      macOSSwiftUnitTests,
      macOSSwiftIntegrationTests
    ];
    const List<String> iOSTests = <String>[
      // TODO(stuartmorgan): Replace this with iOSObjCUnitTests once the CI
      // issues are resolved; see https://github.com/flutter/packages/pull/2816.
      iOSObjCUnitTestsLegacy,
      // TODO(stuartmorgan): Enable by default once CI issues are solved; see
      // https://github.com/flutter/packages/pull/2816.
      // iOSObjCIntegrationTests,
      iOSSwiftUnitTests,
      // Currently these are testing exactly the same thing as
      // macos_swift_e2e_tests, so we don't need to run both by default. This
      // should be enabled if any iOS-only tests are added (e.g., for a feature
      // not supported by macOS).
      // iOSSwiftIntegrationTests,
    ];
    const List<String> windowsTests = <String>[
      windowsUnitTests,
      windowsIntegrationTests,
    ];
    const List<String> dartTests = <String>[
      dartUnitTests,
      flutterUnitTests,
      mockHandlerTests,
      commandLineTests,
    ];

    if (Platform.isMacOS) {
      testsToRun = <String>[
        ...dartTests,
        ...androidTests,
        ...iOSTests,
        ...macOSTests,
      ];
    } else if (Platform.isWindows) {
      testsToRun = windowsTests;
    } else {
      // TODO(stuartmorgan): Make a new entrypoint for developers that runs
      // all tests their host supports by default, and move some of the tests
      // above here. See https://github.com/flutter/flutter/issues/115393
    }
  }

  for (final String test in testsToRun) {
    final _TestInfo? info = _tests[test];
    if (info != null) {
      print('# Running $test');
      final int testCode = await info.function();
      if (testCode != 0) {
        exit(testCode);
      }
    } else {
      print('unknown test: $test');
      exit(1);
    }
  }
  exit(0);
}
