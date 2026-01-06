// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class CameraPluginCreateCameraTests: XCTestCase {
  private func createCameraPlugin() -> (
    CameraPlugin, MockCameraPermissionManager, MockCaptureSession
  ) {
    let mockPermissionManager = MockCameraPermissionManager()
    let mockCaptureSession = MockCaptureSession()

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: mockPermissionManager,
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { mockCaptureSession },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )

    return (cameraPlugin, mockPermissionManager, mockCaptureSession)
  }

  func testCreateCamera_requestsOnlyCameraPermissionWithAudioDisabled() {
    let (cameraPlugin, mockPermissionManager, _) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    var requestCameraPermissionCalled = false
    mockPermissionManager.requestCameraPermissionStub = { completion in
      requestCameraPermissionCalled = true
      // Permission is granted
      completion(nil)
    }
    var requestAudioPermissionCalled = false
    mockPermissionManager.requestAudioPermissionStub = { completion in
      requestAudioPermissionCalled = true
      // Permission is granted
      completion(nil)
    }

    cameraPlugin.createCamera(
      withName: "camera_name",
      settings: FCPPlatformMediaSettings.make(
        with: .medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: false)
    ) { result, error in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(requestCameraPermissionCalled)
    XCTAssertFalse(requestAudioPermissionCalled)
  }

  func testCreateCamera_requestsCameraAndAudioPermissionWithAudioEnabled() {
    let (cameraPlugin, mockPermissionManager, _) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    var requestCameraPermissionCalled = false
    mockPermissionManager.requestCameraPermissionStub = { completion in
      requestCameraPermissionCalled = true
      // Permission is granted
      completion(nil)
    }
    var requestAudioPermissionCalled = false
    mockPermissionManager.requestAudioPermissionStub = { completion in
      requestAudioPermissionCalled = true
      // Permission is granted
      completion(nil)
    }

    cameraPlugin.createCamera(
      withName: "camera_name",
      settings: FCPPlatformMediaSettings.make(
        with: .medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: true)
    ) { result, error in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(requestCameraPermissionCalled)
    XCTAssertTrue(requestAudioPermissionCalled)
  }

  func testCreateCamera_createsFLTCamSuccessfully() {
    let (cameraPlugin, mockPermissionManager, mockCaptureSession) = createCameraPlugin()
    let expectation = expectation(description: "Initialization completed")

    mockPermissionManager.requestCameraPermissionStub = { completion in
      // Permission is granted
      completion(nil)
    }
    mockPermissionManager.requestAudioPermissionStub = { completion in
      // Permission is granted
      completion(nil)
    }
    mockCaptureSession.canSetSessionPresetStub = { _ in true }

    cameraPlugin.createCamera(
      withName: "camera_name",
      settings: FCPPlatformMediaSettings.make(
        with: .medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: true)
    ) { result, error in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertNotNil(cameraPlugin.camera)
  }
}
