// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class FLTCamSetFlashModeTests: XCTestCase {
  private func createCamera() -> (Camera, MockCaptureDevice, MockCapturePhotoOutput) {
    let mockDevice = MockCaptureDevice()
    let mockCapturePhotoOutput = MockCapturePhotoOutput()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in mockDevice }
    let camera = CameraTestUtils.createTestCamera(configuration)
    camera.capturePhotoOutput = mockCapturePhotoOutput

    return (camera, mockDevice, mockCapturePhotoOutput)
  }

  func testSetFlashModeWithTorchMode_setsTrochModeOn() {
    let (camera, mockDevice, _) = createCamera()

    mockDevice.hasTorch = true
    mockDevice.isTorchAvailable = true

    var setTorchModeCalled = false
    mockDevice.setTorchModeStub = { torchMode in
      XCTAssertEqual(torchMode, .on)
      setTorchModeCalled = true
    }

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.torch) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)

    XCTAssertTrue(setTorchModeCalled)
  }

  func testSetFlashModeWithTorchMode_returnError_ifHasNoTorch() {
    let (camera, mockDevice, _) = createCamera()

    mockDevice.hasTorch = false

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.torch) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setFlashModeFailed")
      XCTAssertEqual(error?.message, "Device does not support torch mode")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testSetFlashModeWithTorchMode_returnError_ifTorchIsNotAvailable() {
    let (camera, mockDevice, _) = createCamera()

    mockDevice.hasTorch = true
    mockDevice.isTorchAvailable = false

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.torch) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setFlashModeFailed")
      XCTAssertEqual(error?.message, "Torch mode is currently not available")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testSetFlashModeWithNonTorchMode_setsTrochModeOff_ifTorchModeIsEnabled() {
    let (camera, mockDevice, mockCapturePhotoOutput) = createCamera()

    mockCapturePhotoOutput.supportedFlashModes = [.auto]

    mockDevice.hasFlash = true
    // Torch mode is enabled
    mockDevice.getTorchModeStub = { .on }

    var setTorchModeCalled = false
    mockDevice.setTorchModeStub = { torchMode in
      XCTAssertEqual(torchMode, .off)
      setTorchModeCalled = true
    }

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.auto) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)

    XCTAssertTrue(setTorchModeCalled)
  }

  func testSetFlashModeWithNonTorchMode_returnError_ifHasNoFlash() {
    let (camera, mockDevice, _) = createCamera()

    mockDevice.hasFlash = false

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.auto) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setFlashModeFailed")
      XCTAssertEqual(error?.message, "Device does not have flash capabilities")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testSetFlashModeWithNonTorchMode_returnError_ifModeIsNotSupported() {
    let (camera, mockDevice, mockCapturePhotoOutput) = createCamera()

    // No flash modes are supported
    mockCapturePhotoOutput.supportedFlashModes = []

    mockDevice.hasFlash = true

    let expectation = expectation(description: "Call completed")

    camera.setFlashMode(.auto) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setFlashModeFailed")
      XCTAssertEqual(error?.message, "Device does not support this specific flash mode")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }
}
