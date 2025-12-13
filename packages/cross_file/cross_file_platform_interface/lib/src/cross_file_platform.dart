// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_cross_directory.dart';
import 'platform_cross_file.dart';
import 'shared_storage/platform_shared_storage_cross_directory.dart';
import 'shared_storage/platform_shared_storage_cross_file.dart';

/// Interface for a platform implementation of `cross_file`.
abstract base class CrossFilePlatform {
  /// The instance of [CrossFilePlatform] to be used.
  ///
  /// Platform implementations packages should set this with their own
  /// implementation of [CrossFilePlatform] when they register themselves.
  static CrossFilePlatform? instance;

  /// Creates a new [PlatformXFile].
  @optionalTypeArgs
  PlatformXFile<T, S> createPlatformXFile<
    T extends PlatformXFileCreationParams,
    S extends PlatformXFileExtension
  >(PlatformXFileCreationParams params);

  /// Creates a new [PlatformXDirectory].
  @optionalTypeArgs
  PlatformXDirectory<T, S> createPlatformXDirectory<
    T extends PlatformXDirectoryCreationParams,
    S extends PlatformXDirectoryExtension
  >(PlatformXDirectoryCreationParams params) {
    throw UnimplementedError(
      'createPlatformXDirectory is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformSharedStorageXDirectory].
  PlatformSharedStorageXFile createPlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformSharedStorageXFile is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformSharedStorageXDirectory].
  PlatformSharedStorageXDirectory createPlatformSharedStorageXDirectory(
    PlatformSharedStorageXDirectoryCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformSharedStorageXDirectory is not implemented on the current platform.',
    );
  }
}
