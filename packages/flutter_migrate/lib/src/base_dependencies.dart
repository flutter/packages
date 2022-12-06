// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:process/process.dart';

import 'base/common.dart';
import 'base/file_system.dart';
import 'base/io.dart';
import 'base/logger.dart';
import 'base/signals.dart';
import 'base/terminal.dart';

/// Initializes the boilerplate dependencies needed by the migrate tool.
class MigrateBaseDependencies {
  MigrateBaseDependencies() {
    processManager = const LocalProcessManager();
    fileSystem = LocalFileSystem(
        LocalSignals.instance, Signals.defaultExitSignals, ShutdownHooks());

    stdio = Stdio();
    terminal = AnsiTerminal(stdio: stdio);

    final LoggerFactory loggerFactory = LoggerFactory(
      outputPreferences: OutputPreferences(
        wrapText: stdio.hasTerminal,
        showColor: stdout.supportsAnsiEscapes,
        stdio: stdio,
      ),
      terminal: terminal,
      stdio: stdio,
    );
    logger = loggerFactory.createLogger(
      windows: isWindows,
    );
  }

  late ProcessManager processManager;
  late FileSystem fileSystem;
  late Stdio stdio;
  late Terminal terminal;
  late Logger logger;
}

/// An abstraction for instantiation of the correct logger type.
///
/// Our logger class hierarchy and runtime requirements are overly complicated.
class LoggerFactory {
  LoggerFactory({
    required Terminal terminal,
    required Stdio stdio,
    required OutputPreferences outputPreferences,
    StopwatchFactory stopwatchFactory = const StopwatchFactory(),
  })  : _terminal = terminal,
        _stdio = stdio,
        _stopwatchFactory = stopwatchFactory,
        _outputPreferences = outputPreferences;

  final Terminal _terminal;
  final Stdio _stdio;
  final StopwatchFactory _stopwatchFactory;
  final OutputPreferences _outputPreferences;

  /// Create the appropriate logger for the current platform and configuration.
  Logger createLogger({
    required bool windows,
  }) {
    Logger logger;
    if (windows) {
      logger = WindowsStdoutLogger(
        terminal: _terminal,
        stdio: _stdio,
        outputPreferences: _outputPreferences,
        stopwatchFactory: _stopwatchFactory,
      );
    } else {
      logger = StdoutLogger(
          terminal: _terminal,
          stdio: _stdio,
          outputPreferences: _outputPreferences,
          stopwatchFactory: _stopwatchFactory);
    }
    return logger;
  }
}
