// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'darwin_scoped_storage_cross_directory.dart';
import 'darwin_scoped_storage_cross_file.dart';

/// Implementation of [CrossFilePlatform] for iOS and macOS.
base class CrossFileDarwin extends CrossFileIO {
  /// Registers this class as the default instance of [CrossFilePlatform].
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileDarwin();
  }

  /// Whether the current implementation of `cross_file` is [CrossFileDarwin].
  static bool isCurrentImplementation() =>
      CrossFilePlatform.instance.runtimeType == CrossFileDarwin;

  @override
  DarwinScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return DarwinScopedStorageXFile(params);
  }

  @override
  DarwinScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    return DarwinScopedStorageXDirectory(params);
  }
}

// final ffi.DynamicLibrary _dylib = () {
//   return ffi.DynamicLibrary.open(
//     '/System/Library/Frameworks/Foundation.framework/Foundation',
//   );
// }();

// /// The bindings to the native functions in [_dylib].
// final FoundationFFI _lib = () {
//   return FoundationFFI(_dylib);
// }();
