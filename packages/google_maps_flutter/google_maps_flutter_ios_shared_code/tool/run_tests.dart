// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Ensures that all files that are intended to be shared between
// google_maps_flutter_ios_* packages are in sync with the shared source of
// truth. See google_maps_flutter_ios_shared_code/README.md for details.
//
// Called from the custom-tests CI action.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'utils.dart';

Future<void> main(List<String> args) async {
  // There's no reason to run this on multiple platforms in CI, so limit it to
  // macOS where local development of this package will be happening.
  if (!Platform.isMacOS) {
    print('Skipping for non-macOS host');
    exit(0);
  }

  final Directory packageRoot = Directory(
    p.dirname(Platform.script.path),
  ).parent;
  final String packageName = p.basename(packageRoot.path);
  final sharedSourceRoot = Directory(
    p.join(packageRoot.parent.path, 'google_maps_flutter_ios_shared_code'),
  );

  var failed = false;
  for (final FileSystemEntity entity in sharedSourceRoot.listSync(
    recursive: true,
  )) {
    if (entity is! File) {
      continue;
    }
    final String relativePath = p.relative(
      entity.path,
      from: sharedSourceRoot.path,
    );
    // The shared source README.md is not part of the shared source of truth,
    // just an explanation of this source-sharing system.
    if (relativePath == 'README.md') {
      continue;
    }

    // Adjust the paths to account for the package name being part of the
    // directory structure for Swift packages.
    final String packagePath = p.join(
      packageRoot.path,
      packageRelativePathForSharedSourceRelativePath(packageName, relativePath),
    );

    print('Validating $relativePath');
    final packageFile = File(packagePath);
    if (!packageFile.existsSync()) {
      print('  File $relativePath does not exist in $packageName');
      failed = true;
      continue;
    }
    final String expectedContents = normalizedFileContents(entity);
    final String contents = normalizedFileContents(packageFile);
    if (contents != expectedContents) {
      print('  File $relativePath does not match expected contents:');
      await _printDiff(entity, packageFile);
      failed = true;
    }
  }

  if (failed) {
    print('''

If the changes you made should be shared with other copies of the
implementation, copy the changes to google_maps_flutter_ios_* directories:
  dart run tool/sync_shared_files.dart
To validate that the changes have been shared correctly, run this tool again.

If the changes you made should only be made to one copy of the implementation,
discuss with your reviewer or #hackers-ecosystem on Discord about the best
approach to sharing as much code as can still be shared.

For more information on the code sharing structure used by this package, see
the google_maps_flutter_ios_shared_code/README.md file.
    ''');
    exit(1);
  }
}

Future<void> _printDiff(File expected, File actual) async {
  final Process process = await Process.start('diff', [
    '-u',
    expected.absolute.path,
    actual.absolute.path,
  ], mode: ProcessStartMode.inheritStdio);
  await process.exitCode;
}
