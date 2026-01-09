// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class CameraInitRaceConditionsTests: XCTestCase {
  private func createCameraPlugin() -> (CameraPlugin, DispatchQueue) {
    let captureSessionQueue = DispatchQueue(label: "io.flutter.camera.captureSessionQueue")

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: captureSessionQueue
    )

    return (cameraPlugin, captureSessionQueue)
  }

  func testFixForCaptureSessionQueueNullPointerCrashDueToRaceCondition() {
    let (cameraPlugin, captureSessionQueue) = createCameraPlugin()
    let disposeExpectation = expectation(description: "dispose's result block must be called")
    let createExpectation = expectation(description: "create's result block must be called")

    // Mimic a dispose call followed by a create call, which can be triggered by slightly dragging the
    // home bar, causing the app to be inactive, and immediately regain active.
    cameraPlugin.disposeCamera(0) { error in
      disposeExpectation.fulfill()
    }

    cameraPlugin.createCameraOnSessionQueue(
      withName: "acamera",
      settings: FCPPlatformMediaSettings.make(
        with: .medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: true
      )
    ) { result, error in
      createExpectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    // `captureSessionQueue` must not be nil after `create` call. Otherwise a nil
    // `captureSessionQueue` passed into `AVCaptureVideoDataOutput::setSampleBufferDelegate:queue:`
    // API will cause a crash.
    XCTAssertNotNil(
      captureSessionQueue, "captureSessionQueue must not be nil after create method.")
  }

  func testFlutterChannelInitializedWhenStartingImageStream() {
    let (cameraPlugin, _captureSessionQueue) = createCameraPlugin()
    let createExpectation = expectation(description: "create's result block must be called")

    cameraPlugin.createCameraOnSessionQueue(
      withName: "acamera",
      settings: FCPPlatformMediaSettings.make(
        with: .medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: true
      )
    ) { result, error in
      createExpectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    // Start stream and wait for its completion.
    let startStreamExpectation = expectation(
      description: "startImageStream's result block must be called")
    cameraPlugin.startImageStream(completion: {
      _ in
      startStreamExpectation.fulfill()
    })

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertEqual(cameraPlugin.camera?.isStreamingImages, true)
  }

}
