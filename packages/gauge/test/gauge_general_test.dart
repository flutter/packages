// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

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
}
