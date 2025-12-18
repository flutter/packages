// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Tests of `CameraPlugin` methods delegating to `FLTCam` instance
final class CameraPluginDelegatingMethodTests: XCTestCase {
  private func createCameraPlugin() -> (CameraPlugin, MockCamera) {
    let mockCamera = MockCamera()

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )
    cameraPlugin.camera = mockCamera

    return (cameraPlugin, mockCamera)
  }

  func testLockCapture_callsCameraLockCapture() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetOrientation = FCPPlatformDeviceOrientation.landscapeLeft

    var lockCaptureCalled = false
    mockCamera.lockCaptureOrientationStub = { orientation in
      XCTAssertEqual(orientation, targetOrientation)
      lockCaptureCalled = true
    }

    cameraPlugin.lockCapture(targetOrientation) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(lockCaptureCalled)
  }

  func testPausePreview_callsCameraPausePreview() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var pausePreviewCalled = false
    mockCamera.pausePreviewStub = {
      pausePreviewCalled = true
    }

    cameraPlugin.pausePreview { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(pausePreviewCalled)
  }

  func testPauseVideoRecording_callsCameraPauseVideoRecording() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var pauseVideoRecordingCalled = false
    mockCamera.pauseVideoRecordingStub = {
      pauseVideoRecordingCalled = true
    }

    cameraPlugin.pauseVideoRecording { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(pauseVideoRecordingCalled)
  }

  func testPrepareForVideoRecording_callsCameraSetUpCaptureSessionForAudioIfNeeded() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var setUpCaptureSessionForAudioIfNeededCalled = false
    mockCamera.setUpCaptureSessionForAudioIfNeededStub = {
      setUpCaptureSessionForAudioIfNeededCalled = true
    }

    cameraPlugin.prepareForVideoRecording { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setUpCaptureSessionForAudioIfNeededCalled)
  }

  func testReceivedImageStreamData_callsCameraReceivedImageStreamData() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var receivedImageStreamDataCalled = false
    mockCamera.receivedImageStreamDataStub = {
      receivedImageStreamDataCalled = true
    }

    cameraPlugin.receivedImageStreamData { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(receivedImageStreamDataCalled)
  }

  func testResumeVideoRecording_callsCameraResumeVideoRecording() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var resumeVideoRecordingCalled = false
    mockCamera.resumeVideoRecordingStub = {
      resumeVideoRecordingCalled = true
    }

    cameraPlugin.resumeVideoRecording { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(resumeVideoRecordingCalled)
  }

  func testResumePreview_callsCameraResumePreview() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var resumePreviewCalled = false
    mockCamera.resumePreviewStub = {
      resumePreviewCalled = true
    }

    cameraPlugin.resumePreview { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(resumePreviewCalled)
  }

  func testSetExposureMode_callsCameraExposureMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetExposureMode = FCPPlatformExposureMode.locked

    var setExposureModeCalled = false
    mockCamera.setExposureModeStub = { mode in
      XCTAssertEqual(mode, targetExposureMode)
      setExposureModeCalled = true
    }

    cameraPlugin.setExposureMode(targetExposureMode) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setExposureModeCalled)
  }

  func testSetExposureOffset_callsCameraSetExposureOffset() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetExposureOffset = 1.0

    var setExposureOffsetCalled = false
    mockCamera.setExposureOffsetStub = { offset in
      XCTAssertEqual(offset, targetExposureOffset)
      setExposureOffsetCalled = true
    }

    cameraPlugin.setExposureOffset(targetExposureOffset) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setExposureOffsetCalled)
  }

  func testSetFocusMode_callsCameraSetFocusMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFocusMode = FCPPlatformFocusMode.locked

    var setFocusModeCalled = false
    mockCamera.setFocusModeStub = { mode in
      XCTAssertEqual(mode, targetFocusMode)
      setFocusModeCalled = true
    }

    cameraPlugin.setFocusMode(targetFocusMode) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setFocusModeCalled)
  }

  func testSetImageFileFormat_callsCameraSetImageFileFormat() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFileFormat = FCPPlatformImageFileFormat.heif

    var setImageFileFormatCalled = false
    mockCamera.setImageFileFormatStub = { fileFormat in
      XCTAssertEqual(fileFormat, targetFileFormat)
      setImageFileFormatCalled = true
    }

    cameraPlugin.setImageFileFormat(targetFileFormat) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setImageFileFormatCalled)
  }

  func testStartImageStream_callsCameraStartImageStream() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var startImageStreamCalled = false
    mockCamera.startImageStreamStub = { messenger, completion in
      startImageStreamCalled = true
      completion(nil)
    }

    cameraPlugin.startImageStream { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(startImageStreamCalled)
  }

  func testStopImageStream_callsCameraStopImageStream() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var stopImageStreamCalled = false
    mockCamera.stopImageStreamStub = {
      stopImageStreamCalled = true
    }

    cameraPlugin.stopImageStream { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(stopImageStreamCalled)
  }

  func testStartVideoRecording_withStreamingTrue_callsCameraStartVideoRecordingWithMessenger() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var startVideoRecordingCalled = false
    mockCamera.startVideoRecordingStub = { completion, messenger in
      XCTAssertNotNil(messenger)
      completion(nil)
      startVideoRecordingCalled = true
    }

    cameraPlugin.startVideoRecording(withStreaming: true) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(startVideoRecordingCalled)
  }

  func testStartVideoRecording_withStreamingFalse_callsCameraStartVideoRecordingWithoutMessenger() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var startVideoRecordingCalled = false
    mockCamera.startVideoRecordingStub = { completion, messenger in
      XCTAssertNil(messenger)
      completion(nil)
      startVideoRecordingCalled = true
    }

    cameraPlugin.startVideoRecording(withStreaming: false) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(startVideoRecordingCalled)
  }

  func testStopVideoRecording_callsCameraStopVideoRecording() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetPath = "path"

    var stopVideoRecordingCalled = false
    mockCamera.stopVideoRecordingStub = { completion in
      completion?(targetPath, nil)
      stopVideoRecordingCalled = true
    }

    cameraPlugin.stopVideoRecording { path, error in
      XCTAssertEqual(path, targetPath)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(stopVideoRecordingCalled)
  }

  func testUnlockCaptureOrientation_callsCameraUnlockCaptureOrientation() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    var unlockCaptureOrientationCalled = false
    mockCamera.unlockCaptureOrientationStub = {
      unlockCaptureOrientationCalled = true
    }

    cameraPlugin.unlockCaptureOrientation { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(unlockCaptureOrientationCalled)
  }

  func testSetExposurePoint_callsCameraSetExposurePoint() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetExposurePoint = FCPPlatformPoint.makeWith(x: 1.0, y: 1.0)

    var setExposurePointCalled = false
    mockCamera.setExposurePointStub = { point, completion in
      XCTAssertEqual(point, targetExposurePoint)
      completion?(nil)
      setExposurePointCalled = true
    }

    cameraPlugin.setExposurePoint(targetExposurePoint) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setExposurePointCalled)
  }

  func testSetFlashMode_callsCameraSetFlashMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFlashMode = FCPPlatformFlashMode.auto

    var setFlashModeCalled = false
    mockCamera.setFlashModeStub = { mode, completion in
      XCTAssertEqual(mode, targetFlashMode)
      completion?(nil)
      setFlashModeCalled = true
    }

    cameraPlugin.setFlashMode(targetFlashMode) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setFlashModeCalled)
  }

  func testSetFocusPoint_callsCameraSetFocusPoint() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFocusPoint = FCPPlatformPoint.makeWith(x: 1.0, y: 1.0)

    var setFocusPointCalled = false
    mockCamera.setFocusPointStub = { point, completion in
      XCTAssertEqual(point, targetFocusPoint)
      completion?(nil)
      setFocusPointCalled = true
    }

    cameraPlugin.setFocus(targetFocusPoint) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setFocusPointCalled)
  }

  func testSetZoomLevel_callsCameraSetZoomLevel() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetZoomLevel = 1.0

    var setZoomLevelCalled = false
    mockCamera.setZoomLevelStub = { zoom, completion in
      XCTAssertEqual(zoom, targetZoomLevel)
      completion?(nil)
      setZoomLevelCalled = true
    }

    cameraPlugin.setZoomLevel(targetZoomLevel) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setZoomLevelCalled)
  }

  func testTakePicture_callsCameraCaptureToFile() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetPath = "path"

    var captureToFileCalled = false
    mockCamera.captureToFileStub = { completion in
      completion?(targetPath, nil)
      captureToFileCalled = true
    }

    cameraPlugin.takePicture { path, error in
      XCTAssertEqual(path, targetPath)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(captureToFileCalled)
  }

  func testUpdateDescriptionWhileRecordingCameraName_callsCameraSetDescriptionWhileRecording() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetCameraName = "camera_name"

    var setDescriptionWhileRecordingCalled = false
    mockCamera.setDescriptionWhileRecordingStub = { cameraName, completion in
      XCTAssertEqual(cameraName, targetCameraName)
      completion?(nil)
      setDescriptionWhileRecordingCalled = true
    }

    cameraPlugin.updateDescriptionWhileRecordingCameraName(targetCameraName) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setDescriptionWhileRecordingCalled)
  }

  func testGetMaximumZoomLevel_returnsValueFromCameraGetMaximumAvailableZoomFactor() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMaximumZoomLevel = CGFloat(1.0)

    var getMaximumAvailableZoomFactorCalled = false
    mockCamera.getMaximumAvailableZoomFactorStub = {
      getMaximumAvailableZoomFactorCalled = true
      return targetMaximumZoomLevel
    }

    cameraPlugin.getMaximumZoomLevel { zoom, error in
      XCTAssertEqual(zoom?.doubleValue, targetMaximumZoomLevel)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMaximumAvailableZoomFactorCalled)
  }

  func testGetMinimumZoomLevel_returnsValueFromCameraGetMinimumAvailableZoomFactor() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMinimumZoomLevel = CGFloat(1.0)

    var getMinimumAvailableZoomFactorCalled = false
    mockCamera.getMinimumAvailableZoomFactorStub = {
      getMinimumAvailableZoomFactorCalled = true
      return targetMinimumZoomLevel
    }

    cameraPlugin.getMinimumZoomLevel { zoom, error in
      XCTAssertEqual(zoom?.doubleValue, targetMinimumZoomLevel)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMinimumAvailableZoomFactorCalled)
  }

  func testGetMaximumExposureOffset_returnsValueFromCameraGetMaximumExposureOffset() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMaximumExposureOffset = CGFloat(1.0)

    var getMaximumExposureOffsetCalled = false
    mockCamera.getMaximumExposureOffsetStub = {
      getMaximumExposureOffsetCalled = true
      return targetMaximumExposureOffset
    }

    cameraPlugin.getMaximumExposureOffset { offset, error in
      XCTAssertEqual(offset?.doubleValue, targetMaximumExposureOffset)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMaximumExposureOffsetCalled)
  }

  func testGetMinimumExposureOffset_returnsValueFromCameraGetMinimumExposureOffset() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMinimumExposureOffset = CGFloat(1.0)

    var getMinimumExposureOffsetCalled = false
    mockCamera.getMinimumExposureOffsetStub = {
      getMinimumExposureOffsetCalled = true
      return targetMinimumExposureOffset
    }

    cameraPlugin.getMinimumExposureOffset { offset, error in
      XCTAssertEqual(offset?.doubleValue, targetMinimumExposureOffset)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMinimumExposureOffsetCalled)
  }
}
