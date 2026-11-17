// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

@testable import camera_avfoundation

/// Mock implementation of `CaptureVideoDataOutput` protocol which allows injecting a custom
/// implementation.
class MockCaptureVideoDataOutput: NSObject, CaptureVideoDataOutput {
  var avOutput = AVCaptureVideoDataOutput()
  var alwaysDiscardsLateVideoFrames = false
  var videoSettings: [String: Any]! = [:] {
    didSet { videoSettingsHistory.append(videoSettings) }
  }
  private(set) var videoSettingsHistory: [[String: Any]?] = []
  var availableVideoPixelFormatTypes: [FourCharCode] = [
    kCVPixelFormatType_32BGRA,
    kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
  ]

  var connectionWithMediaTypeStub: ((AVMediaType) -> CaptureConnection?)?

  func connection(with mediaType: AVMediaType) -> CaptureConnection? {
    return connectionWithMediaTypeStub?(mediaType)
  }

  func setSampleBufferDelegate(
    _ sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?,
    queue sampleBufferCallbackQueue: DispatchQueue?
  ) {}
}
