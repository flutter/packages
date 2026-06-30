// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:process/process.dart';

/// Checks if the environment is ready for new work.
class ReadinessChecker {
  /// Creates a new ReadinessChecker.
  ReadinessChecker({
    FileSystem? fileSystem,
    ProcessManager? processManager,
    void Function(Object?)? log,
  })  : _fileSystem = fileSystem ?? const LocalFileSystem(),
        _processManager = processManager ?? const LocalProcessManager(),
        _log = log ?? ((Object? msg) => stdout.writeln(msg));

  final FileSystem _fileSystem;
  final ProcessManager _processManager;
  final void Function(Object?) _log;

  /// Runs all readiness checks.
  ///
  /// Returns `true` if ready, `false` otherwise.
  Future<bool> checkReadiness(String workspaceRoot) async {
    _log('Checking if environment is ready for new work...');

    var isReady = true;

    if (!await _checkSymlinks(workspaceRoot)) {
      isReady = false;
    }
    if (!await _checkGitState(workspaceRoot)) {
      isReady = false;
    }

    final bool hasTools = await _checkFlutterAndDart();
    if (!hasTools) {
      isReady = false;
    } else {
      if (!await _checkDependencies(workspaceRoot)) {
        isReady = false;
      }
    }

    if (isReady) {
      _log('Environment is fully ready!');
    }
    return isReady;
  }

  Future<bool> _checkSymlinks(String workspaceRoot) async {
    _log('1. Checking skill symlinks...');
    final Directory agentsDir =
        _fileSystem.directory(_fileSystem.path.join(workspaceRoot, '.agents', 'skills'));
    if (!agentsDir.existsSync()) {
      // If it doesn't exist, there are no broken symlinks.
      _log('All symlinks resolve correctly.');
      return true;
    }

    final brokenLinks = <String>[];
    await for (final FileSystemEntity entity
        in agentsDir.list(recursive: true, followLinks: false)) {
      if (entity is Link) {
        if (_fileSystem.typeSync(entity.path) == FileSystemEntityType.notFound) {
          brokenLinks.add(entity.path);
        }
      }
    }

    if (brokenLinks.isNotEmpty) {
      _log('Error: Found broken symlinks in .agents/skills:');
      brokenLinks.forEach(_log);
      return false;
    }

    _log('All symlinks resolve correctly.');
    return true;
  }

  Future<bool> _checkGitState(String workspaceRoot) async {
    _log('2. Checking git state...');
    final ProcessResult result;
    try {
      result = await _processManager.run(
        ['git', 'status', '--porcelain'],
        workingDirectory: workspaceRoot,
      );
    } on ProcessException catch (e) {
      _log('Error: Failed to run git status. Is git installed and on the PATH?');
      _log(e.toString());
      return false;
    }
    if (result.exitCode != 0) {
      _log('Error: Failed to run git status.');
      return false;
    }
    final String stdoutStr = (result.stdout as String).trim();
    if (stdoutStr.isNotEmpty) {
      _log(
          'Error: Git working directory is not clean. Please commit or stash your changes before starting new work.');
      return false;
    }
    _log('Git working directory is clean.');
    return true;
  }

  Future<bool> _checkFlutterAndDart() async {
    _log('3. Checking Flutter and Dart...');
    if (!_canRunCommand('flutter')) {
      _log("Error: 'flutter' is not on the PATH.");
      return false;
    }
    if (!_canRunCommand('dart')) {
      _log("Error: 'dart' is not on the PATH.");
      return false;
    }
    _log('Flutter and Dart are on the PATH.');
    return true;
  }

  bool _canRunCommand(String command) {
    // A simple check using ProcessManager's canRun
    // NOTE: ProcessManager.canRun exists if we use process package > certain version
    // Let's implement a safe check
    return _processManager.canRun(command);
  }

  Future<bool> _checkDependencies(String workspaceRoot) async {
    _log('4. Checking dependencies in camera_android_camerax...');
    final ProcessResult result = await _processManager.run(
      ['flutter', 'pub', 'get'],
      workingDirectory: workspaceRoot,
    );
    if (result.exitCode != 0) {
      _log('Error: Failed to resolve dependencies.');
      return false;
    }
    _log('Dependencies are resolved and ready.');
    return true;
  }
}
