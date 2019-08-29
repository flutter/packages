// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:measure/commands/base.dart';
import 'package:measure/parser.dart';

class IosCpuGpuNew extends IosCpuGpuSubcommand {
  IosCpuGpuNew() {
    argParser.addOption(
      kOptionTimeLimitMs,
      abbr: 'l',
      defaultsTo: '5000',
      help: 'time limit (in ms) to run instruments for measuring',
    );
    argParser.addOption(
      kOptionTemplate,
      abbr: 't',
      help: 'instruments template'
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

  @override
  Future<void> run() async {
    checkRequiredOption(kOptionTemplate);
    checkRequiredOption(kOptionTraceUtility);
    _checkDevice();

    print('Running instruments on iOS device $_device for ${_timeLimit}ms');

    final List<String> args = <String>[
      '-l', _timeLimit,
      '-t', argResults[kOptionTemplate],
      '-w', _device,
    ];
    if (isVerbose) {
      print('instruments args: $args');
    }
    final ProcessResult processResult = Process.runSync('instruments', args);
    _parseTraceFilename(processResult.stdout.toString());

    print('Parsing $_traceFilename');

    final CpuGpuResult result =
        IosTraceParser(isVerbose, traceUtility).parseCpuGpu(_traceFilename, processName);
    result.writeToJsonFile(outJson);
    print('$result\nThe result has been written into $outJson');
  }
  String _traceFilename;
  Future<void> _parseTraceFilename(String out) async {
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
    if (_device == null) {
      final ProcessResult result = Process.runSync('flutter', <String>['devices']);
      if (result.stdout.toString().contains('1 connected device')) {
        final List<String> lines = result.stdout.toString().split('\n');
        const String kSeparator = '•';
        for (String line in lines) {
          if (line.contains(kSeparator)) {
            final int left = line.indexOf(kSeparator);
            final int right = line.indexOf(kSeparator, left + 1);
            _device = line.substring(left + 1, right).trim();
          }
        }
        if (_device == null) {
          print('Failed to parse `flutter devices` output:\n ${result.stdout}');
        }
      } else {
        print('''
Option device is not provided, and `flutter devices` returns either 0 or more
than 1 devices, or errored.

stdout of `flutter devices`:
===========================
${result.stdout}
===========================

stderr of `flutter devices`:
===========================
${result.stderr}
===========================
'''
        );
      }
    }

    if (_device == null) {
      throw Exception('Failed to determine the device.');
    }
  }
}
