// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Adjusts a package-relative path to account for the package name being part of
/// the directory structure for Swift packages.
String sharedSourceRelativePathForPackagePath(String packageRelativePath) {
  return packageRelativePath.replaceAll(
    RegExp(r'/google_maps_flutter_ios[_\w\d]*/'),
    '/google_maps_flutter_ios/',
  );
}

/// Adjusts a shared-source-relative path to account for the package name being
/// part of the directory structure for Swift packages.
String packageRelativePathForSharedSourceRelativePath(
  String packageName,
  String sharedSourceRelativePath,
) {
  return sharedSourceRelativePath.replaceAll(
    '/google_maps_flutter_ios/',
    '/$packageName/',
  );
}

/// Returns the contents of the file with any differences caused only by the
/// package name removed.
String normalizedFileContents(File file) {
  return file
      .readAsStringSync()
      // Ignore differences caused only by the package name.
      .replaceAll(
        RegExp(r'google_maps_flutter_ios_[\w\d]+'),
        'google_maps_flutter_ios',
      )
      // Package name diffs could change line wrapping, so collapse whitespace.
      .replaceAll(RegExp(r'[\s\n]+'), ' ')
      .trim();
}

/// Updates the contents of [file] to replace any occurrences of variants of the
/// package name in things that look like paths with [packageName].
///
/// This should only be used on files where this is the only option, and where
/// the diffs are known to be safe, as not all instances of the package name
/// should be replaced in all files.
void updatePackageNameInPathReferences(File file, String packageName) {
  final String newContents = file.readAsStringSync().replaceAllMapped(
    RegExp(r'google_maps_flutter_ios[_\w\d]*([:/])'),
    (match) => '$packageName${match.group(1)}',
  );
  file.writeAsStringSync(newContents);
}

/// Updates the contents of [file] to replace any occurrences of variants of the
/// package name in Obj-C or Swift import statements.
///
/// This is necessary for native unit tests, which need to import the Swift
/// package by name.
void updatePackageNameInImports(File file, String packageName) {
  final String newContents = file.readAsStringSync().replaceAllMapped(
    RegExp(
      r'^(@?)import google_maps_flutter_ios[_\w\d]*(;?)$',
      multiLine: true,
    ),
    (match) => '${match.group(1)}import $packageName${match.group(2)}',
  );
  file.writeAsStringSync(newContents);
}
