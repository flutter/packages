// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show ProcessResult;
import 'dart:math' show Random;

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:fuchsia_ctl/src/package_server.dart';
import 'package:fuchsia_ctl/src/operation_result.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import 'fakes.dart';

void main() {
  const String pmBin = 'pm';
  const String repoPath = '/repo';

  test('newRepo', () async {
    final MockProcessManager processManager = MockProcessManager();

    when(processManager.run(any)).thenAnswer((_) async {
      return ProcessResult(0, 0, 'good job', '');
    });

    final PackageServer server = PackageServer(
      pmBin,
      processManager: processManager,
    );

    final OperationResult result = await server.newRepo(repoPath);

    final List<String> capturedStartArgs =
        verify(processManager.run(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(capturedStartArgs, <String>[pmBin, 'newrepo', '-repo', repoPath]);
    expect(result.success, true);
  });

  test('publishRepo', () async {
    const String farFile = 'flutter_runner-0.far';
    final MockProcessManager processManager = MockProcessManager();

    when(processManager.run(any)).thenAnswer((_) async {
      return ProcessResult(0, 0, 'good job', '');
    });

    final PackageServer server = PackageServer(
      pmBin,
      processManager: processManager,
    );

    final OperationResult result = await server.publishRepo(repoPath, farFile);

    final List<String> capturedStartArgs =
        verify(processManager.run(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(capturedStartArgs, <String>[
      pmBin,
      'publish',
      '-a',
      '-repo',
      repoPath,
      '-f',
      farFile,
    ]);
    expect(result.success, true);
  });

  test('serveRepo', () async {
    final MockProcessManager processManager = MockProcessManager();
    final int randomPort = Random().nextInt(60000);
    final FakeProcess serverProcess = FakeProcess(
      0,
      <String>[
        '',
      ],
      <String>[''],
    );

    when(processManager.start(any)).thenAnswer((_) async {
      return serverProcess;
    });

    final MemoryFileSystem fs = MemoryFileSystem();

    final PackageServer server = PackageServer(
      pmBin,
      processManager: processManager,
      fileSystem: fs,
    );

    expect(server.serving, false);
    final File portFile = fs.file(
      'port.txt',
    )
      ..create()
      ..writeAsString(
        randomPort.toString(),
      );

    await server.serveRepo(
      repoPath,
      port: 0,
      portFilePath: portFile.path,
    );
    expect(server.serving, true);

    final List<String> capturedStartArgs =
        verify(processManager.start(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(capturedStartArgs, <String>[
      pmBin,
      'serve',
      '-repo',
      repoPath,
      '-l',
      ':0',
      '-f',
      'port.txt',
    ]);
    expect(server.serverPort, randomPort);

    final OperationResult result = await server.close();

    expect(result.success, true);
    expect(serverProcess.killed, true);

    expect(server.serving, false);
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
