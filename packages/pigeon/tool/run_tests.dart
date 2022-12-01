// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// usage: dart run tool/run_tests.dart
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show File, Platform, exit;
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

const Map<String, _TestInfo> _tests = <String, _TestInfo>{
  'windows_unittests': _TestInfo(
      function: _runWindowsUnitTests,
      description: 'Unit tests on generated Windows C++ code.'),
  'windows_integration_tests': _TestInfo(
      function: _runWindowsIntegrationTests,
      description: 'Integration tests on generated Windows C++ code.'),
  'android_java_unittests': _TestInfo(
      function: _runAndroidJavaUnitTests,
      description: 'Unit tests on generated Java code.'),
  'android_java_integration_tests': _TestInfo(
      function: _runAndroidJavaIntegrationTests,
      description: 'Integration tests on generated Java code.'),
  'android_kotlin_unittests': _TestInfo(
      function: _runAndroidKotlinUnitTests,
      description: 'Unit tests on generated Kotlin code.'),
  'android_kotlin_integration_tests': _TestInfo(
      function: _runAndroidKotlinIntegrationTests,
      description: 'Integration tests on generated Kotlin code.'),
  'dart_compilation_tests': _TestInfo(
      function: _runDartCompilationTests,
      description: 'Compilation tests on generated Dart code.'),
  'dart_unittests': _TestInfo(
      function: _runDartUnitTests,
      description: "Unit tests on and analysis on Pigeon's implementation."),
  'flutter_unittests': _TestInfo(
      function: _runFlutterUnitTests,
      description: 'Unit tests on generated Dart code.'),
  'ios_objc_unittests': _TestInfo(
      function: _runIOSObjCUnitTests,
      description: 'Unit tests on generated Objective-C code.'),
  'ios_objc_integration_tests': _TestInfo(
      function: _runIOSObjCIntegrationTests,
      description: 'Integration tests on generated Objective-C code.'),
  'ios_swift_unittests': _TestInfo(
      function: _runIOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code.'),
  'ios_swift_integration_tests': _TestInfo(
      function: _runIOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code.'),
  'macos_swift_unittests': _TestInfo(
      function: _runMacOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code on macOS.'),
  'macos_swift_integration_tests': _TestInfo(
      function: _runMacOSSwiftIntegrationTests,
      description: 'Integration tests on generated Swift code on macOS.'),
  'mock_handler_tests': _TestInfo(
      function: _runMockHandlerTests,
      description: 'Unit tests on generated Dart mock handler code.'),
};

Future<int> _runAndroidJavaUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runAndroidJavaIntegrationTests() async {
  return _runMobileIntegrationTests(
      'Android', _alternateLanguageTestPluginRelativePath);
}

Future<int> _runAndroidKotlinUnitTests() async {
  const String examplePath = './$_testPluginRelativePath/example';
  const String androidProjectPath = '$examplePath/android';
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

Future<int> _runDartCompilationTests() async {
  throw UnimplementedError('See run_tests.sh.');
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
  final int generateCode = await _generateDart(<String, String>{
    'pigeons/flutter_unittests.dart':
        '$flutterUnitTestsPath/lib/null_safe_pigeon.dart',
    'pigeons/core_tests.dart': '$flutterUnitTestsPath/lib/core_tests.gen.dart',
    'pigeons/primitive.dart': '$flutterUnitTestsPath/lib/primitive.dart',
    'pigeons/multiple_arity.dart':
        '$flutterUnitTestsPath/lib/multiple_arity.gen.dart',
    'pigeons/non_null_fields.dart':
        '$flutterUnitTestsPath/lib/non_null_fields.gen.dart',
    'pigeons/null_fields.dart':
        '$flutterUnitTestsPath/lib/null_fields.gen.dart',
    'pigeons/nullable_returns.dart':
        '$flutterUnitTestsPath/lib/nullable_returns.gen.dart',
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
  return _runIOSUnitTests(_alternateLanguageTestPluginRelativePath);
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
  return _runIOSUnitTests(_testPluginRelativePath);
}

Future<int> _runIOSUnitTests(String testPluginPath) async {
  final String examplePath = './$testPluginPath/example';
  final int compileCode = await runFlutterBuild(
    examplePath,
    'ios',
    flags: <String>['--simulator', '--no-codesign'],
  );
  if (compileCode != 0) {
    return compileCode;
  }

  return runXcodeBuild(
    '$examplePath/ios',
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

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addOption(_testFlag, abbr: 't', help: 'Only run specified test.')
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
    testsToRun = <String>[argResults[_testFlag]];
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
    if (Platform.isWindows) {
      testsToRun = <String>['windows_unittests', 'windows_integration_tests'];
    } else {
      // TODO(gaaclarke): migrate from run_tests.sh to this script.
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
