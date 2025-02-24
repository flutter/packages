// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class CameraFocusTests: XCTestCase {
  private func createSutAndMocks() -> (FLTCam, MockCaptureDevice, MockDeviceOrientationProvider) {
    let mockDevice = MockCaptureDevice()
    let mockDeviceOrientationProvider = MockDeviceOrientationProvider()

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.captureDeviceFactory = { mockDevice }
    configuration.deviceOrientationProvider = mockDeviceOrientationProvider
    let camera = FLTCreateCamWithConfiguration(configuration)

    return (camera, mockDevice, mockDeviceOrientationProvider)
  }

  func testAutoFocusWithContinuousModeSupported_ShouldSetContinuousAutoFocus() {
    let (camera, mockDevice, _) = createSutAndMocks()
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

    camera.applyFocusMode(.auto, on: mockDevice)

    XCTAssertTrue(setFocusModeContinuousAutoFocusCalled)
  }

  func testAutoFocusWithContinuousModeNotSupported_ShouldSetAutoFocus() {
    let (camera, mockDevice, _) = createSutAndMocks()
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

    camera.applyFocusMode(.auto, on: mockDevice)

    XCTAssertTrue(setFocusModeAutoFocusCalled)
  }

  func testAutoFocusWithNoModeSupported_ShouldSetNothing() {
    let (camera, mockDevice, _) = createSutAndMocks()
    // No modes are supported.
    mockDevice.isFocusModeSupportedStub = { _ in
      false
    }

    // Don't expect any setFocus.
    mockDevice.setFocusModeStub = {
      _ in XCTFail("Unexpected call to setFocusMode")
    }

    camera.applyFocusMode(.auto, on: mockDevice)
  }

  func testLockedFocusWithModeSupported_ShouldSetModeAutoFocus() {
    let (camera, mockDevice, _) = createSutAndMocks()
    // AVCaptureFocusModeContinuousAutoFocus and AVCaptureFocusModeAutoFocus are supported.
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .continuousAutoFocus || mode == .autoFocus
    }

    var setFocusModeAutoFocusCalled = false

    // Expect only setFocusMode:AVCaptureFocusModeAutoFocus.
    mockDevice.setFocusModeStub = { mode in
      if mode == .continuousAutoFocus {
        XCTFail("Unexpected call to setFocusMode")
      } else if mode == .autoFocus {
        setFocusModeAutoFocusCalled = true
      }
    }

    camera.applyFocusMode(.locked, on: mockDevice)

    XCTAssertTrue(setFocusModeAutoFocusCalled)
  }

  func testLockedFocusWithModeNotSupported_ShouldSetNothing() {
    let (camera, mockDevice, _) = createSutAndMocks()
    mockDevice.isFocusModeSupportedStub = { mode in
      mode == .continuousAutoFocus
    }

    // Don't expect any setFocus.
    mockDevice.setFocusModeStub = { _ in
      XCTFail("Unexpected call to setFocusMode")
    }

    camera.applyFocusMode(.locked, on: mockDevice)
  }

  func testSetFocusPointWithResult_SetsFocusPointOfInterest() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createSutAndMocks()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientation = .landscapeLeft
    // Focus point of interest is supported.
    mockDevice.focusPointOfInterestSupported = true

    var setFocusPointOfInterestCalled = false
    mockDevice.setFocusPointOfInterestStub = { point in
      if point == CGPoint(x: 1.0, y: 1.0) {
        setFocusPointOfInterestCalled = true
      }
    }

    camera.setFocusPoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNil(error)
    }

    XCTAssertTrue(setFocusPointOfInterestCalled)
  }

  func testSetFocusPoint_WhenNotSupported_ReturnsError() {
    let (camera, mockDevice, mockDeviceOrientationProvider) = createSutAndMocks()
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientation = .landscapeLeft
    // Focus point of interest is not supported.
    mockDevice.focusPointOfInterestSupported = false

    let expectation = self.expectation(description: "Completion with error")

    camera.setFocusPoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setFocusPointFailed")
      XCTAssertEqual(error?.message, "Device does not have focus point capabilities")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
