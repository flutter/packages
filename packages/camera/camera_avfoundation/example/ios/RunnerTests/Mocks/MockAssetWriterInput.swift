// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
