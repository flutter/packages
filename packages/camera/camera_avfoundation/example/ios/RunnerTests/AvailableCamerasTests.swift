// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class AvailableCamerasTest: XCTestCase {
  private func createCameraPlugin(with deviceDiscoverer: MockCameraDeviceDiscoverer) -> CameraPlugin
  {
    return CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: deviceDiscoverer,
      permissionManager: MockFLTCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory()
    )
  }

  func testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone() {
    let mockDeviceDiscoverer = MockCameraDeviceDiscoverer()
    let cameraPlugin = createCameraPlugin(with: mockDeviceDiscoverer)
    let expectation = self.expectation(description: "Result finished")

    mockDeviceDiscoverer.discoverySessionStub = { deviceTypes, mediaType, position in
      // iPhone 13 Cameras:
      let wideAngleCamera = MockCaptureDevice()
      wideAngleCamera.uniqueID = "0"
      wideAngleCamera.position = .back

      let frontFacingCamera = MockCaptureDevice()
      frontFacingCamera.uniqueID = "1"
      frontFacingCamera.position = .front

      let ultraWideCamera = MockCaptureDevice()
      ultraWideCamera.uniqueID = "2"
      ultraWideCamera.position = .back

      let telephotoCamera = MockCaptureDevice()
      telephotoCamera.uniqueID = "3"
      telephotoCamera.position = .back

      var requiredTypes: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera, .builtInTelephotoCamera,
      ]
      if #available(iOS 13.0, *) {
        requiredTypes.append(.builtInUltraWideCamera)
      }
      var cameras = [wideAngleCamera, frontFacingCamera, telephotoCamera]
      if #available(iOS 13.0, *) {
        cameras.append(ultraWideCamera)
      }

      XCTAssertEqual(deviceTypes, requiredTypes)
      XCTAssertEqual(mediaType, .video)
      XCTAssertEqual(position, .unspecified)
      return cameras
    }

    var resultValue: [FCPPlatformCameraDescription]?
    cameraPlugin.availableCameras { result, error in
      XCTAssertNil(error)
      resultValue = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 30, handler: nil)

    // Verify the result.
    if #available(iOS 13.0, *) {
      XCTAssertEqual(resultValue?.count, 4)
    } else {
      XCTAssertEqual(resultValue?.count, 3)
    }
  }

  func testAvailableCamerasShouldReturnTwoCamerasOnDualCameraIPhone() {
    let mockDeviceDiscoverer = MockCameraDeviceDiscoverer()
    let cameraPlugin = createCameraPlugin(with: mockDeviceDiscoverer)
    let expectation = self.expectation(description: "Result finished")

    mockDeviceDiscoverer.discoverySessionStub = { deviceTypes, mediaType, position in
      // iPhone 8 Cameras:
      let wideAngleCamera = MockCaptureDevice()
      wideAngleCamera.uniqueID = "0"
      wideAngleCamera.position = .back

      let frontFacingCamera = MockCaptureDevice()
      frontFacingCamera.uniqueID = "1"
      frontFacingCamera.position = .front

      var requiredTypes: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera, .builtInTelephotoCamera,
      ]
      if #available(iOS 13.0, *) {
        requiredTypes.append(.builtInUltraWideCamera)
      }
      let cameras = [wideAngleCamera, frontFacingCamera]

      XCTAssertEqual(deviceTypes, requiredTypes)
      XCTAssertEqual(mediaType, .video)
      XCTAssertEqual(position, .unspecified)
      return cameras
    }

    var resultValue: [FCPPlatformCameraDescription]?
    cameraPlugin.availableCameras { result, error in
      XCTAssertNil(error)
      resultValue = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 30, handler: nil)

    // Verify the result.
    XCTAssertEqual(resultValue?.count, 2)
  }

  func testAvailableCamerasShouldReturnExternalLensDirectionForUnspecifiedCameraPosition() {
    let mockDeviceDiscoverer = MockCameraDeviceDiscoverer()
    let cameraPlugin = createCameraPlugin(with: mockDeviceDiscoverer)
    let expectation = self.expectation(description: "Result finished")

    mockDeviceDiscoverer.discoverySessionStub = { deviceTypes, mediaType, position in
      let unspecifiedCamera = MockCaptureDevice()
      unspecifiedCamera.uniqueID = "0"
      unspecifiedCamera.position = .unspecified

      var requiredTypes: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera, .builtInTelephotoCamera,
      ]
      if #available(iOS 13.0, *) {
        requiredTypes.append(.builtInUltraWideCamera)
      }
      let cameras = [unspecifiedCamera]

      XCTAssertEqual(deviceTypes, requiredTypes)
      XCTAssertEqual(mediaType, .video)
      XCTAssertEqual(position, .unspecified)
      return cameras
    }

    var resultValue: [FCPPlatformCameraDescription]?
    cameraPlugin.availableCameras { result, error in
      XCTAssertNil(error)
      resultValue = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertEqual(resultValue?.first?.lensDirection, .external)
  }
}
