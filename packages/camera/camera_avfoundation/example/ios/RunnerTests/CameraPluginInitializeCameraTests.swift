// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class CameraPluginInitializeCameraTests: XCTestCase {
  private func createCameraPlugin() -> (
    CameraPlugin, MockCamera, MockGlobalEventApi, DispatchQueue
  ) {
    let mockCamera = MockCamera()
    let mockGlobalEventApi = MockGlobalEventApi()
    let captureSessionQueue = DispatchQueue(label: "io.flutter.camera.captureSessionQueue")

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: mockGlobalEventApi,
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockFLTCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: captureSessionQueue
    )
    cameraPlugin.camera = mockCamera

    return (cameraPlugin, mockCamera, mockGlobalEventApi, captureSessionQueue)
  }

  func testInitializeCamera_setsCameraOnFrameAvailableCallback() {
    let (cameraPlugin, mockCamera, _, _) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    var onFrameAvailableSet = false
    mockCamera.setOnFrameAvailableStub = { callback in
      onFrameAvailableSet = true
    }

    cameraPlugin.initializeCamera(0, withImageFormat: FCPPlatformImageFormatGroup.bgra8888) {
      error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(onFrameAvailableSet)
  }

  func testInitializeCamera_setsCameraDartAPI() {
    let (cameraPlugin, mockCamera, _, _) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    var dartAPISet = false
    mockCamera.setDartApiStub = { api in
      dartAPISet = true
    }

    cameraPlugin.initializeCamera(0, withImageFormat: FCPPlatformImageFormatGroup.bgra8888) {
      error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(dartAPISet)
  }

  func testInitializeCamera_sendsDeviceOrientation() {
    let (cameraPlugin, _, mockGlobalEventApi, captureSessionQueue) = createCameraPlugin()

    cameraPlugin.initializeCamera(0, withImageFormat: FCPPlatformImageFormatGroup.bgra8888) {
      error in
      XCTAssertNil(error)
    }

    waitForQueueRoundTrip(with: captureSessionQueue)

    XCTAssertTrue(mockGlobalEventApi.deviceOrientationChangedCalled)
  }

  func testInitializeCamera_startsCamera() {
    let (cameraPlugin, mockCamera, _, _) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    var startCalled = false
    mockCamera.startStub = {
      startCalled = true
    }

    cameraPlugin.initializeCamera(0, withImageFormat: FCPPlatformImageFormatGroup.bgra8888) {
      error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(startCalled)
  }
}
