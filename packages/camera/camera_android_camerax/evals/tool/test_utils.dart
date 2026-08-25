// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Author name used for evaluation test commits.
const String evalAuthorName = 'Eval Author';

/// Author email used for evaluation test commits.
const String evalAuthorEmail = 'eval-author@example.com';

/// Detects the remote pointing to the main flutter/packages repository,
/// or falls back to 'upstream' or 'origin'.
String detectDefaultRemote() {
  final ProcessResult result = Process.runSync('git', <String>['remote', '-v']);
  if (result.exitCode == 0) {
    final stdout = result.stdout.toString();
    for (final String line in stdout.split('\n')) {
      if (line.contains('flutter/packages')) {
        final List<String> parts = line.split(RegExp(r'\s+'));
        if (parts.isNotEmpty) {
          return parts.first;
        }
      }
    }
    final List<String> remotes = stdout
        .split('\n')
        .map((String line) => line.split(RegExp(r'\s+')).firstOrNull)
        .whereType<String>()
        .where((String name) => name.isNotEmpty)
        .toList();
    if (remotes.contains('upstream')) {
      return 'upstream';
    }
    if (remotes.contains('origin')) {
      return 'origin';
    }
  }
  return 'origin';
}

/// Asserts that the current git branch is not `main` to prevent modifying the default branch.
void ensureNotMainBranch() {
  final ProcessResult branchResult = Process.runSync('git', <String>['branch', '--show-current']);
  final String branch = branchResult.stdout.toString().trim();
  if (branch == 'main') {
    stdout.writeln('Error: Cannot run setup scripts on main branch.');
    exit(1);
  }
}

/// Updates the package version and changelog using repository tooling.
void updateReleaseInfo({required String changelog, String version = 'bugfix'}) {
  final scriptToolDir = Directory('../../../script/tool');
  if (scriptToolDir.existsSync()) {
    final packageConfigFile = File('../../../script/tool/.dart_tool/package_config.json');
    if (!packageConfigFile.existsSync()) {
      Process.runSync('dart', <String>['pub', 'get'], workingDirectory: scriptToolDir.path);
    }
  }

  Process.runSync('dart', <String>[
    'run',
    '../../../script/tool/bin/flutter_plugin_tools.dart',
    'update-release-info',
    '--packages=camera_android_camerax',
    '--version=$version',
    '--changelog=$changelog',
  ]);
}

/// Stages [paths] and commits them with [message] using evaluation author metadata.
void commitFiles(List<String> paths, String message) {
  final ProcessResult addResult = Process.runSync('git', <String>['add', ...paths]);
  if (addResult.exitCode != 0) {
    stderr.writeln('Error: git add failed:\n${addResult.stderr}');
    exitCode = addResult.exitCode;
    return;
  }

  final ProcessResult commitResult = Process.runSync('git', <String>[
    '-c',
    'user.name=$evalAuthorName',
    '-c',
    'user.email=$evalAuthorEmail',
    'commit',
    '-m',
    message,
  ]);
  if (commitResult.exitCode != 0) {
    stderr.writeln('Error: git commit failed:\n${commitResult.stderr}');
    exitCode = commitResult.exitCode;
    return;
  }
}
