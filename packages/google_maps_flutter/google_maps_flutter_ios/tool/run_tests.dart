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

  bool passesValidation = await _validatePackageSharedCode(
    packageRoot,
    packageName,
    sharedSourceRoot: sharedSourceRoot,
    log: true,
  );

  print(
    '\nChecking for unshared source files that are not in '
    'tool/unshared_source_files.dart...',
  );
  final List<String> unsharedFiles = unexpectedUnsharedSourceFiles(
    packageRoot,
    packageName,
    sharedSourceRoot,
  );
  if (unsharedFiles.isEmpty) {
    print('  No unexpected unshared files.');
  } else {
    passesValidation = false;
    for (final file in unsharedFiles) {
      print('  $file is not shared');
    }
  }

  if (!passesValidation) {
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

  // If everything else passed, sanity-check the other implementation packages.
  // Full diff evaluation is done by the copy of this script in each
  // implementation package, but if someone edits the shared code without
  // updating the other packages, this will catch it. This is useful both
  // locally, where people are unlikely to run the tests in every package, and
  // in CI, where if there are no changes to an implementation package the CI
  // for that package will be skipped.
  print('\nChecking other implementation packages...');
  final failingPackages = <String>[];
  for (final FileSystemEntity entity in packageRoot.parent.listSync()) {
    final String packageName = p.basename(entity.path);
    if (entity is! Directory ||
        !packageName.startsWith('google_maps_flutter_ios_') ||
        packageName == 'google_maps_flutter_ios_shared_code') {
      continue;
    }
    if (!await _validatePackageSharedCode(
      entity,
      packageName,
      sharedSourceRoot: sharedSourceRoot,
      log: false,
    )) {
      failingPackages.add(packageName);
    }
  }

  if (failingPackages.isEmpty) {
    print('  No unexpected diffs found.');
  } else {
    print('''
  The following packages do not match the shared source code:
${failingPackages.map((p) => '    $p').join('\n')}

If you manually synchronized changes to the shared code, you will also need to
copy those changes to the other implementation packages. In the future, consider
using sync_shared_files.dart instead of copying changes to the shared source
manually.
''');
    exit(1);
  }
}

/// Validates that the shared code in [packageRoot] matches the shared source of
/// truth.
///
/// Returns true if the package matches the shared source of truth.
Future<bool> _validatePackageSharedCode(
  Directory packageRoot,
  String packageName, {
  required Directory sharedSourceRoot,
  required bool log,
}) async {
  var hasDiffs = false;
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
    // Ignore .DS_Store files, which may be created in the shared source
    // directory by the OS.
    if (relativePath.endsWith('.DS_Store')) {
      continue;
    }

    // Adjust the paths to account for the package name being part of the
    // directory structure for Swift packages.
    final String packagePath = p.join(
      packageRoot.path,
      packageRelativePathForSharedSourceRelativePath(packageName, relativePath),
    );

    if (log) {
      print('Validating $relativePath');
    }
    final packageFile = File(packagePath);
    if (!packageFile.existsSync()) {
      if (log) {
        print('  File $relativePath does not exist in $packageName');
      }
      hasDiffs = true;
      continue;
    }
    final String expectedContents = normalizedFileContents(entity);
    final String contents = normalizedFileContents(packageFile);
    if (contents != expectedContents) {
      if (log) {
        print('  File $relativePath does not match expected contents:');
        await _printDiff(entity, packageFile);
      }
      hasDiffs = true;
    }
  }
  return !hasDiffs;
}

Future<void> _printDiff(File expected, File actual) async {
  final Process process = await Process.start('diff', [
    '-u',
    expected.absolute.path,
    actual.absolute.path,
  ], mode: ProcessStartMode.inheritStdio);
  await process.exitCode;
}
