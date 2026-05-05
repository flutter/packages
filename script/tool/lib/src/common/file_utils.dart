// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

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
  Directory base,
  List<String> components,
) {
  var dir = base;
  for (final directoryName in components) {
    dir = dir.childDirectory(directoryName);
  }
  return dir;
}

/// Returns the relative path from [from] to [entity] using [platformContext]
/// as the path context, but always formatting the result as a POSIX path
/// (using forward slashes).
///
/// This is useful for generating paths that will be used in configuration
/// files or command lines that expect POSIX paths, even when running on a
/// platform that uses a different path separator, or for display.
String relativePosixPath(
  FileSystemEntity entity, {
  required Directory from,
  required p.Context platformContext,
}) => p.posix.joinAll(
  platformContext.split(
    platformContext.relative(entity.absolute.path, from: from.path),
  ),
);
