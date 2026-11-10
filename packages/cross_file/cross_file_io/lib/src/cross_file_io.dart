// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'io_file_system_cross_directory.dart';
import 'io_file_system_cross_file.dart';

/// Implementation of [CrossFilePlatform] for dart:io.
base class CrossFileIO extends CrossFilePlatform {
  /// Registers this class as the default instance of [CrossFilePlatform].
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileIO();
  }

  @override
  IOFileSystemXFile createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams params) {
    return IOFileSystemXFile(params);
  }

  @override
  IOFileSystemXDirectory createPlatformFileSystemXDirectory(
    PlatformFileSystemXDirectoryCreationParams params,
  ) {
    return IOFileSystemXDirectory(params);
  }
}
