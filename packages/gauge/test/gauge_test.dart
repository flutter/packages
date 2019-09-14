// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('mac-os')

import 'dart:io';

import 'package:test/test.dart';

import 'package:gauge/commands/base.dart';

void main() {
  const String gaugeRootPath = '.';
  final String resourcesRootPath = BaseCommand.defaultResourcesRoot;
  BaseCommand.doEnsureResources(resourcesRootPath, isVerbose: true);

  test('help works', () {
    final ProcessResult result = Process.runSync(
      'dart',
      <String>['$gaugeRootPath/bin/gauge.dart', 'help'],
    );
    expect(
        result.stdout.toString(),
        contains(
          'Tools for gauging/measuring some performance metrics.',
        ));
  });

  ProcessResult _testIosCpuGpu(List<String> extraArgs) {
    return Process.runSync(
      'dart',
      <String>[
        '$gaugeRootPath/bin/gauge.dart',
        'ioscpugpu',
        ...extraArgs,
        '-r',
        resourcesRootPath,
      ],
    );
  }

  ProcessResult _testParse(List<String> extraArgs) {
    return _testIosCpuGpu(<String>[
      'parse',
      '$resourcesRootPath/resources/example_instrumentscli.trace/',
      ...extraArgs,
    ]);
  }

  test('ioscpugpu parse works', () {
    final ProcessResult result = _testParse(<String>[]);
    expect(
        result.stdout.toString(),
        contains(
          'gpu: 12.6%, cpu: 18.15%',
        ));
    expect(
        File('result.json').readAsStringSync(),
        contains(
          '{"gpu_percentage":12.6,"cpu_percentage":18.15}',
        ));
  });

  test('ioscpugpu parse works with verbose', () {
    final ProcessResult result = _testParse(<String>['--verbose']);
    expect(
        result.stdout.toString(),
        contains(
          '00:00.000.000  0 FPS 13.0% GPU',
        ));
    expect(
        result.stdout.toString(),
        contains(
          '00:00.477.632, 1.55 s, Runner (2209), n/a, 2209, mobile, 23.7%',
        ));
  });

  test('ioscpugpu new works', () {
    final ProcessResult result = _testIosCpuGpu(<String>['new']);
    expect(
      result.stdout.toString(),
      contains('The result has been written into result.json'),
      reason: '\n\nioscpugpu new failed. Do you have a single connected iPhone '
          'that has a Flutter app running?',
    );
  });
}
