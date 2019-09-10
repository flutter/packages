import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

/// A client for running SSH based commands on a Fuchsia device.
@immutable
class SshClient {
  /// Creates a new SSH client.
  ///
  /// Relies on `ssh` being present in the $PATH.
  ///
  /// The `processManager` must not be null.
  const SshClient({this.processManager = const LocalProcessManager()})
      : assert(processManager != null);

  /// The [ProcessManager] to use for spawning `ssh`.
  final ProcessManager processManager;

  List<String> _getCommand({
    String identityFilePath,
    String targetIp,
    List<String> command = const <String>[],
  }) {
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
      ...command
    ];
  }

  /// Creates an interactive SSH session.
  Future<int> interactive(
    String targetIp, {
    @required String identityFilePath,
  }) async {
    final Process ssh = await processManager.start(_getCommand(
      targetIp: targetIp,
      identityFilePath: identityFilePath,
    ));
    ssh.stdout.transform(utf8.decoder).listen(stdout.writeln);
    ssh.stderr.transform(utf8.decoder).listen(stderr.writeln);
    stdin.pipe(ssh.stdin);

    return await ssh.exitCode;
  }

  /// Runs an SSH command on the specified target IP.
  ///
  /// A target IP can be obtained from a device node name using the
  /// [DevFinder] class.
  ///
  /// All arguments must not be null.
  Future<ProcessResult> runCommand(
    String targetIp, {
    @required String identityFilePath,
    @required List<String> command,
  }) async {
    assert(targetIp != null);
    assert(identityFilePath != null);
    assert(command != null);

    return await processManager.run(_getCommand(
      identityFilePath: identityFilePath,
      targetIp: targetIp,
      command: command,
    ));
  }
}
