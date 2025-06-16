// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockCamera: NSObject, Camera {
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
  var startImageStreamStub: ((FlutterBinaryMessenger, (FlutterError?) -> Void) -> Void)?
  var stopImageStreamStub: (() -> Void)?

  var dartAPI: FCPCameraEventApi? {
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
    completion: @escaping (FlutterError?) -> Void,
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

  func stopVideoRecording(completion: @escaping (String?, FlutterError?) -> Void) {
    stopVideoRecordingStub?(completion)
  }

  func captureToFile(completion: @escaping (String?, FlutterError?) -> Void) {
    captureToFileStub?(completion)
  }

  func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    setDeviceOrientationStub?(orientation)
  }

  func lockCaptureOrientation(_ orientation: FCPPlatformDeviceOrientation) {
    lockCaptureOrientationStub?(orientation)
  }

  func unlockCaptureOrientation() {
    unlockCaptureOrientationStub?()
  }

  func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat) {
    setImageFileFormatStub?(fileFormat)
  }

  func setExposureMode(_ mode: FCPPlatformExposureMode) {
    setExposureModeStub?(mode)
  }

  func setExposureOffset(_ offset: Double) {
    setExposureOffsetStub?(offset)
  }

  func setExposurePoint(
    _ point: FCPPlatformPoint?, withCompletion: @escaping (FlutterError?) -> Void
  ) {
    setExposurePointStub?(point, withCompletion)
  }

  func setFocusMode(_ mode: FCPPlatformFocusMode) {
    setFocusModeStub?(mode)
  }

  func setFocusPoint(_ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void) {
    setFocusPointStub?(point, completion)
  }

  func setZoomLevel(
    _ zoom: CGFloat,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setZoomLevelStub?(zoom, completion)
  }

  func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setFlashModeStub?(mode, completion)
  }

  func pausePreview() {
    pausePreviewStub?()
  }

  func resumePreview() {
    resumePreviewStub?()
  }

  func setDescriptionWhileRecording(
    _ cameraName: String,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setDescriptionWhileRecordingStub?(cameraName, completion)
  }

  func startImageStream(
    with messenger: FlutterBinaryMessenger,
    completion: @escaping (FlutterError?) -> Void
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
