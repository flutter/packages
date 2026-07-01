// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  Directory repoRoot = Directory.current;
  while (repoRoot.path != repoRoot.parent.path &&
      !(Directory(p.join(repoRoot.path, '.git')).existsSync() ||
          File(p.join(repoRoot.path, '.git')).existsSync())) {
    repoRoot = repoRoot.parent;
  }
  if (!(Directory(p.join(repoRoot.path, '.git')).existsSync() ||
      File(p.join(repoRoot.path, '.git')).existsSync())) {
    print('Installation failed because .git directory could not be found.');
    exit(1);
  }

  final ProcessResult result = await Process.run('git', [
    'config',
    'core.hooksPath',
    'script/githooks',
  ], workingDirectory: repoRoot.path);
  if (result.exitCode == 0) {
    print('Git hooks installed successfully!');
  } else {
    print('Failed to install Git hooks: ${result.stderr}');
    exit(1);
  }
}
