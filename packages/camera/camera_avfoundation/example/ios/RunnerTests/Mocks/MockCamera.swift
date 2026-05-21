// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter

@testable import camera_avfoundation

final class MockCamera: NSObject, Camera {
  var setDartApiStub: ((CameraEventApi?) -> Void)?
  var setOnFrameAvailableStub: (((() -> Void)?) -> Void)?
  var getMinimumExposureOffsetStub: (() -> CGFloat)?
  var getMaximumExposureOffsetStub: (() -> CGFloat)?
  var getMinimumAvailableZoomFactorStub: (() -> CGFloat)?
  var getMaximumAvailableZoomFactorStub: (() -> CGFloat)?
  var setUpCaptureSessionForAudioIfNeededStub: (() -> Void)?
  var receivedImageStreamDataStub: (() -> Void)?
  var startStub: (() -> Void)?
  var startVideoRecordingStub:
    ((@escaping (Result<Void, any Error>) -> Void, FlutterBinaryMessenger?) -> Void)?
  var pauseVideoRecordingStub: (() -> Void)?
  var resumeVideoRecordingStub: (() -> Void)?
  var stopVideoRecordingStub: ((@escaping (Result<String, any Error>) -> Void) -> Void)?
  var captureToFileStub: ((@escaping (Result<String, any Error>) -> Void) -> Void)?
  var setDeviceOrientationStub: ((UIDeviceOrientation) -> Void)?
  var lockCaptureOrientationStub: ((PlatformDeviceOrientation) -> Void)?
  var unlockCaptureOrientationStub: (() -> Void)?
  var setImageFileFormatStub: ((PlatformImageFileFormat) -> Void)?
  var setExposureModeStub: ((PlatformExposureMode) -> Void)?
  var setExposureOffsetStub: ((Double) -> Void)?
  var setExposurePointStub: ((PlatformPoint?, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var setFocusModeStub: ((PlatformFocusMode) -> Void)?
  var setFocusPointStub: ((PlatformPoint?, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var setZoomLevelStub: ((CGFloat, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var setFlashModeStub: ((PlatformFlashMode, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var pausePreviewStub: (() -> Void)?
  var resumePreviewStub: (() -> Void)?
  var setDescriptionWhileRecordingStub:
    ((String, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var startImageStreamStub:
    ((FlutterBinaryMessenger, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var stopImageStreamStub: (() -> Void)?
  var setVideoStabilizationModeStub:
    ((PlatformVideoStabilizationMode, @escaping (Result<Void, any Error>) -> Void) -> Void)?
  var getIsVideoStabilizationModeSupportedStub: ((PlatformVideoStabilizationMode) -> Bool)?

  var dartAPI: CameraEventApi? {
    get {
      preconditionFailure("Attempted to access unimplemented property: dartAPI")
    }
    set {
      setDartApiStub?(newValue)
    }
  }

  var onFrameAvailable: (() -> Void)? {
    get {
      preconditionFailure("Attempted to access unimplemented property: onFrameAvailable")
    }
    set {
      setOnFrameAvailableStub?(newValue)
    }
  }

  var videoFormat: FourCharCode = kCVPixelFormatType_32BGRA

  var isPreviewPaused: Bool = false
  var isStreamingImages: Bool = false

  var deviceOrientation: UIDeviceOrientation {
    get {
      preconditionFailure("Attempted to access unimplemented property: deviceOrientation")
    }
    set {
      setDeviceOrientationStub?(newValue)
    }
  }

  var minimumExposureOffset: CGFloat {
    return getMinimumExposureOffsetStub?() ?? 0
  }

  var maximumExposureOffset: CGFloat {
    return getMaximumExposureOffsetStub?() ?? 0
  }

  var minimumAvailableZoomFactor: CGFloat {
    return getMinimumAvailableZoomFactorStub?() ?? 0
  }

  var maximumAvailableZoomFactor: CGFloat {
    return getMaximumAvailableZoomFactorStub?() ?? 0
  }

  func setUpCaptureSessionForAudioIfNeeded() {
    setUpCaptureSessionForAudioIfNeededStub?()
  }

  func reportInitializationState() {}

  func receivedImageStreamData() {
    receivedImageStreamDataStub?()
  }

  func start() {
    startStub?()
  }

  func stop() {}

  func startVideoRecording(
    completion: @escaping (Result<Void, any Error>) -> Void,
    messengerForStreaming messenger: FlutterBinaryMessenger?
  ) {
    startVideoRecordingStub?(completion, messenger)
  }

  func pauseVideoRecording() {
    pauseVideoRecordingStub?()
  }

  func resumeVideoRecording() {
    resumeVideoRecordingStub?()
  }

  func stopVideoRecording(completion: @escaping (Result<String, any Error>) -> Void) {
    stopVideoRecordingStub?(completion)
  }

  func captureToFile(completion: @escaping (Result<String, any Error>) -> Void) {
    captureToFileStub?(completion)
  }

  func lockCaptureOrientation(_ orientation: PlatformDeviceOrientation) {
    lockCaptureOrientationStub?(orientation)
  }

  func unlockCaptureOrientation() {
    unlockCaptureOrientationStub?()
  }

  func setImageFileFormat(_ fileFormat: PlatformImageFileFormat) {
    setImageFileFormatStub?(fileFormat)
  }

  func setExposureMode(_ mode: PlatformExposureMode) {
    setExposureModeStub?(mode)
  }

  func setExposureOffset(_ offset: Double) {
    setExposureOffsetStub?(offset)
  }

  func setExposurePoint(
    _ point: PlatformPoint?, withCompletion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setExposurePointStub?(point, withCompletion)
  }

  func setFocusMode(_ mode: PlatformFocusMode) {
    setFocusModeStub?(mode)
  }

  func setFocusPoint(
    _ point: PlatformPoint?, completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setFocusPointStub?(point, completion)
  }

  func setZoomLevel(
    _ zoom: CGFloat,
    withCompletion completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setZoomLevelStub?(zoom, completion)
  }

  func setFlashMode(
    _ mode: PlatformFlashMode,
    withCompletion completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setFlashModeStub?(mode, completion)
  }

  func pausePreview() {
    pausePreviewStub?()
  }

  func resumePreview() {
    resumePreviewStub?()
  }

  func setVideoStabilizationMode(
    _ mode: PlatformVideoStabilizationMode,
    withCompletion completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setVideoStabilizationModeStub?(mode, completion)
  }

  func isVideoStabilizationModeSupported(_ mode: PlatformVideoStabilizationMode) -> Bool {
    return getIsVideoStabilizationModeSupportedStub?(mode) ?? false
  }

  func setDescriptionWhileRecording(
    _ cameraName: String,
    withCompletion completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    setDescriptionWhileRecordingStub?(cameraName, completion)
  }

  func startImageStream(
    with messenger: FlutterBinaryMessenger,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    startImageStreamStub?(messenger, completion)
  }

  func stopImageStream() {
    stopImageStreamStub?()
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {}

  func close() {}

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return nil
  }
}
