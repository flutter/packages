// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// usage: dart run tool/test.dart
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show Platform, exit;
import 'dart:math';

import 'package:args/args.dart';

import 'shared/test_runner.dart';
import 'shared/test_suites.dart';

const String _testFlag = 'test';
const String _listFlag = 'list';

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addMultiOption(_testFlag, abbr: 't', help: 'Only run specified tests.')
    ..addFlag(_listFlag,
        negatable: false, abbr: 'l', help: 'List available tests.')
    ..addFlag('help',
        negatable: false, abbr: 'h', help: 'Print this reference.');

  final ArgResults argResults = parser.parse(args);
  List<String> testsToRun = <String>[];
  if (argResults.wasParsed(_listFlag)) {
    print('available tests:');

    final int columnWidth =
        testSuites.keys.map((String key) => key.length).reduce(max) + 4;

    for (final MapEntry<String, TestInfo> info in testSuites.entries) {
      print('${info.key.padRight(columnWidth)}- ${info.value.description}');
    }
    exit(0);
  } else if (argResults.wasParsed('help')) {
    print('''
Pigeon run_tests
usage: dart run tool/test.dart [-l | -t <test name>]

${parser.usage}''');
    exit(0);
  } else if (argResults.wasParsed(_testFlag)) {
    testsToRun = argResults[_testFlag] as List<String>;
  }

  // If no tests are provided, run everything that is supported on the current
  // platform.
  if (testsToRun.isEmpty) {
    const List<String> dartTests = <String>[
      dartUnitTests,
      flutterUnitTests,
      mockHandlerTests,
      commandLineTests,
    ];
    const List<String> androidTests = <String>[
      androidJavaUnitTests,
      androidKotlinUnitTests,
      androidJavaIntegrationTests,
      androidKotlinIntegrationTests,
      androidJavaLint,
    ];
    const List<String> iOSTests = <String>[
      iOSObjCUnitTests,
      iOSObjCIntegrationTests,
      iOSSwiftUnitTests,
      iOSSwiftIntegrationTests,
    ];
    const List<String> macOSTests = <String>[
      macOSSwiftUnitTests,
      macOSSwiftIntegrationTests
    ];
    const List<String> windowsTests = <String>[
      windowsUnitTests,
      windowsIntegrationTests,
    ];

    if (Platform.isMacOS) {
      testsToRun = <String>[
        ...dartTests,
        ...androidTests,
        ...iOSTests,
        ...macOSTests,
      ];
    } else if (Platform.isWindows) {
      testsToRun = <String>[
        ...dartTests,
        ...windowsTests,
      ];
    } else if (Platform.isLinux) {
      testsToRun = <String>[
        ...dartTests,
        ...androidTests,
      ];
    } else {
      print('Unsupported host platform.');
      exit(1);
    }
  }

  await runTests(testsToRun);
}
