// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, internal, protected;

import 'cross_entity.dart';
import 'file_system/file_system_cross_directory.dart';
import 'file_system/file_system_cross_file.dart';
import 'scoped_storage/scoped_storage_cross_directory.dart';
import 'scoped_storage/scoped_storage_cross_file.dart';

/// A reference to a container of data resources.
///
/// Note: Not all platforms support accessing directories.
@immutable
abstract base class XDirectory extends XEntity {
  /// Constructs a [XDirectory] from a specific platform implementation.
  @internal
  @protected
  const XDirectory(PlatformXDirectory super.platform);

  /// Instantiates a [FileSystemXDirectory] as a reference to a directory
  /// (or folder) on the file system.
  factory XDirectory.fileSystem({required String path}) {
    return FileSystemXDirectory(path);
  }

  /// Instantiates a [ScopedStorageXFile] as a reference to a directory
  /// (or folder) on the file system within a devices scoped storage.
  factory XDirectory.scopedStorage({required String uri}) {
    return ScopedStorageXDirectory(uri: uri);
  }

  /// Implementation of [PlatformXDirectory] for the current platform.
  @internal
  @override
  PlatformXDirectory get platform => super.platform as PlatformXDirectory;

  /// Lists the sub-directories and files of this directory.
  Stream<XEntity> list() {
    // Converts PlatformXEntities to XEntities.
    return platform.list(const PlatformListParams()).map<XEntity>((PlatformXEntity entity) {
      switch (entity) {
        case PlatformScopedStorageXFile():
          return ScopedStorageXFile.fromPlatform(entity);
        case PlatformScopedStorageXDirectory():
          return ScopedStorageXDirectory.fromPlatform(entity);
        case PlatformFileSystemXFile():
          return FileSystemXFile.fromPlatform(entity);
        case PlatformFileSystemXDirectory():
          return FileSystemXDirectory.fromPlatform(entity);
      }

      return XEntity(entity);
    });
  }
}
