// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class FLTCamZoomTests: XCTestCase {
  private func createCamera() -> (FLTCam, MockCaptureDevice) {
    let mockDevice = MockCaptureDevice()

    let configuration = createTestCameraConfiguration()
    configuration.captureDeviceFactory = { mockDevice }
    let camera = FLTCam(configuration: configuration, error: nil)

    return (camera, mockDevice)
  }

  func testSetZoomLevel_setVideoZoomFactor() {
    let (camera, mockDevice) = createCamera()

    mockDevice.maxAvailableVideoZoomFactor = 2.0
    mockDevice.minAvailableVideoZoomFactor = 0.0

    let targetZoom = CGFloat(1.0)

    var setVideoZoomFactorCalled = false
    mockDevice.setVideoZoomFactorStub = { zoom in
      XCTAssertEqual(zoom, Float(targetZoom))
      setVideoZoomFactorCalled = true
    }

    let expectation = expectation(description: "Call completed")

    camera.setZoomLevel(targetZoom) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)

    XCTAssertTrue(setVideoZoomFactorCalled)
  }

  func testSetZoomLevel_returnsError_forZoomLevelBlowMinimum() {
    let (camera, mockDevice) = createCamera()

    // Allowed zoom range between 2.0 and 3.0
    mockDevice.maxAvailableVideoZoomFactor = 2.0
    mockDevice.minAvailableVideoZoomFactor = 3.0

    let expectation = expectation(description: "Call completed")

    camera.setZoomLevel(CGFloat(1.0)) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "ZOOM_ERROR")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testSetZoomLevel_returnsError_forZoomLevelAboveMaximum() {
    let (camera, mockDevice) = createCamera()

    // Allowed zoom range between 0.0 and 1.0
    mockDevice.maxAvailableVideoZoomFactor = 0.0
    mockDevice.minAvailableVideoZoomFactor = 1.0

    let expectation = expectation(description: "Call completed")

    camera.setZoomLevel(CGFloat(2.0)) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "ZOOM_ERROR")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testMaximumAvailableZoomFactor_returnsDeviceMaxAvailableVideoZoomFactor() {
    let (camera, mockDevice) = createCamera()

    let targetZoom = CGFloat(1.0)

    mockDevice.maxAvailableVideoZoomFactor = Float(targetZoom)

    XCTAssertEqual(camera.maximumAvailableZoomFactor, targetZoom)
  }

  func testMinimumAvailableZoomFactor_returnsDeviceMinAvailableVideoZoomFactor() {
    let (camera, mockDevice) = createCamera()

    let targetZoom = CGFloat(1.0)

    mockDevice.minAvailableVideoZoomFactor = Float(targetZoom)

    XCTAssertEqual(camera.minimumAvailableZoomFactor, targetZoom)
  }
}
