// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:process/process.dart';

import '../base/command.dart';
import '../base/file_system.dart';
import '../base/logger.dart';
import '../base/project.dart';
import '../base/terminal.dart';

import '../manifest.dart';
import '../utils.dart';

/// Flutter migrate subcommand to check the migration status of the project.
class MigrateStatusCommand extends MigrateCommand {
  MigrateStatusCommand({
    bool verbose = false,
    required this.logger,
    required this.fileSystem,
    required ProcessManager processManager,
    this.standalone = false,
  })  : _verbose = verbose,
        migrateUtils = MigrateUtils(
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
      'diff',
      defaultsTo: true,
      help: 'Shows the diff output when enabled. Enabled by default.',
    );
    argParser.addFlag(
      'show-added-files',
      help: 'Shows the contents of added files. Disabled by default.',
    );
    argParser.addFlag(
      'flutter-subcommand',
      help:
          'Enable when using the flutter tool as a subcommand. This changes the '
          'wording of log messages to indicate the correct suggested commands to use.',
    );
  }

  final bool _verbose;

  final Logger logger;

  final FileSystem fileSystem;

  final MigrateUtils migrateUtils;

  final bool standalone;

  @override
  final String name = 'status';

  @override
  final String description =
      'Prints the current status of the in progress migration.';

  /// Manually marks the lines in a diff that should be printed unformatted for visbility.
  ///
  /// This is used to ensure the initial lines that display the files being diffed and the
  /// git revisions are printed and never skipped.
  final Set<int> _initialDiffLines = <int>{0, 1};

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
      return CommandResult.fail();
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
    }
    if (!stagingDirectory.existsSync()) {
      logger.printStatus(
          'No migration in progress in $stagingDirectory. Start a new migration with:');
      printCommandText('start', logger, standalone: !isSubcommand);
      return const CommandResult(ExitStatus.fail);
    }

    final File manifestFile =
        MigrateManifest.getManifestFileFromDirectory(stagingDirectory);
    if (!manifestFile.existsSync()) {
      logger.printError('No migrate manifest in the migrate working directory '
          'at ${stagingDirectory.path}. Fix the working directory '
          'or abandon and restart the migration.');
      return const CommandResult(ExitStatus.fail);
    }
    final MigrateManifest manifest = MigrateManifest.fromFile(manifestFile);

    final bool showDiff = boolArg('diff') ?? true;
    final bool showAddedFiles = boolArg('show-added-files') ?? true;
    if (showDiff || _verbose) {
      if (showAddedFiles || _verbose) {
        for (final String localPath in manifest.addedFiles) {
          logger.printStatus('Newly added file at $localPath:\n');
          try {
            logger.printStatus(
                stagingDirectory.childFile(localPath).readAsStringSync(),
                color: TerminalColor.green);
          } on FileSystemException {
            logger.printStatus('Contents are byte data\n',
                color: TerminalColor.grey);
          }
        }
      }
      final List<String> files = <String>[];
      files.addAll(manifest.mergedFiles);
      files.addAll(manifest.resolvedConflictFiles(stagingDirectory));
      files.addAll(manifest.remainingConflictFiles(stagingDirectory));
      for (final String localPath in files) {
        final DiffResult result = await migrateUtils.diffFiles(
            project.directory.childFile(localPath),
            stagingDirectory.childFile(localPath));
        if (result.diff != '' && result.diff != null) {
          // Print with different colors for better visibility.
          int lineNumber = -1;
          for (final String line in result.diff!.split('\n')) {
            lineNumber++;
            if (line.startsWith('---') ||
                line.startsWith('+++') ||
                line.startsWith('&&') ||
                _initialDiffLines.contains(lineNumber)) {
              logger.printStatus(line);
              continue;
            }
            if (line.startsWith('-')) {
              logger.printStatus(line, color: TerminalColor.red);
              continue;
            }
            if (line.startsWith('+')) {
              logger.printStatus(line, color: TerminalColor.green);
              continue;
            }
            logger.printStatus(line, color: TerminalColor.grey);
          }
        }
      }
    }

    logger.printBox('Staging directory at `${stagingDirectory.path}`');

    checkAndPrintMigrateStatus(manifest, stagingDirectory, logger: logger);

    final bool readyToApply =
        manifest.remainingConflictFiles(stagingDirectory).isEmpty;

    if (!readyToApply) {
      logger.printStatus('Guided conflict resolution wizard:');
      printCommandText('resolve-conflicts', logger, standalone: !isSubcommand);
      logger.printStatus('Resolve conflicts and accept changes with:');
    } else {
      logger.printStatus(
          'All conflicts resolved. Review changes above and '
          'apply the migration with:',
          color: TerminalColor.green);
    }
    printCommandText('apply', logger, standalone: !isSubcommand);

    return const CommandResult(ExitStatus.success);
  }
}
