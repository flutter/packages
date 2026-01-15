// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A mock implementation of `FrameRateRange` that allows mocking the class properties.
final class MockFrameRateRange: NSObject, FrameRateRange {
  var minFrameRate: Float64
  var maxFrameRate: Float64

  /// Initializes a `MockFrameRateRange` with the given frame rate range.
  init(minFrameRate: Float64, maxFrameRate: Float64) {
    self.minFrameRate = minFrameRate
    self.maxFrameRate = maxFrameRate
  }
}
