// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// This file is a stub to satisfy the analyzer by matching the public API
// surface of the real implementation. This code should never actually be
// called.

/// The iOS and macOS implementation of [PathProviderPlatform].
class PathProviderFoundation extends PathProviderPlatform {
  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {}

  /// Returns the path to the container of the specified App Group.
  /// This is only supported for iOS.
  Future<String?> getContainerPath({required String appGroupIdentifier}) async {
    return null;
  }
}
