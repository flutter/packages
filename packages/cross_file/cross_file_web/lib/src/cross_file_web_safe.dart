// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

/// Implementation of [CrossFilePlatform] for web.
base class CrossFileWeb extends CrossFilePlatform {
  @override
  PlatformScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    throw UnsupportedError(
      '`CrossFileWeb.createPlatformScopedStorageXFile` is only supported on web.',
    );
  }
}
