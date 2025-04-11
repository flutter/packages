// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Mock implementation of `FLTCameraDeviceDiscovering` protocol which allows injecting a custom
/// implementation for session discovery.
final class MockCameraDeviceDiscoverer: NSObject, FLTCameraDeviceDiscovering {
  var discoverySessionStub:
    (
      (
        _ deviceTypes: [AVCaptureDevice.DeviceType],
        _ mediaType: AVMediaType,
        _ position: AVCaptureDevice.Position
      ) -> [NSObject & FLTCaptureDevice]?
    )?

  /// A stub that replaces the default implementation of
  /// `discoverySessionWithDeviceTypes:mediaType:position`.
  func discoverySession(
    withDeviceTypes deviceTypes: [AVCaptureDevice.DeviceType], mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> [FLTCaptureDevice] {
    return discoverySessionStub?(deviceTypes, mediaType, position) ?? []
  }
}
