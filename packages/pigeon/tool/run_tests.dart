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

import 'shared/generation.dart';
import 'shared/process_utils.dart';

const String _testFlag = 'test';
const String _listFlag = 'list';

const String testPluginRelativePath = 'platform_tests/test_plugin';
const String secondaryTestPluginRelativePath =
    'alternate_language_platform_tests/test_plugin';

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
  'android_unittests': _TestInfo(
      function: _runAndroidUnitTests,
      description: 'Unit tests on generated Java code.'),
  'android_kotlin_unittests': _TestInfo(
      function: _runAndroidKotlinUnitTests,
      description: 'Unit tests on generated Kotlin code.'),
  'dart_compilation_tests': _TestInfo(
      function: _runDartCompilationTests,
      description: 'Compilation tests on generated Dart code.'),
  'dart_unittests': _TestInfo(
      function: _runDartUnitTests,
      description: "Unit tests on and analysis on Pigeon's implementation."),
  'flutter_unittests': _TestInfo(
      function: _runFlutterUnitTests,
      description: 'Unit tests on generated Dart code.'),
  'ios_e2e_tests': _TestInfo(
      function: _runIosE2eTests,
      description: 'End-to-end Objective-C tests run on iOS Simulator'),
  'ios_unittests': _TestInfo(
      function: _runIosUnitTests,
      description: 'Unit tests on generated Objective-C code.'),
  'ios_swift_unittests': _TestInfo(
      function: _runIosSwiftUnitTests,
      description: 'Unit tests on generated Swift code.'),
  'mac_swift_unittests': _TestInfo(
      function: _runMacOSSwiftUnitTests,
      description: 'Unit tests on generated Swift code on macOS.'),
  'mock_handler_tests': _TestInfo(
      function: _runMockHandlerTests,
      description: 'Unit tests on generated Dart mock handler code.'),
};

String snakeToPascalCase(String snake) {
  final List<String> parts = snake.split('_');
  return parts
      .map((String part) =>
          part.substring(0, 1).toUpperCase() + part.substring(1))
      .join();
}

Future<int> _runAndroidUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runAndroidKotlinUnitTests() async {
  const String androidKotlinUnitTestsPath = './$testPluginRelativePath';
  // TODO(stuartmorgan): Move generation to a separate script in tool/ that can
  // easily be run manually as well (e.g., to look at generated code without
  // running tests, or to update generated code when running tests in an IDE).
  const List<String> tests = <String>[
    'all_datatypes',
    'all_void',
    'android_unittests',
    'async_handlers',
    'background_platform_channels',
    'enum_args',
    'enum',
    'host2flutter',
    'list',
    'message',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    'primitive',
    'void_arg_flutter',
    'void_arg_host',
    'voidflutter',
    'voidhost'
  ];
  int generateCode = 0;

  for (final String test in tests) {
    generateCode = await runPigeon(
      input: './pigeons/$test.dart',
      kotlinOut:
          '$androidKotlinUnitTestsPath/android/src/main/kotlin/com/example/test_plugin/${snakeToPascalCase(test)}.kt',
      kotlinPackage: 'com.example.test_plugin',
    );
    if (generateCode != 0) {
      return generateCode;
    }
  }

  const String examplePath = '$androidKotlinUnitTestsPath/example';
  final int gradlewExistsCode = await runProcess(
    './gradlew',
    <String>[],
    workingDirectory: '$examplePath/android',
  );
  if (gradlewExistsCode != 0) {
    final int compileCode = await runProcess(
      'flutter',
      <String>['build', 'apk', '--debug'],
      workingDirectory: examplePath,
    );
    if (compileCode != 0) {
      return compileCode;
    }
  }

  return runProcess(
    './gradlew',
    <String>[
      'testDebugUnitTest',
    ],
    workingDirectory: '$examplePath/android',
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
    final int result = await runPigeon(
        input: job.key, dartOut: job.value, streamOutput: false);
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

  final int analyzeCode = await runProcess(
    'flutter',
    <String>['analyze'],
    workingDirectory: flutterUnitTestsPath,
  );
  if (analyzeCode != 0) {
    return analyzeCode;
  }

  // Delete these files that were just generated to help with the analyzer step.
  File(messagePath).deleteSync();
  File(messageTestPath).deleteSync();
  return 0;
}

Future<int> _runFlutterUnitTests() async {
  const String flutterUnitTestsPath =
      'platform_tests/flutter_null_safe_unit_tests';
  final int generateCode = await _generateDart(<String, String>{
    'pigeons/flutter_unittests.dart':
        '$flutterUnitTestsPath/lib/null_safe_pigeon.dart',
    'pigeons/all_datatypes.dart':
        '$flutterUnitTestsPath/lib/all_datatypes.dart',
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

  final int testCode = await runProcess(
    'flutter',
    <String>['test'],
    workingDirectory: flutterUnitTestsPath,
  );
  if (testCode != 0) {
    return testCode;
  }

  return 0;
}

Future<int> _runIosE2eTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runIosUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runMacOSSwiftUnitTests() async {
  const String macosSwiftUnitTestsPath = './$testPluginRelativePath';
  const List<String> tests = <String>[
    'all_void',
  ];
  int generateCode = 0;

  for (final String test in tests) {
    generateCode = await runPigeon(
      input: './pigeons/$test.dart',
      iosSwiftOut:
          '$macosSwiftUnitTestsPath/macos/Classes/${snakeToPascalCase(test)}.gen.swift',
    );
    if (generateCode != 0) {
      return generateCode;
    }
  }

  const String examplePath = '$macosSwiftUnitTestsPath/example';
  final int compileCode = await runProcess(
    'flutter',
    <String>['build', 'macos'],
    workingDirectory: examplePath,
  );
  if (compileCode != 0) {
    return compileCode;
  }

  return runProcess(
    'xcodebuild',
    <String>[
      '-workspace',
      'Runner.xcworkspace',
      '-scheme',
      'Runner',
      'test',
    ],
    workingDirectory: '$examplePath/macos',
  );
}

Future<int> _runIosSwiftUnitTests() async {
  const String iosSwiftUnitTestsPath = './$testPluginRelativePath';
  const List<String> tests = <String>[
    'all_datatypes',
    'all_void',
    'async_handlers',
    'enum_args',
    'enum',
    'host2flutter',
    'list',
    'message',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    'primitive',
    'void_arg_flutter',
    'void_arg_host',
    'voidflutter',
    'voidhost'
  ];
  int generateCode = 0;

  for (final String test in tests) {
    generateCode = await runPigeon(
      input: './pigeons/$test.dart',
      iosSwiftOut:
          '$iosSwiftUnitTestsPath/ios/Classes/${snakeToPascalCase(test)}.gen.swift',
    );
    if (generateCode != 0) {
      return generateCode;
    }
  }

  const String examplePath = '$iosSwiftUnitTestsPath/example';
  final int compileCode = await runProcess(
    'flutter',
    <String>['build', 'ios', '--simulator'],
    workingDirectory: examplePath,
  );
  if (compileCode != 0) {
    return compileCode;
  }

  return runProcess(
    'xcodebuild',
    <String>[
      '-workspace',
      'Runner.xcworkspace',
      '-scheme',
      'Runner',
      '-sdk',
      'iphonesimulator',
      '-destination',
      'platform=iOS Simulator,name=iPhone 8',
      'test',
    ],
    workingDirectory: '$examplePath/ios',
  );
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

  final int testCode = await runProcess(
    'flutter',
    <String>['test'],
    workingDirectory: unitTestsPath,
  );
  if (testCode != 0) {
    return testCode;
  }
  return 0;
}

Future<int> _runWindowsUnitTests() async {
  const String windowsUnitTestsPath = './$testPluginRelativePath';
  const List<String> tests = <String>[
    'all_datatypes',
    'all_void',
    'async_handlers',
    'enum',
    'host2flutter',
    'list',
    'message',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    'primitive',
    'void_arg_flutter',
    'void_arg_host',
    'voidflutter',
    'voidhost'
  ];
  int generateCode = 0;

  for (final String test in tests) {
    generateCode = await runPigeon(
        input: './pigeons/$test.dart',
        cppHeaderOut: '$windowsUnitTestsPath/windows/test/$test.g.h',
        cppSourceOut: '$windowsUnitTestsPath/windows/test/$test.g.cpp',
        cppNamespace: '${test}_pigeontest');
    if (generateCode != 0) {
      return generateCode;
    }
  }

  const String examplePath = '$windowsUnitTestsPath/example';
  final int compileCode = await runProcess(
      'flutter', <String>['build', 'windows', '--debug'],
      workingDirectory: examplePath);
  if (compileCode != 0) {
    return compileCode;
  }

  return runProcess(
      '$examplePath/build/windows/plugins/test_plugin/Debug/test_plugin_test.exe',
      <String>[]);
}

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addOption(_testFlag, abbr: 't', help: 'Only run specified test.')
    ..addFlag(_listFlag,
        negatable: false, abbr: 'l', help: 'List available tests.')
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

  // If no tests are provided, run a default based on the host platform. This is
  // the mode used by CI.
  if (testsToRun.isEmpty) {
    if (Platform.isWindows) {
      testsToRun = <String>['windows_unittests'];
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
