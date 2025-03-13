// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

final class FLTCamSetExposureModeTests: XCTestCase {
  private func createCamera() -> (FLTCam, MockCaptureDevice) {
    let mockDevice = MockCaptureDevice()

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.captureDeviceFactory = { mockDevice }
    let camera = FLTCreateCamWithConfiguration(configuration)

    return (camera, mockDevice)
  }

  func testSetExposureModeLocked_setsLockedExposureMode() {
    let (camera, mockDevice) = createCamera()

    mockDevice.setExposureModeStub = { mode in
      XCTAssertEqual(mode, .locked)
    }

    camera.setExposureMode(.locked)
  }

  func testSetExposureModeAuto_setsContinousAutoExposureMode_ifSupported() {
    let (camera, mockDevice) = createCamera()

    // All exposure modes are supported
    mockDevice.isExposureModeSupportedStub = { _ in true }

    mockDevice.setExposureModeStub = { mode in
      XCTAssertEqual(mode, .continuousAutoExposure)
    }

    camera.setExposureMode(.auto)
  }

  func testSetExposureModeAuto_setsAutoExposeMode_ifNotSupported() {
    let (camera, mockDevice) = createCamera()

    // Continous auto exposure is not supported
    mockDevice.isExposureModeSupportedStub = { mode in
      mode != .continuousAutoExposure
    }

    mockDevice.setExposureModeStub = { mode in
      XCTAssertEqual(mode, .autoExpose)
    }

    camera.setExposureMode(.auto)
  }
}
