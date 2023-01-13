// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'src/base/command.dart';
import 'src/base/file_system.dart';
import 'src/base_dependencies.dart';

import 'src/commands/abandon.dart';
import 'src/commands/apply.dart';
import 'src/commands/resolve_conflicts.dart';
import 'src/commands/start.dart';
import 'src/commands/status.dart';

Future<void> main(List<String> args) async {
  final bool veryVerbose = args.contains('-vv');
  final bool verbose =
      args.contains('-v') || args.contains('--verbose') || veryVerbose;

  final MigrateBaseDependencies baseDependencies = MigrateBaseDependencies();

  final List<MigrateCommand> commands = <MigrateCommand>[
    MigrateStartCommand(
      verbose: verbose,
      logger: baseDependencies.logger,
      fileSystem: baseDependencies.fileSystem,
      processManager: baseDependencies.processManager,
    ),
    MigrateStatusCommand(
      verbose: verbose,
      logger: baseDependencies.logger,
      fileSystem: baseDependencies.fileSystem,
      processManager: baseDependencies.processManager,
    ),
    MigrateAbandonCommand(
        logger: baseDependencies.logger,
        fileSystem: baseDependencies.fileSystem,
        terminal: baseDependencies.terminal,
        processManager: baseDependencies.processManager
    ),
    MigrateApplyCommand(
        verbose: verbose,
        logger: baseDependencies.logger,
        fileSystem: baseDependencies.fileSystem,
        terminal: baseDependencies.terminal,
        processManager: baseDependencies.processManager
    ),
    MigrateResolveConflictsCommand(
        verbose: verbose,
        logger: baseDependencies.logger,
        fileSystem: baseDependencies.fileSystem,
        terminal: baseDependencies.terminal
    ),
  ];

  final MigrateCommandRunner runner = MigrateCommandRunner();

  commands.forEach(runner.addCommand);
  await runner.run(args);

  await _exit(0, baseDependencies,
      shutdownHooks: baseDependencies.fileSystem.shutdownHooks);
  await baseDependencies.fileSystem.dispose();
}

/// Simple extension of a CommandRunner to provide migrate specific global flags.
class MigrateCommandRunner extends CommandRunner<void> {
  MigrateCommandRunner()
      : super(
          'flutter',
          'Migrates legacy flutter projects to modern versions.',
        ) {
    argParser.addFlag('verbose',
        abbr: 'v',
        negatable: false,
        help: 'Noisy logging, including all shell commands executed.');
  }

  @override
  ArgParser get argParser => _argParser;
  final ArgParser _argParser = ArgParser();
}

Future<int> _exit(int code, MigrateBaseDependencies baseDependencies,
    {required ShutdownHooks shutdownHooks}) async {
  // Run shutdown hooks before flushing logs
  await shutdownHooks.runShutdownHooks(baseDependencies.logger);

  final Completer<void> completer = Completer<void>();

  // Give the task / timer queue one cycle through before we hard exit.
  Timer.run(() {
    io.exit(code);
  });

  await completer.future;
  return code;
}
