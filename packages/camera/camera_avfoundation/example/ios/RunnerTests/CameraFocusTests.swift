// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest
import camera_avfoundation

final class CameraFocusTests: XCTestCase {
  var camera: FLTCam!
  var mockDevice: MockCaptureDevice!
  var mockDeviceOrientationProvider: MockDeviceOrientationProvider!

  override func setUp() {
    mockDevice = MockCaptureDevice()
    mockDeviceOrientationProvider = MockDeviceOrientationProvider()

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.captureDeviceFactory = { self.mockDevice }
    configuration.deviceOrientationProvider = mockDeviceOrientationProvider
    camera = FLTCreateCamWithConfiguration(configuration)
  }

  func testAutoFocusWithContinuousModeSupported_ShouldSetContinuousAutoFocus() {
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
    // UI is currently in landscape left orientation.
    mockDeviceOrientationProvider.orientation = .landscapeLeft
    // Focus point of interest is supported.
    mockDevice.focusPointOfInterestSupported = true

    var setFocusPointOfInterestCalled = false
    mockDevice.setFocusPointOfInterestStub = { point in
      if point.x == 1 && point.y == 1 {
        setFocusPointOfInterestCalled = true
      }
    }

    camera.setFocusPoint(FCPPlatformPoint.makeWith(x: 1, y: 1)) { error in
      XCTAssertNil(error)
    }

    XCTAssertTrue(setFocusPointOfInterestCalled)
  }

  func testSetFocusPoint_WhenNotSupported_ReturnsError() {
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

    waitForExpectations(timeout: 1, handler: nil)
  }
}
