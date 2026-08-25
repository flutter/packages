// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Asserts that the current git branch is not `main` to prevent modifying the default branch.
void ensureNotMainBranch() {
  final ProcessResult branchResult = Process.runSync('git', <String>['branch', '--show-current']);
  final String branch = branchResult.stdout.toString().trim();
  if (branch == 'main') {
    stdout.writeln('Error: Cannot run setup scripts on main branch.');
    exit(1);
  }
}

/// Stages [paths] and commits them with [message] using dummy author metadata.
void commitFiles(List<String> paths, String message) {
  Process.runSync('git', <String>['add', ...paths]);
  Process.runSync('git', <String>[
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    message,
  ]);
}
