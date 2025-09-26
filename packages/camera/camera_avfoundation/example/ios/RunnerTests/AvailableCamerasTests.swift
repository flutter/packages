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
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )
  }

  private func fakeNativeCameraList() -> [MockCaptureDevice] {
    var cameras: [MockCaptureDevice] = []

    let wideAngleCamera = MockCaptureDevice()
    wideAngleCamera.uniqueID = "0"
    wideAngleCamera.position = .back
    wideAngleCamera.deviceType = .builtInWideAngleCamera

    let frontFacingCamera = MockCaptureDevice()
    frontFacingCamera.uniqueID = "1"
    frontFacingCamera.position = .front
    frontFacingCamera.deviceType = .builtInWideAngleCamera

    let ultraWideCamera = MockCaptureDevice()
    ultraWideCamera.uniqueID = "2"
    ultraWideCamera.position = .back
    ultraWideCamera.deviceType = .builtInUltraWideCamera

    let telephotoCamera = MockCaptureDevice()
    telephotoCamera.uniqueID = "3"
    telephotoCamera.position = .back
    telephotoCamera.deviceType = .builtInTelephotoCamera

    // the order of `cameras` is important. It must match the order of the
    // discoveryDevices list used by availableCameras()
    cameras = [
      wideAngleCamera, frontFacingCamera, telephotoCamera, ultraWideCamera,
    ]

    return cameras
  }

  func testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone() {
    let mockDeviceDiscoverer = MockCameraDeviceDiscoverer()
    let cameraPlugin = createCameraPlugin(with: mockDeviceDiscoverer)
    let expectation = self.expectation(description: "Result finished")

    // We'll stub the discovery session and return this list of fake cameras
    let nativeCameras = fakeNativeCameraList()

    // The order of expectedDeviceTypesToBeRequested is important. We will use
    // this in our discovery session stub to confirm that availableCameras()
    // requests the correct DeviceTypes in the correct order.
    var expectedDeviceTypesToBeRequested: [AVCaptureDevice.DeviceType] = [
      .builtInWideAngleCamera,
      .builtInTelephotoCamera,
      .builtInUltraWideCamera,
    ]

    mockDeviceDiscoverer.discoverySessionStub = { deviceTypes, mediaType, position in
      // confirm that availableCameras() made the
      // expected call to our discovery stub
      XCTAssertEqual(deviceTypes, expectedDeviceTypesToBeRequested)
      XCTAssertEqual(mediaType, .video)
      XCTAssertEqual(position, .unspecified)
      return nativeCameras
    }

    var resultValue: [FCPPlatformCameraDescription]?
    cameraPlugin.availableCameras { result, error in
      XCTAssertNil(error)
      resultValue = result
      expectation.fulfill()
    }
    waitForExpectations(timeout: 30, handler: nil)

    // Verify the result.
    XCTAssertEqual(resultValue?.count, nativeCameras.count)
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

      let cameras = [wideAngleCamera, frontFacingCamera]

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

      let cameras = [unspecifiedCamera]

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
