// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import XCTest

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

private final class MockUIDevice: UIDevice {
  var mockOrientation: UIDeviceOrientation = .unknown

  override var orientation: UIDeviceOrientation {
    return mockOrientation
  }
}

final class CameraOrientationTests: XCTestCase {
  private func createCameraPlugin() -> (
    cameraPlugin: CameraPlugin,
    mockCamera: MockCamera,
    mockEventAPI: MockGlobalEventApi,
    mockDevice: MockCaptureDevice,
    mockDeviceDiscoverer: MockCameraDeviceDiscoverer,
    captureSessionQueue: DispatchQueue
  ) {
    let mockDevice = MockCaptureDevice()
    let mockCamera = MockCamera()
    let mockEventAPI = MockGlobalEventApi()
    let mockDeviceDiscoverer = MockCameraDeviceDiscoverer()
    let captureSessionQueue = DispatchQueue(label: "io.flutter.camera.captureSessionQueue")

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: mockEventAPI,
      deviceDiscoverer: mockDeviceDiscoverer,
      permissionManager: MockFLTCameraPermissionManager(),
      deviceFactory: { _ in mockDevice },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: captureSessionQueue
    )
    cameraPlugin.camera = mockCamera

    return (
      cameraPlugin,
      mockCamera,
      mockEventAPI,
      mockDevice,
      mockDeviceDiscoverer,
      captureSessionQueue
    )
  }

  private func sendOrientation(
    _ orientation: UIDeviceOrientation,
    to cameraPlugin: CameraPlugin,
    captureSessionQueue: DispatchQueue
  ) {
    cameraPlugin.orientationChanged(createMockNotification(for: orientation))
    waitForQueueRoundTrip(with: captureSessionQueue)
  }

  private func createMockNotification(for deviceOrientation: UIDeviceOrientation) -> Notification {
    let mockDevice = MockUIDevice()
    mockDevice.mockOrientation = deviceOrientation
    return Notification(name: Notification.Name("orientation_test"), object: mockDevice)
  }

  func testOrientationNotifications() {
    let (cameraPlugin, _, mockEventAPI, _, _, captureSessionQueue) = createCameraPlugin()

    sendOrientation(.portraitUpsideDown, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertEqual(mockEventAPI.lastOrientation, .portraitDown)
    sendOrientation(.portrait, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertEqual(mockEventAPI.lastOrientation, .portraitUp)
    sendOrientation(.landscapeLeft, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertEqual(mockEventAPI.lastOrientation, .landscapeLeft)
    sendOrientation(.landscapeRight, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertEqual(mockEventAPI.lastOrientation, .landscapeRight)
  }

  func testOrientationNotificationsNotCalledForFaceUp() {
    let (cameraPlugin, _, mockEventAPI, _, _, captureSessionQueue) = createCameraPlugin()
    sendOrientation(.faceUp, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertFalse(mockEventAPI.deviceOrientationChangedCalled)
  }

  func testOrientationNotificationsNotCalledForFaceDown() {
    let (cameraPlugin, _, mockEventAPI, _, _, captureSessionQueue) = createCameraPlugin()
    sendOrientation(.faceDown, to: cameraPlugin, captureSessionQueue: captureSessionQueue)
    XCTAssertFalse(mockEventAPI.deviceOrientationChangedCalled)
  }

  func testOrientationUpdateMustBeOnCaptureSessionQueue() {
    let queueExpectation = expectation(
      description: "Orientation update must happen on the capture session queue")
    let (cameraPlugin, mockCamera, _, _, _, captureSessionQueue) = createCameraPlugin()
    let captureSessionQueueSpecific = DispatchSpecificKey<Void>()
    captureSessionQueue.setSpecific(
      key: captureSessionQueueSpecific,
      value: ())

    mockCamera.setDeviceOrientationStub = { orientation in
      if DispatchQueue.getSpecific(key: captureSessionQueueSpecific) != nil {
        queueExpectation.fulfill()
      }
    }

    cameraPlugin.orientationChanged(createMockNotification(for: .landscapeLeft))
    waitForExpectations(timeout: 30, handler: nil)
  }

  func testOrientationChangedNoRetainCycle() {
    let (_, mockCamera, mockEventAPI, mockDevice, mockDeviceDiscoverer, _) = createCameraPlugin()
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    weak var weakPlugin: CameraPlugin?
    weak var weakDevice = mockDevice

    autoreleasepool {
      let cameraPlugin = CameraPlugin(
        registry: MockFlutterTextureRegistry(),
        messenger: MockFlutterBinaryMessenger(),
        globalAPI: mockEventAPI,
        deviceDiscoverer: mockDeviceDiscoverer,
        permissionManager: MockFLTCameraPermissionManager(),
        deviceFactory: { _ in weakDevice! },
        captureSessionFactory: { MockCaptureSession() },
        captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
        captureSessionQueue: captureSessionQueue
      )
      weakPlugin = cameraPlugin
      cameraPlugin.camera = mockCamera

      cameraPlugin.orientationChanged(createMockNotification(for: .landscapeLeft))
    }

    // Sanity check.
    let cameraDeallocatedExpectation = self.expectation(
      description: "Camera must have been deallocated.")
    captureSessionQueue.async {
      XCTAssertNil(weakPlugin)
      cameraDeallocatedExpectation.fulfill()
    }
    // Awaiting expectation is needed. The test is flaky when checking for nil right away.
    waitForExpectations(timeout: 1, handler: nil)

    var setDeviceOrientationCalled = false
    mockCamera.setDeviceOrientationStub = { orientation in
      if orientation == .landscapeLeft {
        setDeviceOrientationCalled = true
      }
    }

    weak var weakEventAPI = mockEventAPI
    // Must check in captureSessionQueue since orientationChanged dispatches to this queue.
    let expectation = self.expectation(description: "Dispatched to capture session queue")
    captureSessionQueue.async {
      XCTAssertFalse(setDeviceOrientationCalled)
      XCTAssertFalse(weakEventAPI?.deviceOrientationChangedCalled ?? false)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
