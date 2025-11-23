// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTCameraDeviceDiscoverer` protocol which allows injecting a custom
/// implementation for session discovery.
final class MockCameraDeviceDiscoverer: NSObject, CameraDeviceDiscoverer {
  var discoverySessionStub:
    (
      (
        _ deviceTypes: [AVCaptureDevice.DeviceType],
        _ mediaType: AVMediaType,
        _ position: AVCaptureDevice.Position
      ) -> [NSObject & CaptureDevice]?
    )?

  /// A stub that replaces the default implementation of
  /// `discoverySessionWithDeviceTypes:mediaType:position`.
  func discoverySession(
    withDeviceTypes deviceTypes: [AVCaptureDevice.DeviceType], mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> [CaptureDevice] {
    return discoverySessionStub?(deviceTypes, mediaType, position) ?? []
  }
}
