// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTAssetWriterInput` protocol which allows injecting a custom
/// implementation.
final class MockAssetWriterInput: NSObject, FLTAssetWriterInput {
  var appendStub: ((CMSampleBuffer) -> Bool)?

  var input: AVAssetWriterInput {
    preconditionFailure("Attempted to access unimplemented property: input")
  }

  var expectsMediaDataInRealTime = false

  var readyForMoreMediaData = false

  func append(_ sampleBuffer: CMSampleBuffer) -> Bool {
    return appendStub?(sampleBuffer) ?? false
  }
}
