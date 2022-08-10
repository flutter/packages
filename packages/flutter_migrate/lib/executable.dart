// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:process/process.dart';

import 'src/base/command.dart';
import 'src/base/common.dart';
import 'src/base/file_system.dart';
import 'src/base/io.dart';
import 'src/base/logger.dart';
import 'src/base/signals.dart';
import 'src/base/terminal.dart';

import 'src/commands/abandon.dart';
import 'src/commands/apply.dart';
import 'src/commands/resolve_conflicts.dart';
import 'src/commands/start.dart';
import 'src/commands/status.dart';

Future<void> main(List<String> args) async {
  final bool veryVerbose = args.contains('-vv');
  final bool verbose = args.contains('-v') || args.contains('--verbose') || veryVerbose;

  const ProcessManager localProcessManager = LocalProcessManager();
  final FileSystem fileSystem = LocalFileSystem(LocalSignals.instance, Signals.defaultExitSignals, ShutdownHooks());

  // flutterRoot must be set early because other features use it (e.g.
  // enginePath's initializer uses it). This can only work with the real
  // instances of the platform or filesystem, so just use those.
  flutterRoot = defaultFlutterRoot(fileSystem: fileSystem);

  final Stdio stdio = Stdio();
  final Terminal terminal = AnsiTerminal(stdio: stdio);

  final LoggerFactory loggerFactory = LoggerFactory(
    outputPreferences: OutputPreferences(
      wrapText: stdio.hasTerminal,
      showColor: stdout.supportsAnsiEscapes,
      stdio: stdio,
    ),
    terminal: terminal,
    stdio: stdio,
  );
  final Logger logger = loggerFactory.createLogger(
    windows: isWindows,
  );

  final List<MigrateCommand> commands = <MigrateCommand>[
    MigrateStartCommand(
      verbose: verbose,
      logger: logger,
      fileSystem: fileSystem,
      processManager: localProcessManager,
    ),
    MigrateStatusCommand(
      verbose: verbose,
      logger: logger,
      fileSystem: fileSystem,
      processManager: localProcessManager,
    ),
    MigrateResolveConflictsCommand(
      logger: logger,
      fileSystem: fileSystem,
      terminal: terminal,
    ),
    MigrateAbandonCommand(
      logger: logger,
      fileSystem: fileSystem,
      terminal: terminal,
      processManager: localProcessManager
    ),
    MigrateApplyCommand(
      verbose: verbose,
      logger: logger,
      fileSystem: fileSystem,
      terminal: terminal,
      processManager: localProcessManager
    ),
  ];

  for (final MigrateCommand command in commands) {
    if (command.name == args[0]) {
      command.run();
      break;
    }
  }
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
  }) : _terminal = terminal,
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
        stopwatchFactory: _stopwatchFactory
      );
    }
    return logger;
  }
}
