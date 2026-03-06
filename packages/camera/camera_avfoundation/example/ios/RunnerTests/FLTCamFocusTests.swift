// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class FLTCamSetFocusModeTests: XCTestCase {
  private func createCamera() -> (Camera, MockCaptureDevice, MockDeviceOrientationProvider) {
    let mockDevice = MockCaptureDevice()
    let mockDeviceOrientationProvider = MockDeviceOrientationProvider()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in mockDevice }
    configuration.deviceOrientationProvider = mockDeviceOrientationProvider
    let camera = CameraTestUtils.createTestCamera(configuration)

    return (camera, mockDevice, mockDeviceOrientationProvider)
  }

  func testAutoFocusWithContinuousModeSupported_ShouldSetContinuousAutoFocus() {
    let (camera, mockDevice, _) = createCamera()
    // AVCaptureFocusModeContinuousAutoFocus and AVCaptureFocusModeAutoFocus are supported.
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .continuousAutoFocus || mode == .autoFocus
    }

    var setFocusModeContinuousAutoFocusCalled = false

    mockDevice.setFocusModeStub = { mode in
      // Don't expect setFocusMode:AVCaptureFocusModeAutoFocus.
      if mode == .autoFocus {
        XCTFail("Unexpected call to setFocusMode")
      } else if mode == .continuousAutoFocus {
        setFocusModeContinuousAutoFocusCalled = true
      }
    }

    camera.setFocusMode(.auto)

    XCTAssertTrue(setFocusModeContinuousAutoFocusCalled)
  }

  func testAutoFocusWithContinuousModeNotSupported_ShouldSetAutoFocus() {
    let (camera, mockDevice, _) = createCamera()
    // AVCaptureFocusModeContinuousAutoFocus is not supported.
    // AVCaptureFocusModeAutoFocus is supported.
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .autoFocus
    }

    var setFocusModeAutoFocusCalled = false

    // Don't expect setFocusMode:AVCaptureFocusModeContinuousAutoFocus.
    mockDevice.setFocusModeStub = { mode in
      if mode == .continuousAutoFocus {
        XCTFail("Unexpected call to setFocusMode")
      } else if mode == .autoFocus {
        setFocusModeAutoFocusCalled = true
      }
    }

    camera.setFocusMode(.auto)

    XCTAssertTrue(setFocusModeAutoFocusCalled)
  }

  func testAutoFocusWithNoModeSupported_ShouldSetNothing() {
    let (camera, mockDevice, _) = createCamera()
    // No modes are supported.
    mockDevice.isFocusModeSupportedStub = { _ in
      false
    }

    // Don't expect any setFocus.
    mockDevice.setFocusModeStub = {
      _ in XCTFail("Unexpected call to setFocusMode")
    }

    camera.setFocusMode(.auto)
  }

  func testLockedFocusWithModeSupported_ShouldSetModeAutoFocus() {
    let (camera, mockDevice, _) = createCamera()
    // AVCaptureFocusModeContinuousAutoFocus and AVCaptureFocusModeAutoFocus are supported.
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .continuousAutoFocus || mode == .autoFocus
    }

    var setFocusModeAutoFocusCalled = false

    // AVCaptureFocusModeAutoFocus automatically adjusts the focus one time, and then locks focus
    mockDevice.setFocusModeStub = { mode in
      if mode == .continuousAutoFocus {
        XCTFail("Unexpected call to setFocusMode")
      } else if mode == .autoFocus {
        setFocusModeAutoFocusCalled = true
      }
    }

    camera.setFocusMode(.locked)

    XCTAssertTrue(setFocusModeAutoFocusCalled)
  }

  func testLockedFocusWithModeNotSupported_ShouldSetNothing() {
    let (camera, mockDevice, _) = createCamera()
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .continuousAutoFocus
    }

    // Don't expect any setFocus.
    mockDevice.setFocusModeStub = { _ in
      XCTFail("Unexpected call to setFocusMode")
    }

    camera.setFocusMode(.locked)
  }

  func testSetFocusPointWithResult_SetsFocusPointOfInterest() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createCamera()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientationStub = { .landscapeLeft }
    // Focus point of interest is supported.
    mockDevice.isFocusPointOfInterestSupported = true

    var setFocusPointOfInterestCalled = false
    mockDevice.setFocusPointOfInterestStub = { point in
      if point == CGPoint(x: 1.0, y: 1.0) {
        setFocusPointOfInterestCalled = true
      }
    }

    camera.setFocusPoint(PlatformPoint(x: 1, y: 1)) {
      result in
      let _ = self.assertSuccess(result)
    }

    XCTAssertTrue(setFocusPointOfInterestCalled)
  }

  func testSetFocusPoint_WhenNotSupported_ReturnsError() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createCamera()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientationStub = { .landscapeLeft }
    // Focus point of interest is not supported.
    mockDevice.isFocusPointOfInterestSupported = false

    let expectation = self.expectation(description: "Completion with error")

    camera.setFocusPoint(PlatformPoint(x: 1, y: 1)) { result in
      switch result {
      case .failure(let error as PigeonError):
        XCTAssertEqual(error.code, "setFocusPointFailed")
        XCTAssertEqual(error.message, "Device does not have focus point capabilities")
      default:
        XCTFail("Expected failure")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
