// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:fuchsia_ctl/src/logger.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:process/process.dart';

import 'operation_result.dart';

/// A client for running SSH based commands on a Fuchsia device.
@immutable
class SshClient {
  /// Creates a new SSH client.
  ///
  /// Relies on `ssh` being present in the $PATH.
  ///
  /// The `processManager` must not be null.
  const SshClient({
    this.processManager = const LocalProcessManager(),
  }) : assert(processManager != null);

  /// The [ProcessManager] to use for spawning `ssh`.
  final ProcessManager processManager;

  /// The default ssh timeout as [Duration] in milliseconds.
  static const Duration defaultSshTimeoutMs = Duration(milliseconds: 5 * 60 * 1000);

  /// Creates a list of arguments to pass to ssh.
  ///
  /// This method is not intended for use outside of this library, except for
  /// in unit tests.
  @visibleForTesting
  List<String> getSshArguments({
    String identityFilePath,
    String targetIp,
    List<String> command = const <String>[],
  }) {
    assert(command != null);
    return <String>[
      'ssh',
      '-o', 'CheckHostIP=no', //
      '-o', 'StrictHostKeyChecking=no',
      '-o', 'ForwardAgent=no',
      '-o', 'ForwardX11=no',
      '-o', 'GSSAPIDelegateCredentials=no',
      '-o', 'UserKnownHostsFile=/dev/null',
      '-o', 'User=fuchsia',
      '-o', 'IdentitiesOnly=yes',
      '-o', 'IdentityFile=$identityFilePath',
      '-o', 'ControlPersist=yes',
      '-o', 'ControlMaster=auto',
      '-o', 'ControlPath=/tmp/fuchsia--%r@%h:%p',
      '-o', 'ServerAliveInterval=1',
      '-o', 'ServerAliveCountMax=10',
      '-o', 'LogLevel=ERROR',
      targetIp,
      command.join(' '),
    ];
  }

  /// Creates an interactive SSH session.
  Future<OperationResult> interactive(
    String targetIp, {
    @required String identityFilePath,
  }) async {
    final Process ssh = await processManager.start(getSshArguments(
      targetIp: targetIp,
      identityFilePath: identityFilePath,
    ));
    ssh.stdout.transform(utf8.decoder).listen(stdout.writeln);
    ssh.stderr.transform(utf8.decoder).listen(stderr.writeln);
    stdin.pipe(ssh.stdin);

    final int exitCode = await ssh.exitCode;
    if (exitCode == 0) {
      return OperationResult.success();
    }
    return OperationResult.error('ssh exited with code $exitCode');
  }

  /// Runs an SSH command on the specified target IP.
  ///
  /// A target IP can be obtained from a device node name using the
  /// [DevFinder] class.
  ///
  /// All arguments must not be null.
  Future<OperationResult> runCommand(
    String targetIp, {
    @required String identityFilePath,
    @required List<String> command,
    Duration timeoutMs = defaultSshTimeoutMs,
    String logFilePath,
    FileSystem fs,
  }) async {
    assert(targetIp != null);
    assert(identityFilePath != null);
    assert(command != null);

    final bool logToFile = !(logFilePath == null || logFilePath.isEmpty);
    final FileSystem fileSystem = fs ?? const LocalFileSystem();
    PrintLogger logger;

    // If no file is passed to this method we create a memoryfile to keep to
    // return the stdout in OperationResult.
    if (logToFile) {
      fileSystem.file(logFilePath).existsSync() ?? fileSystem.file(logFilePath).deleteSync();
      fileSystem.file(logFilePath).createSync();
      final IOSink data = fileSystem.file(logFilePath).openWrite();
      logger = PrintLogger(out: data);
    } else {
      logger = PrintLogger();
    }

    final Process process = await processManager.start(
      getSshArguments(
        identityFilePath: identityFilePath,
        targetIp: targetIp,
        command: command,
      ),
    );
    final StreamSubscription<String> stdoutSubscription =
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((String log) {
      logger.info(log);
    });
    final StreamSubscription<String> stderrSubscription =
        process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((String log) {
      logger.error(log);
    });

    // Wait for stdout and stderr to be fully processed because proc.exitCode
    // may complete first.
    await Future.wait<void>(<Future<void>>[
      stdoutSubscription.asFuture<void>(),
      stderrSubscription.asFuture<void>(),
    ]);
    // The streams as futures have already completed, so waiting for the
    // potentially async stream cancellation to complete likely has no benefit.
    unawaited(stdoutSubscription.cancel());
    unawaited(stderrSubscription.cancel());

    final int exitCode = await process.exitCode.timeout(timeoutMs);

    return exitCode != 0
        ? OperationResult.error('Failed', info: logger.errorLog())
        : OperationResult.success(info: logger.outputLog());
  }
}
