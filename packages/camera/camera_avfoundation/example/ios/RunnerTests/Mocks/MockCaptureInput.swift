// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mocked implementation of FLTCaptureInput which allows injecting a custom
/// implementation.
final class MockCaptureInput: NSObject, FLTCaptureInput {
  var input: AVCaptureInput {
    preconditionFailure("Attempted to access unimplemented property: input")
  }

  var ports: [AVCaptureInput.Port] = []
}
