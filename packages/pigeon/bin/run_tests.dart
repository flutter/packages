// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// This currently only supports Windows tests.
///
/// usage: pub run pigeon:run_tests
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show Process, exit, stdout, stderr;
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

Future<int> _runAndroidUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runDartCompilationTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runDartUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runFlutterUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runIosE2eTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runIosUnitTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runMockHandlerTests() async {
  throw UnimplementedError('See run_tests.sh.');
}

Future<int> _runPigeon({
  required String input,
  String? cppHeaderOut,
  String? cppSourceOut,
}) async {
  const bool hasDart = false;
  final List<String> args = <String>[
    'pub',
    'run',
    'pigeon',
    '--input',
    input,
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
  if (!hasDart) {
    args.add('--one_language');
  }
  final Process generate = await _streamOutput(Process.start('dart', args));
  final int generateCode = await generate.exitCode;
  if (generateCode != 0) {
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
  List<String> testsToRun = _tests.keys.toList();
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
