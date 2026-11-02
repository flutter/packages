// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos

/// Photo library authorization status and request-access calls.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol PhotoLibraryPermissionChecking {
  func authorizationStatus() -> PHAuthorizationStatus
  func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
}

/// Production implementation that forwards to PHPhotoLibrary.
struct DefaultPhotoLibraryPermissionChecker: PhotoLibraryPermissionChecking {
  func authorizationStatus() -> PHAuthorizationStatus {
    PHPhotoLibrary.authorizationStatus()
  }

  func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
    PHPhotoLibrary.requestAuthorization(handler)
  }
}
