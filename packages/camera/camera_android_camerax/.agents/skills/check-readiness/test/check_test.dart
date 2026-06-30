// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;

import 'package:check_readiness/check_readiness.dart';
import 'package:file/memory.dart';
import 'package:file/src/interface/directory.dart';
import 'package:file/src/interface/link.dart';
import 'package:path/path.dart' as p;
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../tool/check.dart';

class FakeProcessManager implements ProcessManager {
  final Map<String, bool> canRunMock = {};
  final Map<String, ProcessResult> runMock = {};
  final List<List<String>> runInvocations = [];

  @override
  bool canRun(dynamic executable, {String? workingDirectory}) {
    return canRunMock[executable as String] ?? true;
  }

  @override
  Future<ProcessResult> run(
    List<dynamic> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    final List<String> cmdList = command.cast<String>();
    runInvocations.add(cmdList);
    final String key = cmdList.join(' ');
    if (runMock.containsKey(key)) {
      return runMock[key]!;
    }
    return ProcessResult(0, 0, '', '');
  }

  // The rest of the interface is unimplemented.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MemoryFileSystem fileSystem;
  late FakeProcessManager processManager;
  late ReadinessChecker checker;
  late String workspaceRoot;
  final List<String> printLogs = [];

  setUp(() {
    fileSystem = MemoryFileSystem.test();
    processManager = FakeProcessManager();
    checker = ReadinessChecker(
      fileSystem: fileSystem,
      processManager: processManager,
      log: (Object? message) => printLogs.add(message.toString()),
    );
    workspaceRoot = fileSystem.path.absolute('workspace');
    printLogs.clear();
  });

  /// Runs the checker and captures prints
  Future<bool> runChecker() async {
    return checker.checkReadiness(workspaceRoot);
  }

  test('passes when everything is correct', () async {
    // Setup empty skills dir (no broken symlinks)
    fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
        .createSync(recursive: true);

    // Git returns clean
    processManager.runMock['git status --porcelain'] = ProcessResult(0, 0, '', '');

    final bool result = await runChecker();
    expect(result, isTrue);
    expect(printLogs, contains('Environment is fully ready!'));
  });

  test('fails when a broken symlink is present', () async {
    final Directory skillsDir = fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
      ..createSync(recursive: true);

    // MemoryFileSystem supports links
    final Link link = fileSystem.link(fileSystem.path.join(skillsDir.path, 'broken_link'));
    link.createSync('non_existent_target');

    final bool result = await runChecker();
    expect(result, isFalse);
    expect(
        printLogs.any((line) => line.contains('Found broken symlinks in .agents/skills:')), isTrue);
  });

  test('fails when git is dirty', () async {
    fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
        .createSync(recursive: true);

    processManager.runMock['git status --porcelain'] = ProcessResult(0, 0, ' M file.txt\n', '');

    final bool result = await runChecker();
    expect(result, isFalse);
    expect(
        printLogs,
        contains(
            'Error: Git working directory is not clean. Please commit or stash your changes before starting new work.'));
  });

  test('fails when flutter is missing', () async {
    fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
        .createSync(recursive: true);

    processManager.canRunMock['flutter'] = false;

    final bool result = await runChecker();
    expect(result, isFalse);
    expect(printLogs, contains("Error: 'flutter' is not on the PATH."));
  });

  test('fails when dart is missing', () async {
    fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
        .createSync(recursive: true);

    processManager.canRunMock['dart'] = false;

    final bool result = await runChecker();
    expect(result, isFalse);
    expect(printLogs, contains("Error: 'dart' is not on the PATH."));
  });

  test('fails when flutter pub get fails', () async {
    fileSystem
        .directory(fileSystem.path.join(workspaceRoot, '.agents', 'skills'))
        .createSync(recursive: true);

    processManager.runMock['git status --porcelain'] = ProcessResult(0, 0, '', '');
    processManager.runMock['flutter pub get'] = ProcessResult(0, 1, '', 'Error');

    final bool result = await runChecker();
    expect(result, isFalse);
    expect(printLogs, contains('Error: Failed to resolve dependencies.'));
  });

  group('Windows style', () {
    late MemoryFileSystem winFileSystem;
    late ReadinessChecker winChecker;
    late String winWorkspaceRoot;

    setUp(() {
      winFileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
      winChecker = ReadinessChecker(
        fileSystem: winFileSystem,
        processManager: processManager,
        log: (Object? message) => printLogs.add(message.toString()),
      );
      winWorkspaceRoot = r'C:\workspace';
      printLogs.clear();
    });

    test('fails when a broken symlink is present on Windows', () async {
      final Directory skillsDir = winFileSystem
          .directory(winFileSystem.path.join(winWorkspaceRoot, '.agents', 'skills'))
        ..createSync(recursive: true);

      final Link link = winFileSystem.link(winFileSystem.path.join(skillsDir.path, 'broken_link'));
      link.createSync('non_existent_target');

      final bool result = await winChecker.checkReadiness(winWorkspaceRoot);
      expect(result, isFalse);
      expect(printLogs.any((line) => line.contains('Found broken symlinks in .agents/skills:')),
          isTrue);
    });
  });

  group('findPackageDir', () {
    test('correctly resolves package root from check.dart path', () {
      final String scriptPath = p.joinAll(<String>[
        'repo',
        'packages',
        'camera',
        'camera_android_camerax',
        '.agents',
        'skills',
        'check-readiness',
        'tool',
        'check.dart',
      ]);
      final scriptUri = Uri.file(scriptPath);
      final io.Directory resolved = findPackageDir(scriptUri);

      final String expectedPath = p.joinAll(<String>[
        'repo',
        'packages',
        'camera',
        'camera_android_camerax',
      ]);
      expect(resolved.path, expectedPath);
    });
  });
}
