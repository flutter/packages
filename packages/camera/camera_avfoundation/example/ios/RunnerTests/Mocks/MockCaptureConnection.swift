// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTCaptureConnection` that allows injecting a custom implementation.
class MockCaptureConnection: NSObject, FLTCaptureConnection {

  var setVideoOrientationStub: ((AVCaptureVideoOrientation) -> Void)?

  var connection: AVCaptureConnection {
    fatalError("Unimplemented")
  }
  var isVideoMirrored = false
  var _videoOrientation = AVCaptureVideoOrientation.portrait
  var videoOrientation: AVCaptureVideoOrientation {
    get {
      return _videoOrientation
    }
    set {
      if let stub = setVideoOrientationStub {
        stub(newValue)
      } else {
        _videoOrientation = newValue
      }
    }
  }
  var inputPorts: [AVCaptureInput.Port] = []
  var isVideoMirroringSupported = false
  var isVideoOrientationSupported = false
}
