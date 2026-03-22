// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

@testable import camera_avfoundation

/// A mocked implementation of FLTCaptureInput which allows injecting a custom
/// implementation.
final class MockCaptureInput: NSObject, CaptureInput {
  var avInput: AVCaptureInput {
    preconditionFailure("Attempted to access unimplemented property: input")
  }

  var ports: [AVCaptureInput.Port] = []
}
