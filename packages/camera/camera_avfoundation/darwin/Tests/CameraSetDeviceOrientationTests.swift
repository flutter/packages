// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Testing
import UIKit

@testable import camera_avfoundation

struct CameraSetDeviceOrientationTests {
  private func createCamera() -> (Camera, [MockCaptureConnection]) {
    let camera = CameraTestUtils.createTestCamera()

    let mockCapturePhotoOutput = MockCapturePhotoOutput()
    let mockPhotoCaptureConnection = MockCaptureConnection()
    mockPhotoCaptureConnection.isVideoOrientationSupported = true
    mockPhotoCaptureConnection.isVideoRotationAngleSupported = true

    mockCapturePhotoOutput.connectionWithMediaTypeStub = { _ in mockPhotoCaptureConnection }
    camera.capturePhotoOutput = mockCapturePhotoOutput

    let mockCaptureVideoDataOutput = MockCaptureVideoDataOutput()
    let mockVideoCaptureConnection = MockCaptureConnection()
    mockVideoCaptureConnection.isVideoOrientationSupported = true
    mockVideoCaptureConnection.isVideoRotationAngleSupported = true

    mockCaptureVideoDataOutput.connectionWithMediaTypeStub = { _ in mockVideoCaptureConnection }
    camera.captureVideoOutput = mockCaptureVideoDataOutput

    return (camera, [mockPhotoCaptureConnection, mockVideoCaptureConnection])
  }

  private func stubOrientationUpdates(
    on connection: MockCaptureConnection,
    _ handler: @escaping (AVCaptureVideoOrientation) -> Void
  ) {
    connection.setVideoOrientationStub = handler
    connection.setVideoRotationAngleStub = { angle in
      switch angle {
      case 0:
        handler(.landscapeRight)
      case 90:
        handler(.portrait)
      case 180:
        handler(.landscapeLeft)
      case 270:
        handler(.portraitUpsideDown)
      default:
        Issue.record("Unexpected video rotation angle: \(angle)")
      }
    }
  }

  @Test func setDeviceOrientation_setsOrientationsOfCaptureConnections() {
    let (camera, mockConnections) = createCamera()
    var setVideoOrientations: [AVCaptureVideoOrientation] = []
    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { setVideoOrientations.append($0) }
    }

    camera.deviceOrientation = .landscapeLeft

    // Device orientation is flipped compared to video orientation. When UIDeviceOrientation
    // is landscape left the video orientation should be landscape right.
    #expect(setVideoOrientations == [.landscapeRight, .landscapeRight])
  }

  @Test
  func setDeviceOrientation_setsLockedOrientationsOfCaptureConnection_ifCaptureOrientationIsLocked()
  {
    let (camera, mockConnections) = createCamera()
    camera.lockCaptureOrientation(PlatformDeviceOrientation.portraitDown)

    var setVideoOrientations: [AVCaptureVideoOrientation] = []
    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { setVideoOrientations.append($0) }
    }

    camera.deviceOrientation = .landscapeLeft

    #expect(setVideoOrientations == [.portraitUpsideDown, .portraitUpsideDown])
  }

  @Test func setDeviceOrientation_doesNotSetOrientations_ifRecordingIsInProgress() {
    let (camera, mockConnections) = createCamera()
    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { _ in Issue.record() }
    }

    camera.deviceOrientation = .landscapeLeft
  }

  @Test func setDeviceOrientation_doesNotSetOrientations_forDuplicateUpdates() {
    let (camera, mockConnections) = createCamera()
    var setVideoOrientationCallCount = 0
    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { _ in setVideoOrientationCallCount += 1 }
    }

    camera.deviceOrientation = .landscapeRight
    camera.deviceOrientation = .landscapeRight

    #expect(setVideoOrientationCallCount == mockConnections.count)
  }

  @Test func setDeviceOrientation_doesNotSetOrientations_ifNotSupportedByConnection() {
    let (camera, mockConnections) = createCamera()
    for connection in mockConnections {
      connection.isVideoOrientationSupported = false
      connection.isVideoRotationAngleSupported = false
      stubOrientationUpdates(on: connection) { _ in Issue.record() }
    }

    camera.deviceOrientation = .landscapeLeft
  }

  @Test(arguments: [
    (UIDeviceOrientation.portrait, AVCaptureVideoOrientation.portrait),
    (.portraitUpsideDown, .portraitUpsideDown),
    (.landscapeLeft, .landscapeRight),
    (.landscapeRight, .landscapeLeft),
    // Orientations without a video equivalent fall back to portrait.
    (.faceUp, .portrait),
  ])
  func setDeviceOrientation_mapsDeviceOrientationToVideoOrientation(
    deviceOrientation: UIDeviceOrientation, expectedVideoOrientation: AVCaptureVideoOrientation
  ) {
    let (camera, mockConnections) = createCamera()
    // Orientation updates are skipped for unchanged values, so start from a non-matching one.
    camera.deviceOrientation = .unknown
    var setVideoOrientations: [AVCaptureVideoOrientation] = []
    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { setVideoOrientations.append($0) }
    }

    camera.deviceOrientation = deviceOrientation

    #expect(setVideoOrientations == [expectedVideoOrientation, expectedVideoOrientation])
  }

  @Test func unlockCaptureOrientation_restoresDeviceOrientation() {
    let (camera, mockConnections) = createCamera()
    camera.lockCaptureOrientation(PlatformDeviceOrientation.portraitDown)
    camera.deviceOrientation = .landscapeLeft

    var setVideoOrientations: [AVCaptureVideoOrientation] = []
    for connection in mockConnections {
      stubOrientationUpdates(on: connection) { setVideoOrientations.append($0) }
    }

    camera.unlockCaptureOrientation()

    #expect(setVideoOrientations == [.landscapeRight, .landscapeRight])
  }
}
