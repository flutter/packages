// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// Camera authorization status and request-access calls.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol CameraPermissionChecking {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
  func requestAccess(
    for mediaType: AVMediaType,
    completionHandler handler: @escaping @Sendable (Bool) -> Void
  )
}

/// Production implementation that forwards to AVCaptureDevice.
struct DefaultCameraPermissionChecker: CameraPermissionChecking {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
    AVCaptureDevice.authorizationStatus(for: mediaType)
  }

  func requestAccess(
    for mediaType: AVMediaType,
    completionHandler handler: @escaping @Sendable (Bool) -> Void
  ) {
    AVCaptureDevice.requestAccess(for: mediaType, completionHandler: handler)
  }
}
