// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A protocol which abstracts the discovery of camera devices.
/// It is a thin wrapper around `AVCaptureDiscoverySession` and it exists to allow mocking in tests.
protocol CameraDeviceDiscoverer {
  func discoverySession(
    withDeviceTypes deviceTypes: [AVCaptureDevice.DeviceType],
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> [CaptureDevice]
}

/// The default implementation of the `CameraDeviceDiscoverer` protocol.
/// It wraps a call to `AVCaptureDeviceDiscoverySession`.
class DefaultCameraDeviceDiscoverer: NSObject, CameraDeviceDiscoverer {
  func discoverySession(
    withDeviceTypes deviceTypes: [AVCaptureDevice.DeviceType],
    mediaType: AVMediaType,
    position: AVCaptureDevice.Position
  ) -> [CaptureDevice] {
    return AVCaptureDevice.DiscoverySession(
      deviceTypes: deviceTypes,
      mediaType: mediaType,
      position: position
    ).devices
  }
}
