// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:process/process.dart';

import '../base/command.dart';
import '../base/file_system.dart';
import '../base/logger.dart';
import '../base/project.dart';
import '../base/terminal.dart';

import '../utils.dart';

/// Abandons the existing migration by deleting the migrate working directory.
class MigrateAbandonCommand extends MigrateCommand {
  MigrateAbandonCommand({
    required this.logger,
    required this.fileSystem,
    required this.terminal,
    required ProcessManager processManager,
    this.standalone = false,
  }) : migrateUtils = MigrateUtils(
          logger: logger,
          fileSystem: fileSystem,
          processManager: processManager,
        ) {
    argParser.addOption(
      'staging-directory',
      help: 'Specifies the custom migration working directory used to stage '
          'and edit proposed changes. This path can be absolute or relative '
          'to the flutter project root. This defaults to '
          '`$kDefaultMigrateStagingDirectoryName`',
      valueHelp: 'path',
    );
    argParser.addOption(
      'project-directory',
      help: 'The root directory of the flutter project. This defaults to the '
          'current working directory if omitted.',
      valueHelp: 'path',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      help:
          'Delete the migrate working directory without asking for confirmation.',
    );
    argParser.addFlag(
      'flutter-subcommand',
      help:
          'Enable when using the flutter tool as a subcommand. This changes the '
          'wording of log messages to indicate the correct suggested commands to use.',
    );
  }

  final Logger logger;

  final FileSystem fileSystem;

  final Terminal terminal;

  final MigrateUtils migrateUtils;

  final bool standalone;

  @override
  final String name = 'abandon';

  @override
  final String description =
      'Deletes the current active migration working directory.';

  @override
  Future<CommandResult> runCommand() async {
    final String? projectDirectory = stringArg('project-directory');
    final FlutterProjectFactory flutterProjectFactory = FlutterProjectFactory();
    final FlutterProject project = projectDirectory == null
        ? FlutterProject.current(fileSystem)
        : flutterProjectFactory
            .fromDirectory(fileSystem.directory(projectDirectory));
    final bool isSubcommand = boolArg('flutter-subcommand') ?? !standalone;

    if (!validateWorkingDirectory(project, logger)) {
      return const CommandResult(ExitStatus.fail);
    }

    Directory stagingDirectory =
        project.directory.childDirectory(kDefaultMigrateStagingDirectoryName);
    final String? customStagingDirectoryPath = stringArg('staging-directory');
    if (customStagingDirectoryPath != null) {
      if (fileSystem.path.isAbsolute(customStagingDirectoryPath)) {
        stagingDirectory = fileSystem.directory(customStagingDirectoryPath);
      } else {
        stagingDirectory =
            project.directory.childDirectory(customStagingDirectoryPath);
      }
      if (!stagingDirectory.existsSync()) {
        logger.printError(
            'Provided staging directory `$customStagingDirectoryPath` '
            'does not exist or is not valid.');
        return const CommandResult(ExitStatus.fail);
      }
    }
    if (!stagingDirectory.existsSync()) {
      logger
          .printStatus('No migration in progress. Start a new migration with:');
      printCommandText('start', logger, standalone: !isSubcommand);
      return const CommandResult(ExitStatus.fail);
    }

    logger.printStatus('\nAbandoning the existing migration will delete the '
        'migration staging directory at ${stagingDirectory.path}');
    final bool force = boolArg('force') ?? false;
    if (!force) {
      String selection = 'y';
      terminal.usesTerminalUi = true;
      try {
        selection = await terminal.promptForCharInput(
          <String>['y', 'n'],
          logger: logger,
          prompt:
              'Are you sure you wish to continue with abandoning? (y)es, (N)o',
          defaultChoiceIndex: 1,
        );
      } on StateError catch (e) {
        logger.printError(
          e.message,
          indent: 0,
        );
      }
      if (selection != 'y') {
        return const CommandResult(ExitStatus.success);
      }
    }

    try {
      stagingDirectory.deleteSync(recursive: true);
    } on FileSystemException catch (e) {
      logger.printError('Deletion failed with: $e');
      logger.printError(
          'Please manually delete the staging directory at `${stagingDirectory.path}`');
    }

    logger.printStatus('\nAbandon complete. Start a new migration with:');
    printCommandText('start', logger, standalone: !isSubcommand);
    return const CommandResult(ExitStatus.success);
  }
}
