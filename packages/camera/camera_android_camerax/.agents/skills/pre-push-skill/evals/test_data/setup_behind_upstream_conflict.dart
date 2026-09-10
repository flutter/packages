// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

/// Detects the remote name pointing to the main flutter/packages repository.
Future<String> getUpstreamRemote(String workingDirectory) async {
  final ProcessResult result = await Process.run('git', <String>[
    'remote',
    '-v',
  ], workingDirectory: workingDirectory);
  if (result.exitCode != 0) {
    return 'upstream'; // fallback
  }
  final stdout = result.stdout.toString();
  for (final String line in stdout.split('\n')) {
    if (line.contains('flutter/packages')) {
      final List<String> parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        return parts.first;
      }
    }
  }
  return 'upstream'; // fallback
}

/// Finds the root directory of the git repository.
Future<Directory> getRepoRoot(String workingDirectory) async {
  final ProcessResult result = await Process.run('git', <String>[
    'rev-parse',
    '--show-toplevel',
  ], workingDirectory: workingDirectory);
  if (result.exitCode != 0) {
    return Directory(workingDirectory).parent.parent.parent;
  }
  return Directory(result.stdout.toString().trim());
}

/// Checks out a branch that is behind upstream/main, makes a local commit that
/// conflicts with the latest changes on upstream/main, and verifies that
/// pre-push-skill detects the conflict and stops immediately.
void main() async {
  // The root of the packages directory.
  final Directory packageDir = Directory(
    Platform.script.toFilePath(),
  ).parent.parent.parent.parent.parent.parent;

  final Directory repoRoot = await getRepoRoot(packageDir.path);
  final String upstream = await getUpstreamRemote(packageDir.path);
  print('Detected upstream remote: $upstream');

  // 1. Fetch upstream main with depth of at least 10
  print('Fetching $upstream main...');
  final ProcessResult fetchResult = await Process.run('git', <String>[
    'fetch',
    '--depth=10',
    upstream,
    'main',
  ], workingDirectory: packageDir.path);
  if (fetchResult.exitCode != 0) {
    print('Failed to fetch upstream main: ${fetchResult.stderr}');
    exit(1);
  }

  // 2. Find a modified file in recent commits of upstream/main that exists in the repo
  print('Finding modified file in recent upstream commits...');
  String? fileToConflict;
  for (var i = 1; i <= 5; i++) {
    final ProcessResult diffResult = await Process.run('git', <String>[
      'diff',
      '--name-only',
      '--diff-filter=M',
      '$upstream/main~$i..$upstream/main',
    ], workingDirectory: repoRoot.path);
    if (diffResult.exitCode == 0) {
      final List<String> lines = diffResult.stdout
          .toString()
          .split('\n')
          .map((String line) => line.trim())
          .where((String line) => line.isNotEmpty)
          .toList();
      for (final line in lines) {
        final file = File('${repoRoot.path}/$line');
        if (file.existsSync()) {
          fileToConflict = line;
          break;
        }
      }
      if (fileToConflict != null) {
        break;
      }
    }
  }

  if (fileToConflict == null) {
    print('No modified file found in recent upstream commits. Cannot guarantee conflict.');
    exit(1);
  }
  print('Selected file to conflict: $fileToConflict');

  // 3. Checkout a new temporary branch 'eval_behind_upstream_conflict' starting 1 commit behind upstream/main
  print('Checking out eval_behind_upstream_conflict...');
  final ProcessResult checkoutResult = await Process.run('git', <String>[
    'checkout',
    '-B',
    'eval_behind_upstream_conflict',
    '$upstream/main~1',
  ], workingDirectory: packageDir.path);
  if (checkoutResult.exitCode != 0) {
    print('Failed to checkout: ${checkoutResult.stderr}');
    exit(1);
  }

  // 4. Modify the file to cause a conflict by overwriting it
  final conflictFile = File('${repoRoot.path}/$fileToConflict');
  if (!conflictFile.existsSync()) {
    print('File does not exist: ${conflictFile.path}');
    exit(1);
  }
  await conflictFile.writeAsString('// CONFLICTING CHANGE\n// CONFLICT LINE 2\n');

  // Also modify a file in camera_android_camerax so the skill detects changed files in this package
  final packageFile = File('${packageDir.path}/lib/src/camerax_library.dart');
  await packageFile.writeAsString('\n// Eval comment\n', mode: FileMode.append);

  // 5. Commit the changes
  print('Committing...');
  final ProcessResult addResult = await Process.run('git', <String>[
    'add',
    conflictFile.path,
    packageFile.path,
  ], workingDirectory: packageDir.path);
  if (addResult.exitCode != 0) {
    print('Failed to git add: ${addResult.stderr}');
    exit(1);
  }

  final ProcessResult commitResult = await Process.run('git', <String>[
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'eval: conflicting local commit',
  ], workingDirectory: packageDir.path);
  if (commitResult.exitCode != 0) {
    print('Failed to commit: ${commitResult.stderr}');
    exit(1);
  }

  print('Setup complete.');
}
