// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class FLTCamExposureTests: XCTestCase {
  private func createCamera() -> (Camera, MockCaptureDevice, MockDeviceOrientationProvider) {
    let mockDevice = MockCaptureDevice()
    let mockDeviceOrientationProvider = MockDeviceOrientationProvider()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in mockDevice }
    configuration.deviceOrientationProvider = mockDeviceOrientationProvider
    let camera = CameraTestUtils.createTestCamera(configuration)

    return (camera, mockDevice, mockDeviceOrientationProvider)
  }

  func testSetExposureModeLocked_setsAuthExposeMode() {
    let (camera, mockDevice, _) = createCamera()

    mockDevice.setExposureModeStub = { mode in
      // AVCaptureExposureModeAutoExpose automatically adjusts the exposure one time, and then
      // locks exposure for the device
      XCTAssertEqual(mode, .autoExpose)
    }

    camera.setExposureMode(.locked)
  }

  func testSetExposureModeAuto_setsContinousAutoExposureMode_ifSupported() {
    let (camera, mockDevice, _) = createCamera()

    // All exposure modes are supported
    mockDevice.isExposureModeSupportedStub = { _ in true }

    mockDevice.setExposureModeStub = { mode in
      XCTAssertEqual(mode, .continuousAutoExposure)
    }

    camera.setExposureMode(.auto)
  }

  func testSetExposureModeAuto_setsAutoExposeMode_ifContinousAutoIsNotSupported() {
    let (camera, mockDevice, _) = createCamera()

    // Continous auto exposure is not supported
    mockDevice.isExposureModeSupportedStub = { mode in
      mode != .continuousAutoExposure
    }

    mockDevice.setExposureModeStub = { mode in
      XCTAssertEqual(mode, .autoExpose)
    }

    camera.setExposureMode(.auto)
  }

  func testSetExposurePoint_setsExposurePointOfInterest() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createCamera()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientationStub = { .landscapeLeft }
    // Exposure point of interest is supported.
    mockDevice.isExposurePointOfInterestSupported = true

    // Verify the focus point of interest has been set.
    var setPoint = CGPoint.zero
    mockDevice.setExposurePointOfInterestStub = { point in
      if point == CGPoint(x: 1, y: 1) {
        setPoint = point
      }
    }

    let expectation = expectation(description: "Completion called")
    camera.setExposurePoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertEqual(setPoint, CGPoint(x: 1.0, y: 1.0))
  }

  func testSetExposurePoint_returnsError_ifNotSupported() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createCamera()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientationStub = { .landscapeLeft }
    // Exposure point of interest is not supported.
    mockDevice.isExposurePointOfInterestSupported = false

    let expectation = expectation(description: "Completion with error")

    camera.setExposurePoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setExposurePointFailed")
      XCTAssertEqual(error?.message, "Device does not have exposure point capabilities")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testSetExposureOffset_setsExposureTargetBias() {
    let (camera, mockDevice, _) = createCamera()

    let targetOffset = CGFloat(1.0)

    var setExposureTargetBiasCalled = false
    mockDevice.setExposureTargetBiasStub = { bias, handler in
      XCTAssertEqual(bias, Float(targetOffset))
      setExposureTargetBiasCalled = true
    }

    camera.setExposureOffset(targetOffset)

    XCTAssertTrue(setExposureTargetBiasCalled)
  }

  func testMaximumExposureOffset_returnsDeviceMaxExposureTargetBias() {
    let (camera, mockDevice, _) = createCamera()

    let targetOffset = CGFloat(1.0)

    mockDevice.maxExposureTargetBias = Float(targetOffset)

    XCTAssertEqual(camera.maximumExposureOffset, targetOffset)
  }

  func testMinimumExposureOffset_returnsDeviceMinExposureTargetBias() {
    let (camera, mockDevice, _) = createCamera()

    let targetOffset = CGFloat(1.0)

    mockDevice.minExposureTargetBias = Float(targetOffset)

    XCTAssertEqual(camera.minimumExposureOffset, targetOffset)
  }
}
