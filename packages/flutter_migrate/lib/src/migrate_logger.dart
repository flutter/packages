// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'base/logger.dart';
import 'base/terminal.dart';

const int kDefaultStatusIndent = 2;

class MigrateLogger {
  MigrateLogger({
    required this.logger,
    this.verbose = false,
    this.silent = false,
  }) : status = logger.startSpinner();

  final Logger logger;
  // We keep a spinner going and print periodic progress messages
  // to assure the developer that the command is still working due to
  // the long expected runtime.
  Status status;
  final bool verbose;
  final bool silent;

  void start() {
    status = logger.startSpinner();
  }

  void stop() {
    status.stop();
  }

  static final Map<String, String> _stepStringsMap = <String, String>{
    'start': 'Computing migration - this command may take a while to complete.',
    'revisions': 'Obtaining revisions.',
    'unmanaged': 'Parsing unmanagedFiles.',
    'generating_base': 'Generating base reference app.',
    'diff': 'Diffing base and target reference app.',
    'new_files': 'Finding newly added files',
    'merging': 'Merging changes with existing project.',
    'cleaning': 'Cleaning up temp directories.',
    'modified_count':
        'Could not determine base revision, falling back on `v1.0.0`, revision 5391447fae6209bb21a89e6a5a6583cac1af9b4b',
  };

  void printStatus(String message, {int indent = kDefaultStatusIndent}) {
    if (silent) {
      return;
    }
    status.pause();
    logger.printStatus(message, indent: indent, color: TerminalColor.grey);
    status.resume();
  }

  void printError(String message, {int indent = 0}) {
    status.pause();
    logger.printError(message, indent: indent);
    status.resume();
  }

  void logStep(String key) {
    if (!_stepStringsMap.containsKey(key)) {
      return;
    }
    printStatus(_stepStringsMap[key]!);
  }

  void printIfVerbose(String message, {int indent = kDefaultStatusIndent}) {
    if (verbose) {
      printStatus(message, indent: indent);
    }
  }
}
