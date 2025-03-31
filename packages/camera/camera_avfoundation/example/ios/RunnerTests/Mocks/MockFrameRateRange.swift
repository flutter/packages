// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTFrameRateRange` that allows mocking the class properties.
final class MockFrameRateRange: NSObject, FLTFrameRateRange {
  var minFrameRate: Float
  var maxFrameRate: Float

  /// Initializes a `MockFrameRateRange` with the given frame rate range.
  init(minFrameRate: Float, maxFrameRate: Float) {
    self.minFrameRate = minFrameRate
    self.maxFrameRate = maxFrameRate
  }
}
