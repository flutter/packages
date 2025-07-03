// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTCapturePhotoOutput` protocol which allows injecting a custom
/// implementation.
final class MockCapturePhotoOutput: NSObject, FLTCapturePhotoOutput {
  var avOutput = AVCapturePhotoOutput()
  var availablePhotoCodecTypes: [AVVideoCodecType] = []
  var highResolutionCaptureEnabled = false
  var supportedFlashModes: [NSNumber] = []

  // Stub that is called when the corresponding public method is called.
  var capturePhotoWithSettingsStub:
    ((_ settings: AVCapturePhotoSettings, _ delegate: AVCapturePhotoCaptureDelegate) -> Void)?

  // Stub that is called when the corresponding public method is called.
  var connectionWithMediaTypeStub: ((_ mediaType: AVMediaType) -> FLTCaptureConnection?)?

  func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
  {
    capturePhotoWithSettingsStub?(settings, delegate)
  }

  func connection(withMediaType mediaType: AVMediaType) -> FLTCaptureConnection? {
    return connectionWithMediaTypeStub?(mediaType)
  }
}
