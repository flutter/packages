// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class FLTCamSetDeviceOrientationTests: XCTestCase {
  private func createCamera() -> (FLTCam, MockCaptureConnection, MockCaptureConnection) {
    let configuration = FLTCreateTestCameraConfiguration()
    let camera = FLTCreateCamWithConfiguration(configuration)

    let mockCapturePhotoOutput = MockCapturePhotoOutput()
    let mockPhotoCaptureConnection = MockCaptureConnection()
    mockPhotoCaptureConnection.isVideoOrientationSupported = true

    mockCapturePhotoOutput.connectionWithMediaTypeStub = { _ in mockPhotoCaptureConnection }
    camera.capturePhotoOutput = mockCapturePhotoOutput

    let mockCaptureVideoDataOutput = MockCaptureVideoDataOutput()
    let mockVideoCaptureConnection = MockCaptureConnection()
    mockVideoCaptureConnection.isVideoOrientationSupported = true

    mockCaptureVideoDataOutput.connectionWithMediaTypeStub = { _ in mockVideoCaptureConnection }
    camera.captureVideoOutput = mockCaptureVideoDataOutput

    return (camera, mockPhotoCaptureConnection, mockVideoCaptureConnection)
  }

  func testSetDeviceOrientation_setsOrientationsOfCaptureConnections() {
    let (camera, mockPhotoCaptureConnection, mockVideoCaptureConnection) = createCamera()
    var photoSetVideoOrientationCalled = false
    mockPhotoCaptureConnection.setVideoOrientationStub = { orientation in
      // Device orientation is flipped compared to video orientation. When UIDeviceOrientation
      // is landscape left the video orientation should be landscape right.
      XCTAssertEqual(orientation, .landscapeRight)
      photoSetVideoOrientationCalled = true
    }

    var videoSetVideoOrientationCalled = false
    mockVideoCaptureConnection.setVideoOrientationStub = { orientation in
      // Device orientation is flipped compared to video orientation. When UIDeviceOrientation
      // is landscape left the video orientation should be landscape right.
      XCTAssertEqual(orientation, .landscapeRight)
      videoSetVideoOrientationCalled = true
    }

    camera.setDeviceOrientation(.landscapeLeft)

    XCTAssertTrue(photoSetVideoOrientationCalled)
    XCTAssertTrue(videoSetVideoOrientationCalled)
  }

  func
    testSetDeviceOrientation_setsLockedOrientationsOfCaptureConnection_ifCaptureOrientationIsLocked()
  {
    let (camera, mockPhotoCaptureConnection, mockVideoCaptureConnection) = createCamera()
    var photoSetVideoOrientationCalled = false
    mockPhotoCaptureConnection.setVideoOrientationStub = { orientation in
      XCTAssertEqual(orientation, .portraitUpsideDown)
      photoSetVideoOrientationCalled = true
    }

    var videoSetVideoOrientationCalled = false
    mockVideoCaptureConnection.setVideoOrientationStub = { orientation in
      XCTAssertEqual(orientation, .portraitUpsideDown)
      videoSetVideoOrientationCalled = true
    }

    camera.lockCapture(FCPPlatformDeviceOrientation.portraitDown)

    camera.setDeviceOrientation(.landscapeLeft)

    XCTAssertTrue(photoSetVideoOrientationCalled)
    XCTAssertTrue(videoSetVideoOrientationCalled)
  }

  func testSetDeviceOrientation_doesNotSetOrientations_ifRecordingIsInProgress() {
    let (camera, mockPhotoCaptureConnection, mockVideoCaptureConnection) = createCamera()

    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    mockPhotoCaptureConnection.setVideoOrientationStub = { _ in XCTFail() }
    mockVideoCaptureConnection.setVideoOrientationStub = { _ in XCTFail() }

    camera.setDeviceOrientation(.landscapeLeft)
  }

  func testSetDeviceOrientation_doesNotSetOrientations_forDuplicateUpdates() {
    let (camera, mockPhotoCaptureConnection, mockVideoCaptureConnection) = createCamera()
    var photoSetVideoOrientationCallCount = 0
    mockPhotoCaptureConnection.setVideoOrientationStub = { _ in
      photoSetVideoOrientationCallCount += 1
    }

    var videoSetVideoOrientationCallCount = 0
    mockVideoCaptureConnection.setVideoOrientationStub = { _ in
      videoSetVideoOrientationCallCount += 1
    }

    camera.setDeviceOrientation(.landscapeRight)
    camera.setDeviceOrientation(.landscapeRight)

    XCTAssertEqual(photoSetVideoOrientationCallCount, 1)
    XCTAssertEqual(videoSetVideoOrientationCallCount, 1)
  }
}
