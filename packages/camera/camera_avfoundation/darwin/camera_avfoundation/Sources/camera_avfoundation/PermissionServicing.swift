// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// A protocol for permission-related operations on AVCaptureDevice.
/// It exists to allow mocking permission checks in tests.
protocol PermissionServicing: NSObjectProtocol {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
  func requestAccess(
    for mediaType: AVMediaType,
    completion handler: @escaping @Sendable (Bool) -> Void
  )
}

/// Default implementation of PermissionServicing that forwards calls to AVCaptureDevice.
class DefaultPermissionService: NSObject, PermissionServicing {
  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
    return AVCaptureDevice.authorizationStatus(for: mediaType)
  }

  func requestAccess(
    for mediaType: AVMediaType,
    completion handler: @escaping @Sendable (Bool) -> Void
  ) {
    AVCaptureDevice.requestAccess(for: mediaType, completionHandler: handler)
  }
}
