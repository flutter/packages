// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'src/base/command.dart';
import 'src/base/terminal.dart';

import 'src/base_dependencies.dart';

import 'src/commands/abandon.dart';
import 'src/commands/apply.dart';
import 'src/commands/start.dart';
import 'src/commands/status.dart';

Future<void> main(List<String> args) async {
  final bool veryVerbose = args.contains('-vv');
  final bool verbose =
      args.contains('-v') || args.contains('--verbose') || veryVerbose;

  final MigrateBaseDependencies baseDependencies = MigrateBaseDependencies();

  if (args.isEmpty) {
    baseDependencies.logger.printError('No subcommand specified. Use the --help or -h flag to see options.');
    return;
  }

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
        processManager: baseDependencies.processManager),
    MigrateApplyCommand(
        verbose: verbose,
        logger: baseDependencies.logger,
        fileSystem: baseDependencies.fileSystem,
        terminal: baseDependencies.terminal,
        processManager: baseDependencies.processManager),
  ];

  if (args.contains('-h') || args.contains('--help')) {
    for (final MigrateCommand command in commands) {
      baseDependencies.logger.printStatus('${command.name}:');
      baseDependencies.logger.printStatus(
        command.description,
        color: TerminalColor.grey,
        indent: 2,
      );
    }
  }

  for (final MigrateCommand command in commands) {
    if (command.name == args[0]) {
      await command.runCommand();
      break;
    }
  }
  await baseDependencies.fileSystem.dispose();
}
