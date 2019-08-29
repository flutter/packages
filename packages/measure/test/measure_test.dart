// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  const String measureRootPath = '.';

  test('help works', () {
    final ProcessResult result = Process.runSync(
      'dart', <String>['$measureRootPath/bin/measure.dart', 'help'],
    );
    expect(result.stdout.toString(), contains(
      'Tools for measuring some performance metrics.',
    ));
  });

  ProcessResult _testIosCpuGpu(List<String> extraArgs) {
    return Process.runSync(
      'dart',
      <String>[
        '$measureRootPath/bin/measure.dart',
        'ioscpugpu',
        ...extraArgs,
      ],
    );
  }

  test('trace-utility is required for ioscpugpu parse', () {
    final ProcessResult result = _testIosCpuGpu(
      <String>['parse', 'not_existed.trace'],
    );
    expect(result.stderr.toString(), contains(
      'Option trace-utility is required.',
    ));
  });

  test('trace-utility is required for ioscpugpu new', () {
    final ProcessResult result = _testIosCpuGpu(
      <String>['new', '-t', 'not_existed.tracetemplate'],
    );
    expect(result.stderr.toString(), contains(
      'Option trace-utility is required.',
    ));
  });

  ProcessResult _testParse(List<String> extraArgs) {
    Process.runSync('unzip', <String>[
      '-u', '$measureRootPath/resources/example_instrumentscli.trace.zip',
      '-d', '$measureRootPath/resources/',
    ]);
    return _testIosCpuGpu(<String>[
        'parse',
        '-u',
        '$measureRootPath/resources/TraceUtility',
        '$measureRootPath/resources/example_instrumentscli.trace/',
        ...extraArgs,
    ]);
  }

  test('ioscpugpu parse works', () {
    final ProcessResult result = _testParse(<String>[]);
    expect(result.stdout.toString(), contains(
      'gpu: 12.6%, cpu: 18.15%',
    ));
    expect(File('result.json').readAsStringSync(), contains(
      '{"gpu_percentage":12.6,"cpu_percentage":18.15}',
    ));
  });

  test('ioscpugpu parse works with verbose', () {
    final ProcessResult result = _testParse(<String>['--verbose']);
    expect(result.stdout.toString(), contains(
      '00:00.000.000  0 FPS 13.0% GPU',
    ));
    expect(result.stdout.toString(), contains(
      '00:00.477.632, 1.55 s, Runner (2209), n/a, 2209, mobile, 23.7%',
    ));
  });

  test('ioscpugpu new works', () {
    final ProcessResult result = _testIosCpuGpu(<String>[
      'new',
      '-u',
      '$measureRootPath/resources/TraceUtility',
      '-t',
      '$measureRootPath/resources/CpuGpuTemplate.tracetemplate',
    ]);
    expect(
      result.stdout.toString(),
      contains('The result has been written into result.json'),
      reason: '\n\nioscpugpu new failed. Do you have a single connected iPhone '
              'that has a Flutter app running?',
    );
  });
}
