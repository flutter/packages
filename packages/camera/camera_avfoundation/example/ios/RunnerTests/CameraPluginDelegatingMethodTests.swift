// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

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

    let targetOrientation = PlatformDeviceOrientation.landscapeLeft

    var lockCaptureCalled = false
    mockCamera.lockCaptureOrientationStub = { orientation in
      XCTAssertEqual(orientation, targetOrientation)
      lockCaptureCalled = true
    }

    cameraPlugin.lockCaptureOrientation(orientation: targetOrientation) { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.pausePreview { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.pauseVideoRecording { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.prepareForVideoRecording { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.receivedImageStreamData { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.resumeVideoRecording { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.resumePreview { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(resumePreviewCalled)
  }

  func testSetExposureMode_callsCameraExposureMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetExposureMode = PlatformExposureMode.locked

    var setExposureModeCalled = false
    mockCamera.setExposureModeStub = { mode in
      XCTAssertEqual(mode, targetExposureMode)
      setExposureModeCalled = true
    }

    cameraPlugin.setExposureMode(mode: targetExposureMode) { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.setExposureOffset(offset: targetExposureOffset) { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setExposureOffsetCalled)
  }

  func testSetFocusMode_callsCameraSetFocusMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFocusMode = PlatformFocusMode.locked

    var setFocusModeCalled = false
    mockCamera.setFocusModeStub = { mode in
      XCTAssertEqual(mode, targetFocusMode)
      setFocusModeCalled = true
    }

    cameraPlugin.setFocusMode(mode: targetFocusMode) { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setFocusModeCalled)
  }

  func testSetImageFileFormat_callsCameraSetImageFileFormat() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFileFormat = PlatformImageFileFormat.heif

    var setImageFileFormatCalled = false
    mockCamera.setImageFileFormatStub = { fileFormat in
      XCTAssertEqual(fileFormat, targetFileFormat)
      setImageFileFormatCalled = true
    }

    cameraPlugin.setImageFileFormat(format: targetFileFormat) { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(()))
    }

    cameraPlugin.startImageStream { result in
      let _ = self.assertSuccess(result)
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

    cameraPlugin.stopImageStream { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(()))
      startVideoRecordingCalled = true
    }

    cameraPlugin.startVideoRecording(enableStream: true) { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(()))
      startVideoRecordingCalled = true
    }

    cameraPlugin.startVideoRecording(enableStream: false) { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(targetPath))
      stopVideoRecordingCalled = true
    }

    cameraPlugin.stopVideoRecording { result in
      switch result {
      case .success(let path):
        XCTAssertEqual(path, targetPath)
      case .failure:
        XCTFail("Unexpected error")
      }
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

    cameraPlugin.unlockCaptureOrientation { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(unlockCaptureOrientationCalled)
  }

  func testSetExposurePoint_callsCameraSetExposurePoint() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetExposurePoint = PlatformPoint(x: 1.0, y: 1.0)

    var setExposurePointCalled = false
    mockCamera.setExposurePointStub = { point, completion in
      XCTAssertEqual(point, targetExposurePoint)
      completion(.success(()))
      setExposurePointCalled = true
    }

    cameraPlugin.setExposurePoint(point: targetExposurePoint) { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setExposurePointCalled)
  }

  func testSetFlashMode_callsCameraSetFlashMode() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFlashMode = PlatformFlashMode.auto

    var setFlashModeCalled = false
    mockCamera.setFlashModeStub = { mode, completion in
      XCTAssertEqual(mode, targetFlashMode)
      completion(.success(()))
      setFlashModeCalled = true
    }

    cameraPlugin.setFlashMode(mode: targetFlashMode) { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setFlashModeCalled)
  }

  func testSetFocusPoint_callsCameraSetFocusPoint() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetFocusPoint = PlatformPoint(x: 1.0, y: 1.0)

    var setFocusPointCalled = false
    mockCamera.setFocusPointStub = { point, completion in
      XCTAssertEqual(point, targetFocusPoint)
      completion(.success(()))
      setFocusPointCalled = true
    }

    cameraPlugin.setFocusPoint(point: targetFocusPoint) { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(()))
      setZoomLevelCalled = true
    }

    cameraPlugin.setZoomLevel(zoom: targetZoomLevel) { result in
      let _ = self.assertSuccess(result)
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
      completion(.success(targetPath))
      captureToFileCalled = true
    }

    cameraPlugin.takePicture { result in
      switch result {
      case .success(let path):
        XCTAssertEqual(path, targetPath)
      case .failure:
        XCTFail("Unexpected error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(captureToFileCalled)
  }

  func testUpdateDescriptionWhileRecording_callsCameraSetDescriptionWhileRecording() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetCameraName = "camera_name"

    var setDescriptionWhileRecordingCalled = false
    mockCamera.setDescriptionWhileRecordingStub = { cameraName, completion in
      XCTAssertEqual(cameraName, targetCameraName)
      completion(.success(()))
      setDescriptionWhileRecordingCalled = true
    }

    cameraPlugin.updateDescriptionWhileRecording(cameraName: targetCameraName) { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(setDescriptionWhileRecordingCalled)
  }

  func testGetMaxZoomLevel_returnsValueFromCameraGetMaximumAvailableZoomFactor() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMaximumZoomLevel = CGFloat(1.0)

    var getMaximumAvailableZoomFactorCalled = false
    mockCamera.getMaximumAvailableZoomFactorStub = {
      getMaximumAvailableZoomFactorCalled = true
      return targetMaximumZoomLevel
    }

    cameraPlugin.getMaxZoomLevel { result in
      switch result {
      case .success(let zoom):
        XCTAssertEqual(zoom, targetMaximumZoomLevel)
      case .failure:
        XCTFail("Unexpected error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMaximumAvailableZoomFactorCalled)
  }

  func testGetMinZoomLevel_returnsValueFromCameraGetMinimumAvailableZoomFactor() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMinimumZoomLevel = CGFloat(1.0)

    var getMinimumAvailableZoomFactorCalled = false
    mockCamera.getMinimumAvailableZoomFactorStub = {
      getMinimumAvailableZoomFactorCalled = true
      return targetMinimumZoomLevel
    }

    cameraPlugin.getMinZoomLevel { result in
      switch result {
      case .success(let zoom):
        XCTAssertEqual(zoom, targetMinimumZoomLevel)
      case .failure:
        XCTFail("Unexpected error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMinimumAvailableZoomFactorCalled)
  }

  func testGetMaxExposureOffset_returnsValueFromCameraGetMaximumExposureOffset() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMaximumExposureOffset = CGFloat(1.0)

    var getMaximumExposureOffsetCalled = false
    mockCamera.getMaximumExposureOffsetStub = {
      getMaximumExposureOffsetCalled = true
      return targetMaximumExposureOffset
    }

    cameraPlugin.getMaxExposureOffset { result in
      switch result {
      case .success(let offset):
        XCTAssertEqual(offset, targetMaximumExposureOffset)
      case .failure:
        XCTFail("Unexpected error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMaximumExposureOffsetCalled)
  }

  func testGetMinExposureOffset_returnsValueFromCameraGetMinimumExposureOffset() {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    let expectation = expectation(description: "Call completed")

    let targetMinimumExposureOffset = CGFloat(1.0)

    var getMinimumExposureOffsetCalled = false
    mockCamera.getMinimumExposureOffsetStub = {
      getMinimumExposureOffsetCalled = true
      return targetMinimumExposureOffset
    }

    cameraPlugin.getMinExposureOffset { result in
      switch result {
      case .success(let offset):
        XCTAssertEqual(offset, targetMinimumExposureOffset)
      case .failure:
        XCTFail("Unexpected error")
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(getMinimumExposureOffsetCalled)
  }
}
