// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTCaptureVideoDataOutput` protocol which allows injecting a custom
/// implementation.
class MockCaptureVideoDataOutput: NSObject, FLTCaptureVideoDataOutput {

  var avOutput = AVCaptureVideoDataOutput()
  var alwaysDiscardsLateVideoFrames = false
  var videoSettings: [String: Any] = [:]

  var connectionWithMediaTypeStub: ((AVMediaType) -> FLTCaptureConnection?)?

  func connection(withMediaType mediaType: AVMediaType) -> FLTCaptureConnection? {
    return connectionWithMediaTypeStub?(mediaType)
  }

  func setSampleBufferDelegate(
    _ sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?,
    queue sampleBufferCallbackQueue: DispatchQueue?
  ) {}
}
