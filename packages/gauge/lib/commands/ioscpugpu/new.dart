// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:gauge/commands/base.dart';
import 'package:gauge/parser.dart';

/// See also: [IosCpuGpu]
class IosCpuGpuNew extends IosCpuGpuSubcommand {
  IosCpuGpuNew() {
    argParser.addOption(
      kOptionTimeLimitMs,
      abbr: 'l',
      defaultsTo: '5000',
      help: 'time limit (in ms) to run instruments for measuring',
    );
    argParser.addOption(
      kOptionDevice,
      abbr: 'w',
      help: 'device identifier recognizable by instruments '
          '(e.g., 00008020-000364CE0AF8003A)',
    );
  }

  @override
  String get name => 'new';
  @override
  String get description => 'Take a new measurement on the iOS CPU/GPU '
      'percentage (of Flutter Runner).';

  String get _timeLimit => argResults[kOptionTimeLimitMs];

  String get _templatePath =>
      '$resourcesRoot/resources/CpuGpuTemplate.tracetemplate';

  @override
  Future<void> run() async {
    _checkDevice();
    await ensureResources();

    print('Running instruments on iOS device $_device for ${_timeLimit}ms');

    final List<String> args = <String>[
      '-l',
      _timeLimit,
      '-t',
      _templatePath,
      '-w',
      _device,
    ];
    if (isVerbose) {
      print('instruments args: $args');
    }
    final ProcessResult processResult = Process.runSync('instruments', args);
    _parseTraceFilename(processResult.stdout.toString());

    print('Parsing $_traceFilename');

    final IosTraceParser parser = IosTraceParser(isVerbose, traceUtilityPath);
    final CpuGpuResult result = parser.parseCpuGpu(_traceFilename, processName);
    result.writeToJsonFile(outJson);
    print('$result\nThe result has been written into $outJson');
  }

  String _traceFilename;
  void _parseTraceFilename(String out) {
    const String kPrefix = 'Instruments Trace Complete: ';
    final int prefixIndex = out.indexOf(kPrefix);
    if (prefixIndex == -1) {
      throw Exception('Failed to parse instruments output:\n$out');
    }
    _traceFilename = out.substring(prefixIndex + kPrefix.length).trim();
  }

  String _device;
  void _checkDevice() {
    _device = argResults[kOptionDevice];
    if (_device != null) {
      return;
    }
    final ProcessResult result = Process.runSync(
      'instruments',
      <String>['-s', 'devices'],
    );
    for (String line in result.stdout.toString().split('\n')) {
      if (line.contains('iPhone') && !line.contains('Simulator')) {
        _device = RegExp(r'\[(.+)\]').firstMatch(line).group(1);
        break;
      }
    }
    if (_device == null) {
      print('''
  Option device (-w) is not provided, and failed to find an iPhone(not a
  simulator) from `instruments -s devices`.

  stdout of `instruments -s device`:
  ===========================
  ${result.stdout}
  ===========================

  stderr of `instruments -s device`:
  ===========================
  ${result.stderr}
  ===========================
  ''');
      throw Exception('Failed to determine the device.');
    }
  }
}
