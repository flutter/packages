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

/// Checks out a branch that is behind upstream/main, makes a local commit that
/// conflicts with the latest changes on upstream/main, and verifies that
/// pre-push-skill detects the conflict and stops immediately.
void main() async {
  // The root of the packages directory.
  final Directory packageDir = Directory(Platform.script.toFilePath())
      .parent
      .parent
      .parent
      .parent
      .parent
      .parent;

  final String upstream = await getUpstreamRemote(packageDir.path);
  print('Detected upstream remote: $upstream');

  // 1. Fetch upstream main with depth of at least 2
  print('Fetching $upstream main...');
  final ProcessResult fetchResult = await Process.run('git', <String>[
    'fetch',
    '--depth=2',
    upstream,
    'main',
  ], workingDirectory: packageDir.path);
  if (fetchResult.exitCode != 0) {
    print('Failed to fetch upstream main: ${fetchResult.stderr}');
    exit(1);
  }

  // 2. Find a file modified in the last commit of upstream/main
  print('Finding modified file in last upstream commit...');
  final ProcessResult diffResult = await Process.run('git', <String>[
    'diff',
    '$upstream/main~1..$upstream/main',
    '--name-only',
  ], workingDirectory: packageDir.path);
  if (diffResult.exitCode != 0) {
    print('Failed to get diff: ${diffResult.stderr}');
    exit(1);
  }

  final List<String> lines = diffResult.stdout
      .toString()
      .split('\n')
      .where((String line) => line.isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    print('No files modified in the last commit of upstream/main. Cannot guarantee conflict.');
    exit(1);
  }

  final String fileToConflict = lines.first;
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
  final file = File('${packageDir.path}/$fileToConflict');
  if (!file.existsSync()) {
    print('File does not exist: ${file.path}');
    exit(1);
  }
  await file.writeAsString('// CONFLICTING CHANGE\n');

  // 5. Commit the change
  print('Committing...');
  final ProcessResult addResult = await Process.run('git', <String>[
    'add',
    fileToConflict,
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
