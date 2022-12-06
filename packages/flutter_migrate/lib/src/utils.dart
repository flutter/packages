// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:process/process.dart';

import 'base/common.dart';
import 'base/file_system.dart';
import 'base/logger.dart';
import 'base/terminal.dart';

/// The default name of the migrate working directory used to stage proposed changes.
const String kDefaultMigrateStagingDirectoryName = 'migrate_staging_dir';

/// Utility class that contains methods that wrap git and other shell commands.
class MigrateUtils {
  MigrateUtils({
    required Logger logger,
    required FileSystem fileSystem,
    required ProcessManager processManager,
  })  : _processManager = processManager,
        _logger = logger,
        _fileSystem = fileSystem;

  final Logger _logger;
  final FileSystem _fileSystem;
  final ProcessManager _processManager;

  Future<ProcessResult> _runCommand(List<String> command,
      {String? workingDirectory, bool runInShell = false}) {
    return _processManager.run(command,
        workingDirectory: workingDirectory, runInShell: runInShell);
  }

  /// Calls `git diff` on two files and returns the diff as a DiffResult.
  Future<DiffResult> diffFiles(File one, File two) async {
    if (one.existsSync() && !two.existsSync()) {
      return DiffResult(diffType: DiffType.deletion);
    }
    if (!one.existsSync() && two.existsSync()) {
      return DiffResult(diffType: DiffType.addition);
    }
    final List<String> cmdArgs = <String>[
      'git',
      'diff',
      '--no-index',
      one.absolute.path,
      two.absolute.path
    ];
    final ProcessResult result = await _runCommand(cmdArgs);

    // diff exits with 1 if diffs are found.
    checkForErrors(result,
        allowedExitCodes: <int>[0, 1],
        commandDescription: 'git ${cmdArgs.join(' ')}');
    return DiffResult(
        diffType: DiffType.command,
        diff: result.stdout,
        exitCode: result.exitCode);
  }

  /// Clones a copy of the flutter repo into the destination directory. Returns false if unsuccessful.
  Future<bool> cloneFlutter(String revision, String destination) async {
    // Use https url instead of ssh to avoid need to setup ssh on git.
    List<String> cmdArgs = <String>[
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/flutter/flutter.git',
      destination
    ];
    ProcessResult result = await _runCommand(cmdArgs);
    checkForErrors(result, commandDescription: cmdArgs.join(' '));

    cmdArgs.clear();
    cmdArgs = <String>['git', 'reset', '--hard', revision];
    result = await _runCommand(cmdArgs, workingDirectory: destination);
    if (!checkForErrors(result,
        commandDescription: cmdArgs.join(' '), exit: false)) {
      return false;
    }
    return true;
  }

  /// Calls `flutter create` as a re-entrant command.
  Future<String> createFromTemplates(
    String flutterBinPath, {
    required String name,
    bool legacyNameParameter = false,
    required String androidLanguage,
    required String iosLanguage,
    required String outputDirectory,
    String? createVersion,
    List<String> platforms = const <String>[],
    int iterationsAllowed = 5,
  }) async {
    // Limit the number of iterations this command is allowed to attempt to prevent infinite looping.
    if (iterationsAllowed <= 0) {
      _logger.printError(
          'Unable to `flutter create` with the version of flutter at $flutterBinPath');
      return outputDirectory;
    }

    final List<String> cmdArgs = <String>['$flutterBinPath/flutter', 'create'];
    if (!legacyNameParameter) {
      cmdArgs.add('--project-name=$name');
    }
    cmdArgs.add('--android-language=$androidLanguage');
    cmdArgs.add('--ios-language=$iosLanguage');
    if (platforms.isNotEmpty) {
      String platformsArg = '--platforms=';
      for (int i = 0; i < platforms.length; i++) {
        if (i > 0) {
          platformsArg += ',';
        }
        platformsArg += platforms[i];
      }
      cmdArgs.add(platformsArg);
    }
    cmdArgs.add('--no-pub');
    if (legacyNameParameter) {
      cmdArgs.add(name);
    } else {
      cmdArgs.add(outputDirectory);
    }
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: outputDirectory);
    final String error = result.stderr;

    // Catch errors due to parameters not existing.

    // Old versions of the tool does not include the platforms option.
    if (error.contains('Could not find an option named "platforms".')) {
      return createFromTemplates(
        flutterBinPath,
        name: name,
        legacyNameParameter: legacyNameParameter,
        androidLanguage: androidLanguage,
        iosLanguage: iosLanguage,
        outputDirectory: outputDirectory,
        iterationsAllowed: iterationsAllowed--,
      );
    }
    // Old versions of the tool does not include the project-name option.
    if ((result.stderr as String)
        .contains('Could not find an option named "project-name".')) {
      return createFromTemplates(
        flutterBinPath,
        name: name,
        legacyNameParameter: true,
        androidLanguage: androidLanguage,
        iosLanguage: iosLanguage,
        outputDirectory: outputDirectory,
        platforms: platforms,
        iterationsAllowed: iterationsAllowed--,
      );
    }
    if (error.contains('Multiple output directories specified.')) {
      if (error.contains('Try moving --platforms')) {
        return createFromTemplates(
          flutterBinPath,
          name: name,
          legacyNameParameter: legacyNameParameter,
          androidLanguage: androidLanguage,
          iosLanguage: iosLanguage,
          outputDirectory: outputDirectory,
          iterationsAllowed: iterationsAllowed--,
        );
      }
    }
    checkForErrors(result, commandDescription: cmdArgs.join(' '), silent: true);

    if (legacyNameParameter) {
      return _fileSystem.path.join(outputDirectory, name);
    }
    return outputDirectory;
  }

  /// Runs the git 3-way merge on three files and returns the results as a MergeResult.
  ///
  /// Passing the same path for base and current will perform a two-way fast forward merge.
  Future<MergeResult> gitMergeFile({
    required String base,
    required String current,
    required String target,
    required String localPath,
  }) async {
    final List<String> cmdArgs = <String>[
      'git',
      'merge-file',
      '-p',
      current,
      base,
      target
    ];
    final ProcessResult result = await _runCommand(cmdArgs);
    checkForErrors(result,
        allowedExitCodes: <int>[-1], commandDescription: cmdArgs.join(' '));
    return StringMergeResult(result, localPath);
  }

  /// Calls `git init` on the workingDirectory.
  Future<void> gitInit(String workingDirectory) async {
    final List<String> cmdArgs = <String>['git', 'init'];
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: workingDirectory);
    checkForErrors(result, commandDescription: cmdArgs.join(' '));
  }

  /// Returns true if the workingDirectory git repo has any uncommited changes.
  Future<bool> hasUncommittedChanges(String workingDirectory,
      {String? migrateStagingDir}) async {
    final List<String> cmdArgs = <String>[
      'git',
      'ls-files',
      '--deleted',
      '--modified',
      '--others',
      '--exclude-standard',
      '--exclude=${migrateStagingDir ?? kDefaultMigrateStagingDirectoryName}'
    ];
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: workingDirectory);
    checkForErrors(result,
        allowedExitCodes: <int>[-1], commandDescription: cmdArgs.join(' '));
    if ((result.stdout as String).isEmpty) {
      return false;
    }
    return true;
  }

  /// Returns true if the workingDirectory is a git repo.
  Future<bool> isGitRepo(String workingDirectory) async {
    final List<String> cmdArgs = <String>[
      'git',
      'rev-parse',
      '--is-inside-work-tree'
    ];
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: workingDirectory);
    checkForErrors(result,
        allowedExitCodes: <int>[-1], commandDescription: cmdArgs.join(' '));
    if (result.exitCode == 0) {
      return true;
    }
    return false;
  }

  /// Returns true if the file at `filePath` is covered by the `.gitignore`
  Future<bool> isGitIgnored(String filePath, String workingDirectory) async {
    final List<String> cmdArgs = <String>['git', 'check-ignore', filePath];
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: workingDirectory);
    checkForErrors(result,
        allowedExitCodes: <int>[0, 1, 128],
        commandDescription: cmdArgs.join(' '));
    return result.exitCode == 0;
  }

  /// Runs `flutter pub upgrade --major-revisions`.
  Future<void> flutterPubUpgrade(String workingDirectory) async {
    final List<String> cmdArgs = <String>[
      'flutter',
      'pub',
      'upgrade',
      '--major-versions'
    ];
    final ProcessResult result =
        await _runCommand(cmdArgs, workingDirectory: workingDirectory);
    checkForErrors(result, commandDescription: cmdArgs.join(' '));
  }

  /// Runs `./gradlew tasks` in the android directory of a flutter project.
  Future<void> gradlewTasks(String workingDirectory) async {
    final String baseCommand = isWindows ? 'gradlew.bat' : './gradlew';
    final List<String> cmdArgs = <String>[baseCommand, 'tasks'];
    final ProcessResult result = await _runCommand(cmdArgs,
        workingDirectory: workingDirectory, runInShell: isWindows);
    checkForErrors(result, commandDescription: cmdArgs.join(' '));
  }

  /// Verifies that the ProcessResult does not contain an error.
  ///
  /// If an error is detected, the error can be optionally logged or exit the tool.
  ///
  /// Passing -1 in allowedExitCodes means all exit codes are valid.
  bool checkForErrors(ProcessResult result,
      {List<int> allowedExitCodes = const <int>[0],
      String? commandDescription,
      bool exit = true,
      bool silent = false}) {
    if (allowedExitCodes.contains(result.exitCode) ||
        allowedExitCodes.contains(-1)) {
      return true;
    }
    if (!silent) {
      _logger.printError(
          'Command encountered an error with exit code ${result.exitCode}.');
      if (commandDescription != null) {
        _logger.printError('Command:');
        _logger.printError(commandDescription, indent: 2);
      }
      _logger.printError('Stdout:');
      _logger.printError(result.stdout, indent: 2);
      _logger.printError('Stderr:');
      _logger.printError(result.stderr, indent: 2);
    }
    if (exit) {
      throwToolExit(
          'Command failed with exit code ${result.exitCode}: ${result.stderr}\n${result.stdout}',
          exitCode: result.exitCode);
    }
    return false;
  }

  /// Returns true if the file does not contain any git conflit markers.
  bool conflictsResolved(String contents) {
    final bool hasMarker = contents.contains('>>>>>>>') ||
        contents.contains('=======') ||
        contents.contains('<<<<<<<');
    return !hasMarker;
  }
}

Future<bool> gitRepoExists(
    String projectDirectory, Logger logger, MigrateUtils migrateUtils) async {
  if (await migrateUtils.isGitRepo(projectDirectory)) {
    return true;
  }
  logger.printStatus(
      'Project is not a git repo. Please initialize a git repo and try again.');
  printCommandText('git init', logger);
  return false;
}

Future<bool> hasUncommittedChanges(
    String projectDirectory, Logger logger, MigrateUtils migrateUtils) async {
  if (await migrateUtils.hasUncommittedChanges(projectDirectory)) {
    logger.printStatus(
        'There are uncommitted changes in your project. Please git commit, abandon, or stash your changes before trying again.');
    logger.printStatus(
        'You may commit your changes using \'git add .\' and \'git commit -m "<message"\'');
    return true;
  }
  return false;
}

/// Prints a command to logger with appropriate formatting.
void printCommandText(String command, Logger logger,
    {bool? standalone = true}) {
  final String prefix = standalone == null
      ? ''
      : (standalone ? './bin/flutter_migrate ' : 'flutter migrate ');
  logger.printStatus(
    '\n\$ $prefix$command\n',
    color: TerminalColor.grey,
    indent: 4,
    newline: false,
  );
}

/// Defines the classification of difference between files.
enum DiffType {
  command,
  addition,
  deletion,
  ignored,
  none,
}

/// Tracks the output of a git diff command or any special cases such as addition of a new
/// file or deletion of an existing file.
class DiffResult {
  DiffResult({
    required this.diffType,
    this.diff,
    this.exitCode,
  }) : assert(diffType == DiffType.command && exitCode != null ||
            diffType != DiffType.command && exitCode == null);

  /// The diff string output by git.
  final String? diff;

  final DiffType diffType;

  /// The exit code of the command. This is zero when no diffs are found.
  ///
  /// The exitCode is null when the diffType is not `command`.
  final int? exitCode;
}

/// Data class to hold the results of a merge.
abstract class MergeResult {
  /// Initializes a MergeResult based off of a ProcessResult.
  MergeResult(ProcessResult result, this.localPath)
      : hasConflict = result.exitCode != 0,
        exitCode = result.exitCode;

  /// Manually initializes a MergeResult with explicit values.
  MergeResult.explicit({
    required this.hasConflict,
    required this.exitCode,
    required this.localPath,
  });

  /// True when there is a merge conflict.
  bool hasConflict;

  /// The exitcode of the merge command.
  int exitCode;

  /// The local path relative to the project root of the file.
  String localPath;
}

/// The results of a string merge.
class StringMergeResult extends MergeResult {
  /// Initializes a BinaryMergeResult based off of a ProcessResult.
  StringMergeResult(super.result, super.localPath)
      : mergedString = result.stdout;

  /// Manually initializes a StringMergeResult with explicit values.
  StringMergeResult.explicit({
    required this.mergedString,
    required super.hasConflict,
    required super.exitCode,
    required super.localPath,
  }) : super.explicit();

  /// The final merged string.
  String mergedString;
}

/// The results of a binary merge.
class BinaryMergeResult extends MergeResult {
  /// Initializes a BinaryMergeResult based off of a ProcessResult.
  BinaryMergeResult(super.result, super.localPath)
      : mergedBytes = result.stdout as Uint8List;

  /// Manually initializes a BinaryMergeResult with explicit values.
  BinaryMergeResult.explicit({
    required this.mergedBytes,
    required super.hasConflict,
    required super.exitCode,
    required super.localPath,
  }) : super.explicit();

  /// The final merged bytes.
  Uint8List mergedBytes;
}
