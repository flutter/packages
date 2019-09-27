// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('posix')

import 'dart:io';

import 'package:gauge/commands/base.dart';
import 'package:test/test.dart';

void main() {
  final String gaugeRootPath = Directory.current.absolute.path;

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

  test('ioscpugpu parse help works', () {
    final ProcessResult result = Process.runSync(
      'dart',
      <String>['$gaugeRootPath/bin/gauge.dart', 'ioscpugpu', 'parse'],
    );
    final String help = result.stdout.toString();
    expect(
      help.split('\n')[0],
      equals('Parse an existing instruments trace with CPU/GPU measurements.'),
    );
    expect(
      help,
      contains('Usage: gauge ioscpugpu parse [arguments] <trace-file-path>'),
    );
  });

  test('cipd downloading is triggered.', () {
    final ProcessResult result = Process.runSync(
      'dart',
      <String>[
        '$gaugeRootPath/bin/gauge.dart',
        'ioscpugpu',
        'parse',
        'non-existent-file',
        '--verbose'
      ],
    );
    expect(
      result.stdout.toString(),
      contains('Downloading resources from CIPD...'),
    );
    expect(
      Directory('${BaseCommand.defaultResourcesRoot}/resources').existsSync(),
      isTrue,
    );
  });

  test('depot_tools is downloaded.', () {
    final Directory depotToolsDir =
        Directory('${BaseCommand.defaultResourcesRoot}/depot_tools');
    if (depotToolsDir.existsSync()) {
      depotToolsDir.deleteSync(recursive: true);
    }
    expect(
      depotToolsDir.existsSync(),
      isFalse,
    );
    Process.runSync(
      'dart',
      <String>[
        '$gaugeRootPath/bin/gauge.dart',
        'ioscpugpu',
        'parse',
        'non-existent-file',
        '--verbose'
      ],
    );
    expect(
      depotToolsDir.existsSync(),
      isTrue,
    );
  });
}
