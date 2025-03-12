// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Mock implementation of `FLTCaptureVideoDataOutput` protocol which allows injecting a custom
/// implementation.
class MockCaptureVideoDataOutput: NSObject, FLTCaptureVideoDataOutput {

  var avOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
  var alwaysDiscardsLateVideoFrames: Bool = false
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
