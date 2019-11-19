// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show ProcessResult;
import 'dart:math' show Random;

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
      '-repo', repoPath, //
      '-f', farFile,
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
        'YYYY-MM-DD HH:mm:ss [pm serve] serving $repoPath at http://:$randomPort',
        'YYYY-MM-DD HH:mm:ss [pm serve] 200 /',
      ],
      <String>[''],
    );

    when(processManager.start(any)).thenAnswer((_) async {
      return serverProcess;
    });

    final PackageServer server = PackageServer(
      pmBin,
      processManager: processManager,
    );

    await server.serveRepo(repoPath, port: 0);

    final List<String> capturedStartArgs =
        verify(processManager.start(captureAny))
            .captured
            .cast<List<String>>()
            .single;

    expect(capturedStartArgs, <String>[
      pmBin,
      'serve',
      '-repo', repoPath, //
      '-l', ':0',
    ]);
    expect(server.serverPort, randomPort);

    expect(server.sourceUrl('192.168.42.42'),
        'http://192.168.42.42:$randomPort/config.json');
    expect(server.sourceUrl('fe80::f64d:30ff:fe6b:25d6%br0'),
        'http://[fe80::f64d:30ff:fe6b:25d6%25br0]:$randomPort/config.json');
    final OperationResult result = await server.close();

    expect(result.success, true);
    expect(serverProcess.killed, true);
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
