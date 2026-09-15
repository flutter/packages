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

/// Checks out a branch that is behind upstream/main by 1 commit, makes a local commit,
/// and sets up the branch to test that pre-push-skill detects the branch is behind upstream,
/// verifies there are no merge conflicts, proceeds with checks without running update-release-info,
/// and reports that the branch needs to be updated before pushing.
void main() async {
  // The root of the packages directory.
  final Directory packageDir = Directory(
    Platform.script.toFilePath(),
  ).parent.parent.parent.parent.parent.parent;
  final dartFilePath = '${packageDir.path}/lib/src/camerax_library.dart';

  final String upstream = await getUpstreamRemote(packageDir.path);
  print('Detected upstream remote: $upstream');

  // 1. Fetch upstream main with depth of at least 2 to ensure upstream/main~1 is available
  print('Fetching $upstream main...');
  final ProcessResult fetchResult = await Process.run('git', <String>[
    'fetch',
    '--depth=2',
    upstream,
    'main',
  ], workingDirectory: packageDir.path);
  if (fetchResult.exitCode != 0) {
    print('Failed to fetch: ${fetchResult.stderr}');
    exit(1);
  }

  // 2. Checkout a new temporary branch 'eval_behind_upstream_no_conflict' starting 1 commit behind upstream/main
  print('Checking out eval_behind_upstream_no_conflict...');
  final ProcessResult checkoutResult = await Process.run('git', <String>[
    'checkout',
    '-B',
    'eval_behind_upstream_no_conflict',
    '$upstream/main~1',
  ], workingDirectory: packageDir.path);
  if (checkoutResult.exitCode != 0) {
    print('Failed to checkout: ${checkoutResult.stderr}');
    exit(1);
  }

  // 3. Make a local change and commit it so our HEAD is behind upstream/main and diverged
  print('Making local change...');
  final dartFile = File(dartFilePath);
  await dartFile.writeAsString('\n// Eval comment\n', mode: FileMode.append);

  // 4. Commit
  print('Committing...');
  final ProcessResult addResult = await Process.run('git', <String>[
    'add',
    dartFilePath,
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
    'eval: local commit while behind upstream/main',
  ], workingDirectory: packageDir.path);
  if (commitResult.exitCode != 0) {
    print('Failed to commit: ${commitResult.stderr}');
    exit(1);
  }

  print('Setup complete.');
}
