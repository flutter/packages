// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

const String kOptionTimeLimitMs = 'time-limit-ms';
const String kOptionTemplate = 'template';
const String kOptionDevice = 'device';
const String kOptionProessName = 'process-name';
const String kOptionTraceUtility = 'trace-utility';
const String kOptionOutJson = 'out-json';
const String kFlagVerbose = 'verbose';

const String kDefaultProccessName = 'Runner';  // Flutter app's default process

abstract class BaseCommand extends Command<void> {
  BaseCommand() {
    argParser.addFlag(kFlagVerbose);
    argParser.addOption(
      kOptionOutJson,
      abbr: 'o',
      help: 'json file for the measure result.',
      defaultsTo: 'result.json',
    );
  }

  @protected
  void checkRequiredOption(String option) {
    if (argResults[option] == null) {
      throw Exception('Option $option is required.');
    }
  }

  @protected
  bool get isVerbose => argResults[kFlagVerbose];
  @protected
  String get outJson => argResults[kOptionOutJson];
}

abstract class IosCpuGpuSubcommand extends BaseCommand {
  IosCpuGpuSubcommand() {
    argParser.addOption(
      kOptionTraceUtility,
      abbr: 'u',
      help:
        'Specifies path to TraceUtility binary '
        '(https://github.com/Qusic/TraceUtility).',
    );
    argParser.addOption(
      kOptionProessName,
      abbr: 'p',
      help:
        'Specifies the process name used for filtering the instruments CPU '
        'measurements.',
      defaultsTo: kDefaultProccessName,
    );
  }

  @protected
  String get traceUtility => argResults[kOptionTraceUtility];
  @protected
  String get processName => argResults[kOptionProessName];
}
