// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'android_scoped_storage_cross_directory.dart';
import 'android_scoped_storage_cross_file.dart';

/// Implementation of [CrossFilePlatform] for Android.
base class CrossFileAndroid extends CrossFileIO {
  /// Registers this class as the default instance of [CrossFilePlatform].
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileAndroid();
  }

  @override
  AndroidScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return AndroidScopedStorageXFile(params);
  }

  @override
  AndroidScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    return AndroidScopedStorageXDirectory(params);
  }
}
