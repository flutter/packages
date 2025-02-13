// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import XCTest

@testable import camera_avfoundation

private final class MockCamera: FLTCam {
  var setDeviceOrientationStub: ((UIDeviceOrientation) -> Void)?

  override func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    setDeviceOrientationStub?(orientation)
  }
}

private final class MockUIDevice: UIDevice {
  var mockOrientation: UIDeviceOrientation = .unknown

  override var orientation: UIDeviceOrientation {
    return mockOrientation
  }
}

final class CameraOrientationTests: XCTestCase {
  private var mockCamera: MockCamera!
  private var mockDevice: MockCaptureDevice!
  private var mockEventAPI: MockGlobalEventApi!
  private var mockDeviceDiscoverer: MockCameraDeviceDiscoverer!
  private var cameraPlugin: CameraPlugin!

  override func setUp() {
    mockDevice = MockCaptureDevice()
    mockCamera = MockCamera()
    mockEventAPI = MockGlobalEventApi()
    mockDeviceDiscoverer = MockCameraDeviceDiscoverer()

    cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: mockEventAPI,
      deviceDiscoverer: mockDeviceDiscoverer,
      deviceFactory: { _ in self.mockDevice },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory()
    )
    cameraPlugin.camera = mockCamera
  }

  private func waitForRoundTrip(with queue: DispatchQueue) {
    let expectation = self.expectation(description: "Queue flush")
    queue.async {
      DispatchQueue.main.async {
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 30, handler: nil)
  }

  private func sendOrientation(_ orientation: UIDeviceOrientation, to cameraPlugin: CameraPlugin) {
    cameraPlugin.orientationChanged(createMockNotification(for: orientation))
    waitForRoundTrip(with: cameraPlugin.captureSessionQueue)
  }

  private func createMockNotification(for deviceOrientation: UIDeviceOrientation) -> Notification {
    let mockDevice = MockUIDevice()
    mockDevice.mockOrientation = deviceOrientation
    return Notification(name: Notification.Name("orientation_test"), object: mockDevice)
  }

  func testOrientationNotifications() {
    sendOrientation(.portraitUpsideDown, to: cameraPlugin)
    XCTAssertEqual(mockEventAPI.lastOrientation, .portraitDown)
    sendOrientation(.portrait, to: cameraPlugin)
    XCTAssertEqual(mockEventAPI.lastOrientation, .portraitUp)
    sendOrientation(.landscapeLeft, to: cameraPlugin)
    XCTAssertEqual(mockEventAPI.lastOrientation, .landscapeLeft)
    sendOrientation(.landscapeRight, to: cameraPlugin)
    XCTAssertEqual(mockEventAPI.lastOrientation, .landscapeRight)
  }

  func testOrientationNotificationsNotCalledForFaceUp() {
    sendOrientation(.faceUp, to: cameraPlugin)
    XCTAssertFalse(mockEventAPI.deviceOrientationChangedCalled)
  }

  func testOrientationNotificationsNotCalledForFaceDown() {
    sendOrientation(.faceDown, to: cameraPlugin)
    XCTAssertFalse(mockEventAPI.deviceOrientationChangedCalled)
  }

  func testOrientationUpdateMustBeOnCaptureSessionQueue() {
    let queueExpectation = expectation(
      description: "Orientation update must happen on the capture session queue")

    let plugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger())
    let captureSessionQueueSpecific = DispatchSpecificKey<Void>()
    plugin.captureSessionQueue.setSpecific(key: captureSessionQueueSpecific, value: ())
    plugin.camera = mockCamera

    mockCamera.setDeviceOrientationStub = { orientation in
      if DispatchQueue.getSpecific(key: captureSessionQueueSpecific) != nil {
        queueExpectation.fulfill()
      }
    }

    plugin.orientationChanged(createMockNotification(for: .landscapeLeft))
    waitForExpectations(timeout: 30, handler: nil)
  }

  func testOrientationChangedNoRetainCycle() {
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    weak var weakPlugin: CameraPlugin?
    weak var weakDevice: MockCaptureDevice! = mockDevice

    autoreleasepool {
      let plugin = CameraPlugin(
        registry: MockFlutterTextureRegistry(),
        messenger: MockFlutterBinaryMessenger(),
        globalAPI: mockEventAPI,
        deviceDiscoverer: mockDeviceDiscoverer,
        deviceFactory: { _ in weakDevice },
        captureSessionFactory: { MockCaptureSession() },
        captureDeviceInputFactory: MockCaptureDeviceInputFactory()
      )
      weakPlugin = plugin
      plugin.captureSessionQueue = captureSessionQueue
      plugin.camera = mockCamera

      plugin.orientationChanged(createMockNotification(for: .landscapeLeft))
    }

    // Sanity check.
    let cameraDeallocatedExpectation = self.expectation(
      description: "Camera must have been deallocated.")
    captureSessionQueue.async {
      XCTAssertNil(weakPlugin)
      cameraDeallocatedExpectation.fulfill()
    }
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
