// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'src/base/command.dart';

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

  for (final MigrateCommand command in commands) {
    if (command.name == args[0]) {
      await command.run();
      break;
    }
  }
  exit(0);
}
