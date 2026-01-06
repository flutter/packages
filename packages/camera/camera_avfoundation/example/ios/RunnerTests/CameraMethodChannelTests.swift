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

final class CameraMethodChannelTests: XCTestCase {
  private func createCameraPlugin(with session: MockCaptureSession) -> CameraPlugin {
    return CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { session },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )
  }

  func testCreate_ShouldCallResultOnMainThread() {
    let avCaptureSessionMock = MockCaptureSession()
    avCaptureSessionMock.canSetSessionPresetStub = { _ in true }
    let camera = createCameraPlugin(with: avCaptureSessionMock)
    let expectation = self.expectation(description: "Result finished")

    var resultValue: NSNumber?
    camera.createCameraOnSessionQueue(
      withName: "acamera",
      settings: FCPPlatformMediaSettings.make(
        with: FCPPlatformResolutionPreset.medium,
        framesPerSecond: nil,
        videoBitrate: nil,
        audioBitrate: nil,
        enableAudio: true
      )
    ) { result, error in
      resultValue = result
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertNotNil(resultValue)
  }

  func testDisposeShouldDeallocCamera() {
    let avCaptureSessionMock = MockCaptureSession()
    avCaptureSessionMock.canSetSessionPresetStub = { _ in true }
    let camera = createCameraPlugin(with: avCaptureSessionMock)
    let createExpectation = self.expectation(description: "create's result block must be called")

    camera.createCameraOnSessionQueue(
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
    XCTAssertNotNil(camera.camera)

    let disposeExpectation = self.expectation(description: "dispose's result block must be called")
    camera.disposeCamera(0) { error in
      disposeExpectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertNil(camera.camera, "camera should be deallocated after dispose")
  }
}
