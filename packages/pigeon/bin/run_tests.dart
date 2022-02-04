// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// usage: pub run pigeon:run_tests
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show File, Process, Platform, exit, stderr, stdout;
import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:pigeon/functional.dart';

const String _testFlag = 'test';
const String _listFlag = 'list';

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
  'dart_compilation_tests': _TestInfo(
      function: _runDartCompilationTests,
      description: 'Compilation tests on generated Dart code.'),
  'dart_unittests': _TestInfo(
      function: _runDartUnitTests,
      description: 'Unit tests on and analysis on Pigeon\'s implementation.'),
  'flutter_unittests': _TestInfo(
      function: _runFlutterUnitTests,
      description: 'Unit tests on generated Dart code.'),
  'ios_e2e_tests': _TestInfo(
      function: _runIosE2eTests,
      description: 'End-to-end Objective-C tests run on iOS Simulator'),
  'ios_unittests': _TestInfo(
      function: _runIosUnitTests,
      description: 'Unit tests on generated Objective-C code.'),
  'mock_handler_tests': _TestInfo(
      function: _runMockHandlerTests,
      description: 'Unit tests on generated Dart mock handler code.'),
};

Future<Process> _streamOutput(Future<Process> processFuture) async {
  final Process process = await processFuture;
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  return process;
}

Future<int> _runProcess(String command, List<String> arguments,
    {String? workingDirectory}) async {
  final Process process = await _streamOutput(Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
  ));
  return process.exitCode;
}

Future<int> _runAndroidUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runDartCompilationTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runDartUnitTests() async {
  int exitCode = await _runProcess('dart', <String>['analyze', 'bin']);
  if (exitCode != 0) {
    return exitCode;
  }
  exitCode = await _runProcess('dart', <String>['analyze', 'lib']);
  if (exitCode != 0) {
    return exitCode;
  }
  exitCode = await _runProcess('dart', <String>['test']);
  return exitCode;
}

/// Generates multiple dart files based on the jobs defined in [jobs] which is
/// in the format of (key: input pigeon file path, value: output dart file
/// path).
Future<int> _generateDart(Map<String, String> jobs) async {
  for (final MapEntry<String, String> job in jobs.entries) {
    // TODO(gaaclarke): Make this run the jobs in parallel.  A bug in Dart
    // blocked this (https://github.com/dart-lang/pub/pull/3285).
    final int result = await _runPigeon(
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
  final int generateTestCode = await _runPigeon(
    input: 'pigeons/message.dart',
    dartOut: messagePath,
    dartTestOut: messageTestPath,
    streamOutput: true,
  );
  if (generateTestCode != 0) {
    return generateTestCode;
  }

  final int analyzeCode = await _runProcess(
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
  });
  if (generateCode != 0) {
    return generateCode;
  }

  final int analyzeCode = await _analyzeFlutterUnitTests(flutterUnitTestsPath);
  if (analyzeCode != 0) {
    return analyzeCode;
  }

  final int testCode = await _runProcess(
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

Future<int> _runMockHandlerTests() async {
  const String unitTestsPath = './mock_handler_tester';
  final int generateCode = await _runPigeon(
    input: './pigeons/message.dart',
    dartOut: './mock_handler_tester/test/message.dart',
    dartTestOut: './mock_handler_tester/test/test.dart',
  );
  if (generateCode != 0) {
    return generateCode;
  }

  final int testCode = await _runProcess(
    'flutter',
    <String>['test'],
    workingDirectory: unitTestsPath,
  );
  if (testCode != 0) {
    return testCode;
  }
  return 0;
}

Future<int> _runPigeon(
    {required String input,
    String? cppHeaderOut,
    String? cppSourceOut,
    String? dartOut,
    String? dartTestOut,
    bool streamOutput = true}) async {
  const bool hasDart = false;
  final List<String> args = <String>[
    'pub',
    'run',
    'pigeon',
    '--input',
    input,
    '--copyright_header',
    './copyright_header.txt',
  ];
  if (cppHeaderOut != null) {
    args.addAll(<String>[
      '--objc_header_out', // TODO(gaaclarke): Switch to c++.
      cppHeaderOut,
    ]);
  }
  if (cppSourceOut != null) {
    args.addAll(<String>[
      '--objc_source_out', // TODO(gaaclarke): Switch to c++.
      cppSourceOut,
    ]);
  }
  if (dartOut != null) {
    args.addAll(<String>['--dart_out', dartOut]);
  }
  if (dartTestOut != null) {
    args.addAll(<String>['--dart_test_out', dartTestOut]);
  }
  if (!hasDart) {
    args.add('--one_language');
  }
  final Process generate = streamOutput
      ? await _streamOutput(Process.start('dart', args))
      : await Process.start('dart', args);
  final int generateCode = await generate.exitCode;
  if (generateCode != 0) {
    if (!streamOutput) {
      print('dart $args failed:');
      generate.stdout.pipe(stdout);
      generate.stderr.pipe(stderr);
    }
    return generateCode;
  }
  return 0;
}

Future<int> _runWindowsUnitTests() async {
  const String windowsUnitTestsPath = './platform_tests/windows_unit_tests';
  final int generateCode = await _runPigeon(
    input: './pigeons/message.dart',
    cppHeaderOut: '$windowsUnitTestsPath/windows/test/message.g.h',
    cppSourceOut: '$windowsUnitTestsPath/windows/test/message.g.cpp',
  );
  if (generateCode != 0) {
    return generateCode;
  }

  final Process compile = await _streamOutput(Process.start(
      'flutter', <String>['build', 'windows', '--debug'],
      workingDirectory: '$windowsUnitTestsPath/example', runInShell: true));
  final int compileCode = await compile.exitCode;
  if (compileCode != 0) {
    return compileCode;
  }

  final Process run = await _streamOutput(Process.start(
      '$windowsUnitTestsPath/example/build/windows/plugins/windows_unit_tests/Debug/windows_unit_tests_test.exe',
      <String>[]));

  return run.exitCode;
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
    for (final MapEntry<String, _TestInfo> info in _tests.entries) {
      final int tabCount = (4 - info.key.length / 8).toInt();
      final String tabs = repeat('\t', tabCount).join('');
      print('${info.key}$tabs- ${info.value.description}');
    }
    exit(0);
  } else if (argResults.wasParsed('help')) {
    print('''
Pigeon run_tests
usage: pub run pigeon:run_tests [-l | -t <test name>]

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
