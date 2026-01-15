// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_cross_directory.dart';
import 'platform_cross_file.dart';
import 'scoped_storage/platform_scoped_storage_cross_directory.dart';
import 'scoped_storage/platform_scoped_storage_cross_file.dart';

/// Interface for a platform implementation of `cross_file`.
abstract base class CrossFilePlatform {
  /// The instance of [CrossFilePlatform] to be used.
  ///
  /// Platform implementations packages should set this with their own
  /// implementation of [CrossFilePlatform] when they register themselves.
  static CrossFilePlatform? instance;

  /// Creates a new [PlatformXFile].
  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params);

  /// Creates a new [PlatformXDirectory].
  @optionalTypeArgs
  PlatformXDirectory createPlatformXDirectory(
    PlatformXDirectoryCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformXDirectory is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformScopedStorageXDirectory].
  PlatformScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformScopedStorageXFile is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformScopedStorageXDirectory].
  PlatformScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformScopedStorageXDirectory is not implemented on the current platform.',
    );
  }
}
