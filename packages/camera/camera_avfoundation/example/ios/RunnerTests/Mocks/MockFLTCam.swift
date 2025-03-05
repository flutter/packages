// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

final class MockFLTCam: FLTCam {
  var setOnFrameAvailableStub: ((() -> Void) -> Void)?
  var setDartApiStub: ((FCPCameraEventApi) -> Void)?

  var startStub: (() -> Void)?
  var setDeviceOrientationStub: ((UIDeviceOrientation) -> Void)?

  override var onFrameAvailable: (() -> Void) {
    get {
      return super.onFrameAvailable
    }
    set {
      setOnFrameAvailableStub?(newValue)
    }
  }

  override var dartAPI: FCPCameraEventApi {
    get {
      return super.dartAPI
    }
    set {
      setDartApiStub?(newValue)
    }
  }

  override func start() {
    startStub?()
  }

  override func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    setDeviceOrientationStub?(orientation)
  }
}
