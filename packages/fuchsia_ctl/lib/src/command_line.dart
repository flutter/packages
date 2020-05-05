// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

/// Class for common actions with processes on the command line.
@immutable
class CommandLine {
  /// Create a new instance of [CommandLine].
  const CommandLine(
      {this.processManager = const LocalProcessManager(),
      @visibleForTesting this.stdoutValue,
      @visibleForTesting this.stderrValue});

  /// The underlying [ProcessManager] to use for running on the current shell.
  final ProcessManager processManager;

  /// Mock value for use in tests.
  final Stdout stdoutValue;

  /// Mock value for use in tests.
  final Stdout stderrValue;

  /// Current shells stdout to use.
  Stdout get shellStdout => stdoutValue ?? stdout;

  /// Current shells stderr to use.
  Stdout get shellStderr => stderrValue ?? stderr;

  /// Run [command] and handle its stdio. Once [command] is complete, it will
  /// output its stdio to the console.
  ///
  /// Use this for tasks where stdio does not need to be monitored.
  ///
  /// Throw [CommandLineException] if [command] returns a non-0 exit code.
  Future<void> run(List<String> command) async {
    shellStdout.writeln(command.join(' '));
    final ProcessResult process = await processManager.run(command);
    shellStdout.writeln(process.stdout);
    shellStderr.writeln(process.stderr);

    if (process.exitCode != 0) {
      throw CommandLineException('${command.first} did not return exit code 0');
    }
  }

  /// Start [command] and handle its stdio by streaming it to the existing
  /// stdio. While [command] is running, its stdio is streamed to the shell.
  ///
  /// Use this for long running tasks where stdio should be monitored.
  ///
  /// Throw [CommandLineException] if [command] returns a non-0 exit code.
  Future<Process> start(List<String> command) async {
    shellStdout.writeln(command.join(' '));
    final Process process = await processManager.start(command);
    shellStdout.addStream(process.stdout);
    shellStderr.addStream(process.stderr);

    if (await process.exitCode != 0) {
      throw CommandLineException('${command.first} did not return exit code 0');
    }

    return process;
  }
}

/// Wraps exceptions thrown by [CommandLine].
class CommandLineException implements Exception {
  /// Creates a new [CommandLineException].
  const CommandLineException(this.message);

  /// The user-facing message to display.
  final String message;

  @override
  String toString() => message;
}
