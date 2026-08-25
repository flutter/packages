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

    if (url.contains(RegExp(r'/flutter/packages(\.git)?$'))) {
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
    stderr.writeln('Error: Cannot run setup scripts on main branch.');
    exit(1);
  }
}

/// Updates the package version and changelog using repository tooling.
void updateReleaseInfo({required String changelog, String version = 'bugfix'}) {
  final scriptToolDir = Directory('../../../script/tool');
  if (scriptToolDir.existsSync()) {
    final packageConfigFile = File('../../../script/tool/.dart_tool/package_config.json');
    if (!packageConfigFile.existsSync()) {
      final ProcessResult pubGetResult = Process.runSync(
        'dart',
        <String>['pub', 'get'],
        workingDirectory: scriptToolDir.path,
      );
      if (pubGetResult.exitCode != 0) {
        stderr.writeln('Error: pub get in script/tool failed:\n${pubGetResult.stderr}');
        exit(pubGetResult.exitCode);
      }
    }
  }

  final ProcessResult result = Process.runSync('dart', <String>[
    'run',
    '../../../script/tool/bin/flutter_plugin_tools.dart',
    'update-release-info',
    '--packages=camera_android_camerax',
    '--version=$version',
    '--changelog=$changelog',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('Error: update-release-info failed:\n${result.stderr}\n${result.stdout}');
    exit(result.exitCode);
  }
}

/// Stages [paths] and commits them with [message].
///
/// Defaults to [evalAuthorName] and [evalAuthorEmail] so evaluation commits
/// are quarantined and rejected by pre-push validation by default.
void commitFiles(
  List<String> paths,
  String message, {
  String authorName = evalAuthorName,
  String authorEmail = evalAuthorEmail,
}) {
  final ProcessResult addResult = Process.runSync('git', <String>['add', ...paths]);
  if (addResult.exitCode != 0) {
    stderr.writeln('Error: git add failed:\n${addResult.stderr}');
    exit(addResult.exitCode);
  }

  final ProcessResult commitResult = Process.runSync('git', <String>[
    '-c',
    'user.name=$authorName',
    '-c',
    'user.email=$authorEmail',
    'commit',
    '-m',
    message,
  ]);
  if (commitResult.exitCode != 0) {
    stderr.writeln('Error: git commit failed:\n${commitResult.stderr}');
    exit(commitResult.exitCode);
  }
}
