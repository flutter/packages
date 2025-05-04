// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class CameraExposureTests: XCTestCase {
  private func createSutAndMocks() -> (FLTCam, MockCaptureDevice, MockDeviceOrientationProvider) {
    let mockDevice = MockCaptureDevice()
    let mockDeviceOrientationProvider = MockDeviceOrientationProvider()

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.captureDeviceFactory = { mockDevice }
    configuration.deviceOrientationProvider = mockDeviceOrientationProvider
    let camera = FLTCreateCamWithConfiguration(configuration)

    return (camera, mockDevice, mockDeviceOrientationProvider)
  }

  func testSetExposurePointWithResult_SetsExposurePointOfInterest() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createSutAndMocks()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientation = .landscapeLeft
    // Exposure point of interest is supported.
    mockDevice.exposurePointOfInterestSupported = true

    // Verify the focus point of interest has been set.
    var setPoint = CGPoint.zero
    mockDevice.setExposurePointOfInterestStub = { point in
      if point == CGPoint(x: 1, y: 1) {
        setPoint = point
      }
    }

    let completionExpectation = expectation(description: "Completion called")
    camera.setExposurePoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNil(error)
      completionExpectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertEqual(setPoint, CGPoint(x: 1.0, y: 1.0))
  }

  func testSetExposurePoint_WhenNotSupported_ReturnsError() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createSutAndMocks()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientation = .landscapeLeft
    // Exposure point of interest is not supported.
    mockDevice.exposurePointOfInterestSupported = false

    let expectation = self.expectation(description: "Completion with error")

    camera.setExposurePoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setExposurePointFailed")
      XCTAssertEqual(error?.message, "Device does not have exposure point capabilities")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
