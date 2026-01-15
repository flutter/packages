// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'android_library.g.dart';
import 'android_scoped_storage_cross_file.dart';

/// Implementation of [PlatformSharedStorageXDirectory] for Android.
base class AndroidScopedStorageXDirectory
    extends PlatformScopedStorageXDirectory {
  /// Constructs an [AndroidScopedStorageXDirectory].
  AndroidScopedStorageXDirectory(super.params) : super.implementation();

  late final DocumentFile _documentFile = DocumentFile.fromTreeUri(
    treeUri: params.uri,
  );

  @override
  Future<bool> exists() async {
    return await _documentFile.exists() && await _documentFile.isDirectory();
  }

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    for (final DocumentFile documentFile in await _documentFile.listFiles()) {
      final String uri = await documentFile.getUri();
      if (await documentFile.isFile()) {
        yield AndroidScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: uri),
        );
      } else if (await documentFile.isDirectory()) {
        yield AndroidScopedStorageXDirectory(
          PlatformScopedStorageXDirectoryCreationParams(uri: uri),
        );
      }
    }
  }
}
