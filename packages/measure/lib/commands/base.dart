// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

const String kOptionResourcesRoot = 'resources-root';
const String kOptionTimeLimitMs = 'time-limit-ms';
const String kOptionDevice = 'device';
const String kOptionProessName = 'process-name';
const String kOptionOutJson = 'out-json';
const String kFlagVerbose = 'verbose';

const String kDefaultProccessName = 'Runner'; // Flutter app's default process

abstract class BaseCommand extends Command<void> {
  BaseCommand() {
    argParser.addFlag(kFlagVerbose);
    argParser.addOption(
      kOptionOutJson,
      abbr: 'o',
      help: 'Specifies the json file for result output.',
      defaultsTo: 'result.json',
    );
    argParser.addOption(
      kOptionResourcesRoot,
      abbr: 'r',
      help: 'Specifies the path to download resources',
      defaultsTo: defaultResourcesRoot,
    );
  }

  static String get defaultResourcesRoot =>
      '${Platform.environment['HOME']}/.measure';

  static Future<void> doEnsureResources(String rootPath,
      {bool isVerbose}) async {
    final Directory root = await Directory(rootPath).create(recursive: true);
    final Directory previous = Directory.current;
    Directory.current = root;
    final File ensureFile = File('ensure_file.txt');
    ensureFile.writeAsStringSync('flutter/packages/measure/resources latest');
    if (isVerbose) {
      print('Downloading resources from CIPD...');
    }
    final ProcessResult result = Process.runSync(
      'cipd',
      <String>[
        'ensure',
        '-ensure-file',
        'ensure_file.txt',
        '-root',
        '.',
      ],
    );
    if (result.exitCode != 0) {
      print('cipd ensure stdout:\n${result.stdout}\n');
      print('cipd ensure stderr:\n${result.stderr}\n');
      throw Exception('Failed to download the CIPD package.');
    }
    if (isVerbose) {
      print('Download completes.');
    }
    Directory.current = previous;
  }

  @protected
  Future<void> ensureResources() async {
    doEnsureResources(resourcesRoot, isVerbose: isVerbose);
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
  @protected
  String get resourcesRoot => argResults[kOptionResourcesRoot];
}

abstract class IosCpuGpuSubcommand extends BaseCommand {
  IosCpuGpuSubcommand() {
    argParser.addOption(
      kOptionProessName,
      abbr: 'p',
      help: 'Specifies the process name used for filtering the instruments CPU '
          'measurements.',
      defaultsTo: kDefaultProccessName,
    );
  }

  @protected
  String get processName => argResults[kOptionProessName];
  @protected
  String get traceUtilityPath => '$resourcesRoot/resources/TraceUtility';
}
