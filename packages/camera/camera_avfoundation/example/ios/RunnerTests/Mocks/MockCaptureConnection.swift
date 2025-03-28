// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTCaptureConnection` that allows injecting a custom implementation.
final class MockCaptureConnection: NSObject, FLTCaptureConnection {
  var setVideoOrientationStub: ((AVCaptureVideoOrientation) -> Void)?

  var connection: AVCaptureConnection {
    preconditionFailure("Attempted to access unimplemented property: connection")
  }
  var isVideoMirrored = false
  var videoOrientation: AVCaptureVideoOrientation {
    get { AVCaptureVideoOrientation.portrait }
    set {
      setVideoOrientationStub?(newValue)
    }
  }
  var inputPorts: [AVCaptureInput.Port] = []
  var isVideoMirroringSupported = false
  var isVideoOrientationSupported = false
}
