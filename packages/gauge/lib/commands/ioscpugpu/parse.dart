// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:gauge/commands/base.dart';
import 'package:gauge/parser.dart';

class IosCpuGpuParse extends IosCpuGpuSubcommand {
  @override
  String get name => 'parse';
  @override
  String get description =>
      'parse an existing instruments trace with CPU/GPU measurements.';

  @override
  String get usage {
    final List<String> lines = super.usage.split('\n');
    lines[0] = 'Usage: gauge ioscpugpu parse <trace-file-path>';
    return lines.join('\n');
  }

  @override
  Future<void> run() async {
    if (argResults.rest.length != 1) {
      print(usage);
      throw Exception('exactly one argument <trace-file-path> expected');
    }
    final String path = argResults.rest[0];

    await ensureResources();

    final CpuGpuResult result = IosTraceParser(isVerbose, traceUtilityPath)
        .parseCpuGpu(path, processName);
    result.writeToJsonFile(outJson);
    print('$result\nThe result has been written into $outJson');
  }
}
