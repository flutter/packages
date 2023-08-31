// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

/// Returns a [File] created by appending all but the last item in [components]
/// to [base] as subdirectories, then appending the last as a file.
///
/// Example:
///   childFileWithSubcomponents(rootDir, ['foo', 'bar', 'baz.txt'])
/// creates a File representing /rootDir/foo/bar/baz.txt.
File childFileWithSubcomponents(Directory base, List<String> components) {
  final String basename = components.removeLast();
  return childDirectoryWithSubcomponents(base, components).childFile(basename);
}

/// Returns a [Directory] created by appending everything in [components]
/// to [base] as subdirectories.
///
/// Example:
///   childFileWithSubcomponents(rootDir, ['foo', 'bar'])
/// creates a File representing /rootDir/foo/bar/.
Directory childDirectoryWithSubcomponents(
    Directory base, List<String> components) {
  Directory dir = base;
  for (final String directoryName in components) {
    dir = dir.childDirectory(directoryName);
  }
  return dir;
}
