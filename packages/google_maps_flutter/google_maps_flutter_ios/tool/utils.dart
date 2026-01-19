// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Adjusts a package-relative path to account for the package name being part of
// the directory structure for Swift packages.
import 'dart:io';

String sharedSourceRelativePathForPackagePath(String packageRelativePath) {
  return packageRelativePath.replaceAll(
    RegExp('/google_maps_flutter_ios[_a-z]*/'),
    '/google_maps_flutter_ios/',
  );
}

// Adjusts a shared-source-relative path to account for the package name being
// part of the directory structure for Swift packages.
String packageRelativePathForSharedSourceRelativePath(
  String packageName,
  String sharedSourceRelativePath,
) {
  return sharedSourceRelativePath.replaceAll(
    '/google_maps_flutter_ios/',
    '/$packageName/',
  );
}

// Returns the contents of the file with all whitespace collapsed to single
// spaces and trailing whitespace removed.
String normalizedFileContents(File file) {
  return file.readAsStringSync().replaceAll(RegExp(r'[\s\n]+'), ' ').trim();
}
