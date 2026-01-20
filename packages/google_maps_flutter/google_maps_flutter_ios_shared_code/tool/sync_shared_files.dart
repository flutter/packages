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
    final String sharedContents = normalizedFileContents(entity);
    final String newContents = normalizedFileContents(packageFile);
    final copiedFiles = <String>[];
    if (newContents != sharedContents) {
      copiedFiles.add(relativePath);
      // Copy to shared source.
      packageFile.copySync(entity.path);
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
        packageFile.copySync(otherPackagePath);
      }
    }

    var changedPigeonSource = false;
    if (copiedFiles.isNotEmpty) {
      print('Copied files:');
      for (final file in copiedFiles) {
        print('  $file');
        if (relativePath.contains('/pigeon/')) {
          changedPigeonSource = true;
        }
      }
    }
    if (changedPigeonSource) {
      print(
        'A Pigeon source file was copied, and the generated files are not '
        'automatically copied.\n'
        'Re-run Pigeon generation in the other implementation packages.',
      );
    }
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
      // Generated files aren't expected to be shared.
      .where((file) => !file.path.contains('.g.'))
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
    'Pods',
  ].any((dir) => path.contains('/$dir/'));
}
