// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';

import 'logger.dart';
import 'project.dart';

enum ExitStatus {
  success,
  warning,
  fail,
  killed,
}

const String flutterNoPubspecMessage = 'Error: No pubspec.yaml file found.\n'
    'This command should be run from the root of your Flutter project.';

class CommandResult {
  const CommandResult(this.exitStatus);

  /// A command that succeeded. It is used to log the result of a command invocation.
  factory CommandResult.success() {
    return const CommandResult(ExitStatus.success);
  }

  /// A command that exited with a warning. It is used to log the result of a command invocation.
  factory CommandResult.warning() {
    return const CommandResult(ExitStatus.warning);
  }

  /// A command that failed. It is used to log the result of a command invocation.
  factory CommandResult.fail() {
    return const CommandResult(ExitStatus.fail);
  }

  final ExitStatus exitStatus;

  @override
  String toString() {
    switch (exitStatus) {
      case ExitStatus.success:
        return 'success';
      case ExitStatus.warning:
        return 'warning';
      case ExitStatus.fail:
        return 'fail';
      case ExitStatus.killed:
        return 'killed';
    }
  }
}

abstract class MigrateCommand extends Command<void> {
  @override
  Future<void> run() async {
    await runCommand();
    return;
  }

  Future<CommandResult> runCommand();

  /// Gets the parsed command-line option named [name] as a `bool?`.
  bool? boolArg(String name) {
    if (!argParser.options.containsKey(name)) {
      return null;
    }
    return argResults == null ? null : argResults![name] as bool;
  }

  String? stringArg(String name) {
    if (!argParser.options.containsKey(name)) {
      return null;
    }
    return argResults == null ? null : argResults![name] as String?;
  }

  /// Gets the parsed command-line option named [name] as an `int`.
  int? intArg(String name) => argResults?[name] as int?;

  bool validateWorkingDirectory(FlutterProject project, Logger logger) {
    if (!project.pubspecFile.existsSync()) {
      logger.printError(flutterNoPubspecMessage);
      return false;
    }
    return true;
  }
}
