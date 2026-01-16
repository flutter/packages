// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Synchronizes files that are intended to be shared between
// google_maps_flutter_ios_* packages with the shared source of truth and other
// copies. See google_maps_flutter_ios_shared_code/README.md for details.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'utils.dart';

const String _sharedSourceRootName = 'google_maps_flutter_ios_shared_code';

Future<void> main(List<String> args) async {
  final Directory packageRoot = Directory(
    p.dirname(Platform.script.path),
  ).parent;
  final String packageName = p.basename(packageRoot.path);
  final sharedSourceRoot = Directory(
    p.join(packageRoot.parent.path, _sharedSourceRootName),
  );

  _syncSharedFiles(packageRoot, packageName, sharedSourceRoot);
  _reportUnsharedFiles(packageRoot, packageName, sharedSourceRoot);
}

void _syncSharedFiles(
  Directory packageRoot,
  String packageName,
  Directory sharedSourceRoot,
) {
  final List<String> otherImplementationPackages = sharedSourceRoot.parent
      .listSync()
      .whereType<Directory>()
      .map((e) => p.basename(e.path))
      .where(
        (name) =>
            name.startsWith('google_maps_flutter_ios') &&
            name != _sharedSourceRootName &&
            name != packageName,
      )
      .toList();

  final copiedFiles = <String>[];
  final missingFiles = <String>[];
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

    final packageFile = File(packagePath);
    if (!packageFile.existsSync()) {
      missingFiles.add(relativePath);
      continue;
    }
    final String sharedContents = normalizedFileContents(entity);
    final String newContents = normalizedFileContents(packageFile);
    if (newContents != sharedContents) {
      copiedFiles.add(relativePath);
      // Copy to shared source.
      _syncFile(packageFile, entity.path, 'google_maps_flutter_ios');
      // Copy to other implementation packages.
      for (final otherPackageName in otherImplementationPackages) {
        final String otherPackagePath = p.join(
          packageRoot.parent.path,
          otherPackageName,
          packageRelativePathForSharedSourceRelativePath(
            otherPackageName,
            relativePath,
          ),
        );
        _syncFile(packageFile, otherPackagePath, otherPackageName);
      }
    }
  }

  if (copiedFiles.isNotEmpty) {
    print('Copied files:');
    for (final file in copiedFiles) {
      print('  $file');
    }
  }
  if (missingFiles.isNotEmpty) {
    print(
      'This package is missing the following files from the shared source:',
    );
    for (final file in missingFiles) {
      print('  $file');
    }
    print(
      'If these files should no longer be shared, remove them from the shared source.',
    );
  }
}

/// Syncs a file from the given source to a destination package.
///
/// If the file needs special handling of package names that appear within the
/// contents of the file, it will update the package name in the file to match
/// the destination package name.
void _syncFile(
  File source,
  String destinationPath,
  String destinationPackageName,
) {
  source.copySync(destinationPath);
  if (<String>[
    // The Pigeon definition file has output paths that must use the
    // package name, to follow Swift package naming rules.
    '/pigeons/',
    // The mock needs to import the package.
    '.mocks.dart',
  ].any((pattern) => source.absolute.path.contains(pattern))) {
    updatePackageNameInPathReferences(
      File(destinationPath),
      destinationPackageName,
    );
  }
}

void _reportUnsharedFiles(
  Directory packageRoot,
  String packageName,
  Directory sharedSourceRoot,
) {
  final List<File> codeFiles = packageRoot
      .listSync(recursive: true)
      .whereType<File>()
      // Only report code files.
      .where(
        (file) =>
            <String>['.swift', '.m', '.h', '.dart'].any(file.path.endsWith),
      )
      // Flutter-generated files aren't expected to be shared.
      .where((file) => !file.path.contains('GeneratedPluginRegistrant'))
      // Ignore intermediate file directories.
      .where((file) => !_isInIntermediateDirectory(file.path))
      .toList();

  final unsharedFiles = <String>[];
  for (final file in codeFiles) {
    final String relativePath = p.relative(file.path, from: packageRoot.path);
    final String sharedPath = p.join(
      sharedSourceRoot.path,
      sharedSourceRelativePathForPackagePath(relativePath),
    );
    final sharedFile = File(sharedPath);
    if (!sharedFile.existsSync()) {
      unsharedFiles.add(relativePath);
    }
  }

  if (unsharedFiles.isNotEmpty) {
    print('\nThe following code files are not shared with other packages:');
    for (final file in unsharedFiles) {
      print('  $file');
    }
    print(
      'If this is not intentional, copy the relevant files to '
      '$_sharedSourceRootName, then re-run this tool.',
    );
  }
}

bool _isInIntermediateDirectory(String path) {
  return <String>[
    '.dart_tool',
    '.symlinks',
    '.build',
    'build',
    'ephemeral',
    'Pods',
  ].any((dir) => path.contains('/$dir/'));
}
