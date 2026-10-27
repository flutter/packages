// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as path;

/// Placeholder text that is replaced with the new release version in a batch
/// release package's Dart files in `lib/` when creating a batch release.
///
/// For example, a deprecation message can use
/// `'This feature was deprecated in v{{NEXT_VERSION}}.'`.
const String nextVersionPlaceholder = '{{NEXT_VERSION}}';

/// A text file containing [nextVersionPlaceholder].
typedef VersionPlaceholderFile = ({File file, String content});

/// The set of files to search for [nextVersionPlaceholder].
enum VersionPlaceholderScope {
  /// Files in which the batch release tooling replaces placeholders: Dart files
  /// in `lib/`.
  replaceable,

  /// All text files in the package, other than those in build output or tool
  /// state directories. Used to find placeholders that won't be replaced.
  all;

  /// Whether the file at [relativePath], relative to the package root, is in
  /// this scope.
  bool includes(String relativePath, path.Context pathContext) {
    final List<String> components = pathContext.split(relativePath);
    switch (this) {
      case VersionPlaceholderScope.replaceable:
        return components.first == 'lib' && pathContext.extension(relativePath) == '.dart';
      case VersionPlaceholderScope.all:
        final List<String> directories = components.sublist(0, components.length - 1);
        return !directories.any((String name) => name.startsWith('.') || name == 'build');
    }
  }
}

/// Returns the files in [files] that are in [scope] and contain
/// [nextVersionPlaceholder], along with their contents, in path order.
///
/// [files] should be the files of the package rooted at [packageDirectory],
/// as returned by `PackageCommand.getFilesForPackage`.
Future<List<VersionPlaceholderFile>> findVersionPlaceholderFiles(
  Directory packageDirectory,
  Stream<File> files, {
  required VersionPlaceholderScope scope,
}) async {
  final path.Context pathContext = packageDirectory.fileSystem.path;
  final List<File> candidates =
      await files
            .where(
              (File file) => scope.includes(
                pathContext.relative(file.path, from: packageDirectory.path),
                pathContext,
              ),
            )
            .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));
  return <VersionPlaceholderFile>[
    for (final File file in candidates)
      if (_readUtf8(file) case final String content when content.contains(nextVersionPlaceholder))
        (file: file, content: content),
  ];
}

String? _readUtf8(File file) {
  try {
    return utf8.decode(file.readAsBytesSync());
  } on FormatException {
    return null;
  }
}
