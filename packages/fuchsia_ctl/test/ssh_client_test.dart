// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show ProcessResult;

import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:fuchsia_ctl/src/ssh_client.dart';
import 'package:fuchsia_ctl/src/operation_result.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import 'fakes.dart';

void main() {
  const String targetIp = '127.0.0.2';
  const String identityFilePath = '.ssh/pkey';

  test('interactive', () async {
    final MockProcessManager processManager = MockProcessManager();

    when(processManager.start(any)).thenAnswer((_) async {
      return FakeProcess(0, <String>[''], <String>['']);
    });

    final SshClient ssh = SshClient(processManager: processManager);

    final OperationResult result = await ssh.interactive(
      targetIp,
      identityFilePath: identityFilePath,
    );

    final List<String> capturedStartArgs =
        verify(processManager.start(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(
        capturedStartArgs,
        ssh.getSshArguments(
          identityFilePath: identityFilePath,
          targetIp: targetIp,
        ));
    expect(result.success, true);
  });

  test('command', () async {
    const List<String> command = <String>['ls', '-al'];
    final MockProcessManager processManager = MockProcessManager();

    when(processManager.run(any)).thenAnswer((_) async {
      return ProcessResult(0, 0, 'Good job', '');
    });

    final SshClient ssh = SshClient(processManager: processManager);

    final OperationResult result = await ssh.runCommand(
      targetIp,
      identityFilePath: identityFilePath,
      command: command,
    );

    final List<String> capturedStartArgs =
        verify(processManager.run(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(
        capturedStartArgs,
        ssh.getSshArguments(
          identityFilePath: identityFilePath,
          targetIp: targetIp,
          command: command,
        ));
    expect(result.success, true);
  });

  test('getSshArgs', () {
    const SshClient ssh = SshClient();
    final List<String> args = ssh.getSshArguments(
      identityFilePath: identityFilePath,
      targetIp: targetIp,
      command: const <String>['ls', '-al'],
    );
    expect(args.last, 'ls -al');
  });

  test('sshCommand times out', () async {
    final MockProcessManager processManager = MockProcessManager();

    when(processManager.run(any)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 3));
      return ProcessResult(0, 0, 'Good job', '');
    });

    final SshClient ssh = SshClient(processManager: processManager);
    try {
      await ssh.runCommand(
        targetIp,
        identityFilePath: identityFilePath,
        command: const <String>['ls', '-al'],
        timeoutMs: const Duration(milliseconds: 1),
      );
    } catch (e) {
      expect(e, isA<TimeoutException>());
    }
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
