// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockCamera: FLTCam {
  var setDartApiStub: ((FCPCameraEventApi?) -> Void)?
  var setOnFrameAvailableStub: (((() -> Void)?) -> Void)?
  var getMinimumExposureOffsetStub: (() -> CGFloat)?
  var getMaximumExposureOffsetStub: (() -> CGFloat)?
  var getMinimumAvailableZoomFactorStub: (() -> CGFloat)?
  var getMaximumAvailableZoomFactorStub: (() -> CGFloat)?
  var setUpCaptureSessionForAudioIfNeededStub: (() -> Void)?
  var receivedImageStreamDataStub: (() -> Void)?
  var startStub: (() -> Void)?
  var startVideoRecordingStub:
    ((@escaping (FlutterError?) -> Void, FlutterBinaryMessenger?) -> Void)?
  var pauseVideoRecordingStub: (() -> Void)?
  var resumeVideoRecordingStub: (() -> Void)?
  var stopVideoRecordingStub: ((((String?, FlutterError?) -> Void)?) -> Void)?
  var captureToFileStub: ((((String?, FlutterError?) -> Void)?) -> Void)?
  var setDeviceOrientationStub: ((UIDeviceOrientation) -> Void)?
  var lockCaptureOrientationStub: ((FCPPlatformDeviceOrientation) -> Void)?
  var unlockCaptureOrientationStub: (() -> Void)?
  var setImageFileFormatStub: ((FCPPlatformImageFileFormat) -> Void)?
  var setExposureModeStub: ((FCPPlatformExposureMode) -> Void)?
  var setExposureOffsetStub: ((Double) -> Void)?
  var setExposurePointStub: ((FCPPlatformPoint?, ((FlutterError?) -> Void)?) -> Void)?
  var setFocusModeStub: ((FCPPlatformFocusMode) -> Void)?
  var setFocusPointStub: ((FCPPlatformPoint?, ((FlutterError?) -> Void)?) -> Void)?
  var setZoomLevelStub: ((CGFloat, ((FlutterError?) -> Void)?) -> Void)?
  var setFlashModeStub: ((FCPPlatformFlashMode, ((FlutterError?) -> Void)?) -> Void)?
  var pausePreviewStub: (() -> Void)?
  var resumePreviewStub: (() -> Void)?
  var setDescriptionWhileRecordingStub: ((String, ((FlutterError?) -> Void)?) -> Void)?
  var startImageStreamStub: ((FlutterBinaryMessenger) -> Void)?
  var stopImageStreamStub: (() -> Void)?

  override var dartAPI: FCPCameraEventApi {
    get {
      preconditionFailure("Attempted to access unimplemented property: dartAPI")
    }
    set {
      setDartApiStub?(newValue)
    }
  }

  override var onFrameAvailable: (() -> Void) {
    get {
      preconditionFailure("Attempted to access unimplemented property: onFrameAvailable")
    }
    set {
      setOnFrameAvailableStub?(newValue)
    }
  }

  override var minimumExposureOffset: CGFloat {
    return getMinimumExposureOffsetStub?() ?? 0
  }

  override var maximumExposureOffset: CGFloat {
    return getMaximumExposureOffsetStub?() ?? 0
  }

  override var minimumAvailableZoomFactor: CGFloat {
    return getMinimumAvailableZoomFactorStub?() ?? 0
  }

  override var maximumAvailableZoomFactor: CGFloat {
    return getMaximumAvailableZoomFactorStub?() ?? 0
  }

  override func setUpCaptureSessionForAudioIfNeeded() {
    setUpCaptureSessionForAudioIfNeededStub?()
  }

  override func reportInitializationState() {}

  override func receivedImageStreamData() {
    receivedImageStreamDataStub?()
  }

  override func start() {
    startStub?()
  }

  override func stop() {}

  override func startVideoRecording(
    completion: @escaping (FlutterError?) -> Void,
    messengerForStreaming messenger: FlutterBinaryMessenger?
  ) {
    startVideoRecordingStub?(completion, messenger)
  }

  override func pauseVideoRecording() {
    pauseVideoRecordingStub?()
  }

  override func resumeVideoRecording() {
    resumeVideoRecordingStub?()
  }

  override func stopVideoRecording(completion: @escaping (String?, FlutterError?) -> Void) {
    stopVideoRecordingStub?(completion)
  }

  override func captureToFile(completion: @escaping (String?, FlutterError?) -> Void) {
    captureToFileStub?(completion)
  }

  override func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    setDeviceOrientationStub?(orientation)
  }

  override func lockCaptureOrientation(_ orientation: FCPPlatformDeviceOrientation) {
    lockCaptureOrientationStub?(orientation)
  }

  override func unlockCaptureOrientation() {
    unlockCaptureOrientationStub?()
  }

  override func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat) {
    setImageFileFormatStub?(fileFormat)
  }

  override func setExposureMode(_ mode: FCPPlatformExposureMode) {
    setExposureModeStub?(mode)
  }

  override func setExposureOffset(_ offset: Double) {
    setExposureOffsetStub?(offset)
  }

  override func setExposurePoint(
    _ point: FCPPlatformPoint?, withCompletion: @escaping (FlutterError?) -> Void
  ) {
    setExposurePointStub?(point, withCompletion)
  }

  override func setFocusMode(_ mode: FCPPlatformFocusMode) {
    setFocusModeStub?(mode)
  }

  override func setFocusPoint(
    _ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void
  ) {
    setFocusPointStub?(point, completion)
  }

  override func setZoomLevel(
    _ zoom: CGFloat,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setZoomLevelStub?(zoom, completion)
  }

  override func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setFlashModeStub?(mode, completion)
  }

  override func pausePreview() {
    pausePreviewStub?()
  }

  override func resumePreview() {
    resumePreviewStub?()
  }

  override func setDescriptionWhileRecording(
    _ cameraName: String,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setDescriptionWhileRecordingStub?(cameraName, completion)
  }

  override func startImageStream(with messenger: FlutterBinaryMessenger) {
    startImageStreamStub?(messenger)
  }

  override func stopImageStream() {
    stopImageStreamStub?()
  }

  override func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {}

  override func close() {}

  override func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return nil
  }
}
