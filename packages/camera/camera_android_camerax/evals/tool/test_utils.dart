// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Author name used for evaluation test commits.
const String evalAuthorName = 'Eval Author';

/// Author email used for evaluation test commits.
const String evalAuthorEmail = 'eval-author@example.com';

/// Returns the git remote to compare against.
///
/// Resolves the remote using the following priority:
/// 1. The first remote whose URL contains `flutter/packages` (the canonical upstream repository).
/// 2. A remote named `upstream`, if configured.
/// 3. Falls back to `origin`.
String detectDefaultRemote() {
  final ProcessResult result = Process.runSync('git', <String>['remote', '-v']);
  if (result.exitCode != 0) {
    return 'origin';
  }

  final List<String> lines = result.stdout.toString().split('\n');
  final remoteNames = <String>{};

  for (final line in lines) {
    final List<String> parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      continue;
    }
    final String name = parts[0];
    final String url = parts[1];
    remoteNames.add(name);

    if (url.contains('flutter/packages')) {
      return name;
    }
  }

  if (remoteNames.contains('upstream')) {
    return 'upstream';
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
