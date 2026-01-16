// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'cross_file_darwin_apis.g.dart';
import 'darwin_scoped_storage_cross_file.dart';

/// Implementation of [PlatformScopedStorageXDirectory] for iOS and macOS.
base class DarwinScopedStorageXDirectory
    extends PlatformScopedStorageXDirectory {
  /// Constructs an [DarwinScopedStorageXDirectory].
  DarwinScopedStorageXDirectory(super.params) : super.implementation();

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
        yield DarwinScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: uri),
        );
      } else if (await documentFile.isDirectory()) {
        yield DarwinScopedStorageXDirectory(
          PlatformScopedStorageXDirectoryCreationParams(uri: uri),
        );
      }
    }
  }
}
