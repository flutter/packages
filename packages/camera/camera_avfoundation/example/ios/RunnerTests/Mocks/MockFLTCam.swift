// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

final class MockFLTCam: FLTCam {
  var setOnFrameAvailableStub: ((() -> Void) -> Void)?
  var setDartApiStub: ((FCPCameraEventApi) -> Void)?
  var setExposureModeStub: ((FCPPlatformExposureMode) -> Void)?
  var setFocusModeStub: ((FCPPlatformFocusMode) -> Void)?
  var getMinimumAvailableZoomFactorStub: (() -> CGFloat)?
  var getMaximumAvailableZoomFactorStub: (() -> CGFloat)?
  var getMinimumExposureOffsetStub: (() -> CGFloat)?
  var getMaximumExposureOffsetStub: (() -> CGFloat)?

  var startStub: (() -> Void)?
  var setDeviceOrientationStub: ((UIDeviceOrientation) -> Void)?
  var captureToFileStub: ((((String?, FlutterError?) -> Void)?) -> Void)?
  var setImageFileFormatStub: ((FCPPlatformImageFileFormat) -> Void)?
  var startVideoRecordingStub:
    ((@escaping (FlutterError?) -> Void, FlutterBinaryMessenger?) -> Void)?
  var stopVideoRecordingStub: ((((String?, FlutterError?) -> Void)?) -> Void)?
  var pauseVideoRecordingStub: (() -> Void)?
  var resumeVideoRecordingStub: (() -> Void)?
  var lockCaptureStub: ((FCPPlatformDeviceOrientation) -> Void)?
  var unlockCaptureOrientationStub: (() -> Void)?
  var setFlashModeStub: ((FCPPlatformFlashMode, ((FlutterError?) -> Void)?) -> Void)?
  var receivedImageStreamDataStub: (() -> Void)?
  var pausePreviewStub: (() -> Void)?
  var resumePreviewStub: (() -> Void)?
  var setDescriptionWhileRecordingStub: ((String, ((FlutterError?) -> Void)?) -> Void)?
  var setExposurePointStub: ((FCPPlatformPoint?, ((FlutterError?) -> Void)?) -> Void)?
  var setFocusPointStub: ((FCPPlatformPoint?, ((FlutterError?) -> Void)?) -> Void)?
  var setExposureOffsetStub: ((Double) -> Void)?
  var startImageStreamStub: ((FlutterBinaryMessenger) -> Void)?
  var stopImageStreamStub: (() -> Void)?
  var setZoomLevelStub: ((CGFloat, ((FlutterError?) -> Void)?) -> Void)?
  var setUpCaptureSessionForAudioIfNeededStub: (() -> Void)?

  override var onFrameAvailable: (() -> Void) {
    get {
      return super.onFrameAvailable
    }
    set {
      setOnFrameAvailableStub?(newValue)
    }
  }

  override var dartAPI: FCPCameraEventApi {
    get {
      return super.dartAPI
    }
    set {
      setDartApiStub?(newValue)
    }
  }

  /// The `setExposureMode` ObjC method is converted to property accessor in Swift translation
  override var exposureMode: FCPPlatformExposureMode {
    get {
      return super.exposureMode
    }
    set {
      setExposureModeStub?(newValue)
    }
  }

  /// The `setFocusMode` ObjC method is converted to property accessor in Swift translation
  override var focusMode: FCPPlatformFocusMode {
    get {
      return super.focusMode
    }
    set {
      setFocusModeStub?(newValue)
    }
  }

  override var minimumAvailableZoomFactor: CGFloat {
    get {
      return getMinimumAvailableZoomFactorStub?() ?? super.minimumAvailableZoomFactor
    }
    set {
      super.minimumAvailableZoomFactor = newValue
    }
  }

  override var maximumAvailableZoomFactor: CGFloat {
    get {
      return getMaximumAvailableZoomFactorStub?() ?? super.maximumAvailableZoomFactor
    }
    set {
      super.maximumAvailableZoomFactor = newValue
    }
  }

  override var minimumExposureOffset: CGFloat {
    get {
      return getMinimumExposureOffsetStub?() ?? super.minimumExposureOffset
    }
    set {
      super.minimumExposureOffset = newValue
    }
  }

  override var maximumExposureOffset: CGFloat {
    get {
      return getMaximumExposureOffsetStub?() ?? super.maximumExposureOffset
    }
    set {
      super.maximumExposureOffset = newValue
    }
  }

  override func start() {
    startStub?()
  }

  override func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    setDeviceOrientationStub?(orientation)
  }

  override func captureToFile(completion: @escaping (String?, FlutterError?) -> Void) {
    captureToFileStub?(completion)
  }

  override func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat) {
    setImageFileFormatStub?(fileFormat)
  }

  override func startVideoRecording(
    completion: @escaping (FlutterError?) -> Void,
    messengerForStreaming messenger: FlutterBinaryMessenger?
  ) {
    startVideoRecordingStub?(completion, messenger)
  }

  override func stopVideoRecording(completion: ((String?, FlutterError?) -> Void)?) {
    stopVideoRecordingStub?(completion)
  }

  override func pauseVideoRecording() {
    pauseVideoRecordingStub?()
  }

  override func resumeVideoRecording() {
    resumeVideoRecordingStub?()
  }

  override func lockCapture(_ orientation: FCPPlatformDeviceOrientation) {
    lockCaptureStub?(orientation)
  }

  override func unlockCaptureOrientation() {
    unlockCaptureOrientationStub?()
  }

  override func setFlashMode(
    _ mode: FCPPlatformFlashMode, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setFlashModeStub?(mode, completion)
  }

  override func receivedImageStreamData() {
    receivedImageStreamDataStub?()
  }

  override func pausePreview() {
    pausePreviewStub?()
  }

  override func resumePreview() {
    resumePreviewStub?()
  }

  override func setDescriptionWhileRecording(
    _ cameraName: String, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setDescriptionWhileRecordingStub?(cameraName, completion)
  }

  override func setExposurePoint(
    _ point: FCPPlatformPoint?, withCompletion completion: ((FlutterError?) -> Void)?
  ) {
    setExposurePointStub?(point, completion)
  }

  override func setFocusPoint(
    _ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void
  ) {
    setFocusPointStub?(point, completion)
  }

  override func setExposureOffset(_ offset: Double) {
    setExposureOffsetStub?(offset)
  }

  override func startImageStream(with messenger: FlutterBinaryMessenger) {
    startImageStreamStub?(messenger)
  }

  override func stopImageStream() {
    stopImageStreamStub?()
  }

  override func setZoomLevel(
    _ zoom: CGFloat, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    setZoomLevelStub?(zoom, completion)
  }

  override func setUpCaptureSessionForAudioIfNeeded() {
    setUpCaptureSessionForAudioIfNeededStub?()
  }
}
