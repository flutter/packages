// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreMotion

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class DefaultCamera: FLTCam, Camera {
  override var videoFormat: FourCharCode {
    didSet {
      captureVideoOutput.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: videoFormat
      ]
    }
  }

  override var deviceOrientation: UIDeviceOrientation {
    get { super.deviceOrientation }
    set {
      guard newValue != super.deviceOrientation else { return }

      super.deviceOrientation = newValue
      updateOrientation()
    }
  }

  var minimumExposureOffset: CGFloat { CGFloat(captureDevice.minExposureTargetBias) }
  var maximumExposureOffset: CGFloat { CGFloat(captureDevice.maxExposureTargetBias) }
  var minimumAvailableZoomFactor: CGFloat { captureDevice.minAvailableVideoZoomFactor }
  var maximumAvailableZoomFactor: CGFloat { captureDevice.maxAvailableVideoZoomFactor }

  /// The queue on which `latestPixelBuffer` property is accessed.
  /// To avoid unnecessary contention, do not access `latestPixelBuffer` on the `captureSessionQueue`.
  private let pixelBufferSynchronizationQueue = DispatchQueue(
    label: "io.flutter.camera.pixelBufferSynchronizationQueue")

  /// The queue on which captured photos (not videos) are written to disk.
  /// Videos are written to disk by `videoAdaptor` on an internal queue managed by AVFoundation.
  private let photoIOQueue = DispatchQueue(label: "io.flutter.camera.photoIOQueue")

  /// Tracks the latest pixel buffer sent from AVFoundation's sample buffer delegate callback.
  /// Used to deliver the latest pixel buffer to the flutter engine via the `copyPixelBuffer` API.
  private var latestPixelBuffer: CVPixelBuffer?
  private var lastVideoSampleTime = CMTime.zero
  private var lastAudioSampleTime = CMTime.zero

  /// Maximum number of frames pending processing.
  /// To limit memory consumption, limit the number of frames pending processing.
  /// After some testing, 4 was determined to be the best maximum value.
  /// https://github.com/flutter/plugins/pull/4520#discussion_r766335637
  private var maxStreamingPendingFramesCount = 4

  private var exposureMode = FCPPlatformExposureMode.auto
  private var focusMode = FCPPlatformFocusMode.auto

  private static func flutterErrorFromNSError(_ error: NSError) -> FlutterError {
    return FlutterError(
      code: "Error \(error.code)",
      message: error.localizedDescription,
      details: error.domain)
  }

  private static func createConnection(
    captureDevice: FLTCaptureDevice,
    videoFormat: FourCharCode,
    captureDeviceInputFactory: FLTCaptureDeviceInputFactory
  ) throws -> (FLTCaptureInput, FLTCaptureVideoDataOutput, AVCaptureConnection) {
    // Setup video capture input.
    let captureVideoInput = try captureDeviceInputFactory.deviceInput(with: captureDevice)

    // Setup video capture output.
    let captureVideoOutput = FLTDefaultCaptureVideoDataOutput(
      captureVideoOutput: AVCaptureVideoDataOutput())
    captureVideoOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: videoFormat
    ]
    captureVideoOutput.alwaysDiscardsLateVideoFrames = true

    // Setup video capture connection.
    let connection = AVCaptureConnection(
      inputPorts: captureVideoInput.ports,
      output: captureVideoOutput.avOutput)

    if captureDevice.position == .front {
      connection.isVideoMirrored = true
    }

    return (captureVideoInput, captureVideoOutput, connection)
  }

  func reportInitializationState() {
    // Get all the state on the current thread, not the main thread.
    let state = FCPPlatformCameraState.make(
      withPreviewSize: FCPPlatformSize.make(
        withWidth: Double(previewSize.width),
        height: Double(previewSize.height)
      ),
      exposureMode: exposureMode,
      focusMode: focusMode,
      exposurePointSupported: captureDevice.isExposurePointOfInterestSupported,
      focusPointSupported: captureDevice.isFocusPointOfInterestSupported
    )

    FLTEnsureToRunOnMainQueue { [weak self] in
      self?.dartAPI?.initialized(with: state) { _ in
        // Ignore any errors, as this is just an event broadcast.
      }
    }
  }

  func receivedImageStreamData() {
    streamingPendingFramesCount -= 1
  }

  func start() {
    videoCaptureSession.startRunning()
    audioCaptureSession.startRunning()
  }

  func stop() {
    videoCaptureSession.stopRunning()
    audioCaptureSession.stopRunning()
  }

  func startVideoRecording(
    completion: @escaping (FlutterError?) -> Void,
    messengerForStreaming messenger: FlutterBinaryMessenger?
  ) {
    guard !isRecording else {
      completion(
        FlutterError(
          code: "Error",
          message: "Video is already recording",
          details: nil))
      return
    }

    if let messenger = messenger {
      startImageStream(with: messenger) { [weak self] error in
        self?.setUpVideoRecording(completion: completion)
      }
      return
    }

    setUpVideoRecording(completion: completion)
  }

  /// Main logic to setup the video recording.
  private func setUpVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    let videoRecordingPath: String
    do {
      videoRecordingPath = try getTemporaryFilePath(
        withExtension: "mp4",
        subfolder: "videos",
        prefix: "REC_")
      self.videoRecordingPath = videoRecordingPath
    } catch let error as NSError {
      completion(DefaultCamera.flutterErrorFromNSError(error))
      return
    }

    guard setupWriter(forPath: videoRecordingPath) else {
      completion(
        FlutterError(
          code: "IOError",
          message: "Setup Writer Failed",
          details: nil))
      return
    }

    // startWriting should not be called in didOutputSampleBuffer where it can cause state
    // in which isRecording is true but videoWriter.status is .unknown
    // in stopVideoRecording if it is called after startVideoRecording but before
    // didOutputSampleBuffer had chance to call startWriting and lag at start of video
    // https://github.com/flutter/flutter/issues/132016
    // https://github.com/flutter/flutter/issues/151319
    videoWriter?.startWriting()
    isFirstVideoSample = true
    isRecording = true
    isRecordingPaused = false
    videoTimeOffset = CMTime.zero
    audioTimeOffset = CMTime.zero
    videoIsDisconnected = false
    audioIsDisconnected = false
    completion(nil)
  }

  private func setupWriter(forPath path: String) -> Bool {
    setUpCaptureSessionForAudioIfNeeded()

    var error: NSError?
    videoWriter = assetWriterFactory(URL(fileURLWithPath: path), AVFileType.mp4, &error)

    guard let videoWriter = videoWriter else {
      if let error = error {
        reportErrorMessage(error.description)
      }
      return false
    }

    var videoSettings = mediaSettingsAVWrapper.recommendedVideoSettingsForAssetWriter(
      withFileType:
        AVFileType.mp4,
      for: captureVideoOutput
    )

    if mediaSettings.videoBitrate != nil || mediaSettings.framesPerSecond != nil {
      var compressionProperties: [String: Any] = [:]

      if let videoBitrate = mediaSettings.videoBitrate {
        compressionProperties[AVVideoAverageBitRateKey] = videoBitrate
      }

      if let framesPerSecond = mediaSettings.framesPerSecond {
        compressionProperties[AVVideoExpectedSourceFrameRateKey] = framesPerSecond
      }

      videoSettings?[AVVideoCompressionPropertiesKey] = compressionProperties
    }

    let videoWriterInput = mediaSettingsAVWrapper.assetWriterVideoInput(
      withOutputSettings: videoSettings)
    self.videoWriterInput = videoWriterInput

    let sourcePixelBufferAttributes: [String: Any] = [
      kCVPixelBufferPixelFormatTypeKey as String: videoFormat
    ]

    videoAdaptor = inputPixelBufferAdaptorFactory(videoWriterInput, sourcePixelBufferAttributes)

    videoWriterInput.expectsMediaDataInRealTime = true

    // Add the audio input
    if mediaSettings.enableAudio {
      var audioChannelLayout = AudioChannelLayout()
      audioChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Mono

      let audioChannelLayoutData = withUnsafeBytes(of: &audioChannelLayout) { Data($0) }

      var audioSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVChannelLayoutKey: audioChannelLayoutData,
      ]

      if let audioBitrate = mediaSettings.audioBitrate {
        audioSettings[AVEncoderBitRateKey] = audioBitrate
      }

      let newAudioWriterInput = mediaSettingsAVWrapper.assetWriterAudioInput(
        withOutputSettings: audioSettings)
      newAudioWriterInput.expectsMediaDataInRealTime = true
      mediaSettingsAVWrapper.addInput(newAudioWriterInput, to: videoWriter)
      self.audioWriterInput = newAudioWriterInput
      audioOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
    }

    if flashMode == .torch {
      try? captureDevice.lockForConfiguration()
      captureDevice.torchMode = .on
      captureDevice.unlockForConfiguration()
    }

    mediaSettingsAVWrapper.addInput(videoWriterInput, to: videoWriter)

    captureVideoOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)

    return true
  }

  func pauseVideoRecording() {
    isRecordingPaused = true
    videoIsDisconnected = true
    audioIsDisconnected = true
  }

  func resumeVideoRecording() {
    isRecordingPaused = false
  }

  func stopVideoRecording(completion: @escaping (String?, FlutterError?) -> Void) {
    guard isRecording else {
      let error = NSError(
        domain: NSCocoaErrorDomain,
        code: URLError.resourceUnavailable.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Video is not recording!"]
      )
      completion(nil, DefaultCamera.flutterErrorFromNSError(error))
      return
    }

    isRecording = false

    // When `isRecording` is true `startWriting` was already called so `videoWriter.status`
    // is always either `.writing` or `.failed` and `finishWriting` does not throw exceptions so
    // there is no need to check `videoWriter.status`
    videoWriter?.finishWriting { [weak self] in
      guard let strongSelf = self else { return }

      if strongSelf.videoWriter?.status == .completed {
        strongSelf.updateOrientation()
        completion(strongSelf.videoRecordingPath, nil)
        strongSelf.videoRecordingPath = nil
      } else {
        completion(
          nil,
          FlutterError(
            code: "IOError",
            message: "AVAssetWriter could not finish writing!",
            details: nil))
      }
    }
  }

  func captureToFile(completion: @escaping (String?, FlutterError?) -> Void) {
    var settings = AVCapturePhotoSettings()

    if mediaSettings.resolutionPreset == .max {
      settings.isHighResolutionPhotoEnabled = true
    }

    let fileExtension: String

    let isHEVCCodecAvailable = capturePhotoOutput.availablePhotoCodecTypes.contains(
      .hevc)

    if fileFormat == .heif, isHEVCCodecAvailable {
      settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
      fileExtension = "heif"
    } else {
      fileExtension = "jpg"
    }

    if flashMode != .torch {
      settings.flashMode = FCPGetAVCaptureFlashModeForPigeonFlashMode(flashMode)
    }

    let path: String
    do {
      path = try getTemporaryFilePath(
        withExtension: fileExtension,
        subfolder: "pictures",
        prefix: "CAP_")
    } catch let error as NSError {
      completion(nil, DefaultCamera.flutterErrorFromNSError(error))
      return
    }

    let savePhotoDelegate = FLTSavePhotoDelegate(
      path: path,
      ioQueue: photoIOQueue,
      completionHandler: { [weak self] path, error in
        guard let strongSelf = self else { return }

        strongSelf.captureSessionQueue.async { [weak self] in
          self?.inProgressSavePhotoDelegates.removeObject(
            forKey: settings.uniqueID)
        }

        if let error = error {
          completion(nil, DefaultCamera.flutterErrorFromNSError(error as NSError))
        } else {
          assert(path != nil, "Path must not be nil if no error.")
          completion(path, nil)
        }
      }
    )

    assert(
      DispatchQueue.getSpecific(key: captureSessionQueueSpecificKey)
        == captureSessionQueueSpecificValue,
      "save photo delegate references must be updated on the capture session queue")
    inProgressSavePhotoDelegates[settings.uniqueID] = savePhotoDelegate
    capturePhotoOutput.capturePhoto(with: settings, delegate: savePhotoDelegate)
  }

  private func getTemporaryFilePath(
    withExtension ext: String,
    subfolder: String,
    prefix: String
  ) throws -> String {
    let documentDirectory = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask)[0]

    let fileDirectory = documentDirectory.appendingPathComponent("camera").appendingPathComponent(
      subfolder)
    let fileName = prefix + UUID().uuidString
    let file = fileDirectory.appendingPathComponent(fileName).appendingPathExtension(ext).path

    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: fileDirectory.path) {
      try fileManager.createDirectory(
        at: fileDirectory,
        withIntermediateDirectories: true,
        attributes: nil)
    }

    return file
  }

  func lockCaptureOrientation(_ pigeonOrientation: FCPPlatformDeviceOrientation) {
    let orientation = FCPGetUIDeviceOrientationForPigeonDeviceOrientation(pigeonOrientation)
    if lockedCaptureOrientation != orientation {
      lockedCaptureOrientation = orientation
      updateOrientation()
    }
  }

  func unlockCaptureOrientation() {
    lockedCaptureOrientation = .unknown
    updateOrientation()
  }

  func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat) {
    self.fileFormat = fileFormat
  }

  func setExposureMode(_ mode: FCPPlatformExposureMode) {
    exposureMode = mode
    applyExposureMode()
  }

  private func applyExposureMode() {
    try? captureDevice.lockForConfiguration()
    switch exposureMode {
    case .locked:
      // AVCaptureExposureMode.autoExpose automatically adjusts the exposure one time, and then locks exposure for the device
      captureDevice.setExposureMode(.autoExpose)
    case .auto:
      if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
        captureDevice.setExposureMode(.continuousAutoExposure)
      } else {
        captureDevice.setExposureMode(.autoExpose)
      }
    @unknown default:
      assertionFailure("Unknown exposure mode")
    }
    captureDevice.unlockForConfiguration()
  }

  func setExposureOffset(_ offset: Double) {
    try? captureDevice.lockForConfiguration()
    captureDevice.setExposureTargetBias(Float(offset), completionHandler: nil)
    captureDevice.unlockForConfiguration()
  }

  func setExposurePoint(
    _ point: FCPPlatformPoint?, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    guard captureDevice.isExposurePointOfInterestSupported else {
      completion(
        FlutterError(
          code: "setExposurePointFailed",
          message: "Device does not have exposure point capabilities",
          details: nil))
      return
    }

    let orientation = UIDevice.current.orientation
    try? captureDevice.lockForConfiguration()
    // A nil point resets to the center.
    let exposurePoint = cgPoint(
      for: point ?? FCPPlatformPoint.makeWith(x: 0.5, y: 0.5), withOrientation: orientation)
    captureDevice.setExposurePointOfInterest(exposurePoint)
    captureDevice.unlockForConfiguration()
    // Retrigger auto exposure
    applyExposureMode()
    completion(nil)
  }

  func setFocusMode(_ mode: FCPPlatformFocusMode) {
    focusMode = mode
    applyFocusMode()
  }

  func setFocusPoint(_ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void) {
    guard captureDevice.isFocusPointOfInterestSupported else {
      completion(
        FlutterError(
          code: "setFocusPointFailed",
          message: "Device does not have focus point capabilities",
          details: nil))
      return
    }

    let orientation = deviceOrientationProvider.orientation()
    try? captureDevice.lockForConfiguration()
    // A nil point resets to the center.
    captureDevice.setFocusPointOfInterest(
      cgPoint(
        for: point ?? .makeWith(x: 0.5, y: 0.5),
        withOrientation: orientation)
    )
    captureDevice.unlockForConfiguration()
    // Retrigger auto focus
    applyFocusMode()
    completion(nil)
  }

  private func applyFocusMode() {
    applyFocusMode(focusMode, onDevice: captureDevice)
  }

  private func applyFocusMode(
    _ focusMode: FCPPlatformFocusMode, onDevice captureDevice: FLTCaptureDevice
  ) {
    try? captureDevice.lockForConfiguration()
    switch focusMode {
    case .locked:
      // AVCaptureFocusMode.autoFocus automatically adjusts the focus one time, and then locks focus
      if captureDevice.isFocusModeSupported(.autoFocus) {
        captureDevice.setFocusMode(.autoFocus)
      }
    case .auto:
      if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
        captureDevice.setFocusMode(.continuousAutoFocus)
      } else if captureDevice.isFocusModeSupported(.autoFocus) {
        captureDevice.setFocusMode(.autoFocus)
      }
    @unknown default:
      assertionFailure("Unknown focus mode")
    }
    captureDevice.unlockForConfiguration()
  }

  private func cgPoint(
    for point: FCPPlatformPoint, withOrientation orientation: UIDeviceOrientation
  )
    -> CGPoint
  {
    var x = point.x
    var y = point.y
    switch orientation {
    case .portrait:  // 90 ccw
      y = 1 - point.x
      x = point.y
    case .portraitUpsideDown:  // 90 cw
      x = 1 - point.y
      y = point.x
    case .landscapeRight:  // 180
      x = 1 - point.x
      y = 1 - point.y
    case .landscapeLeft:
      // No rotation required
      break
    default:
      // No rotation required
      break
    }
    return CGPoint(x: x, y: y)
  }

  func setZoomLevel(_ zoom: CGFloat, withCompletion completion: @escaping (FlutterError?) -> Void) {
    if zoom < captureDevice.minAvailableVideoZoomFactor
      || zoom > captureDevice.maxAvailableVideoZoomFactor
    {
      completion(
        FlutterError(
          code: "ZOOM_ERROR",
          message:
            "Zoom level out of bounds (zoom level should be between \(captureDevice.minAvailableVideoZoomFactor) and \(captureDevice.maxAvailableVideoZoomFactor).",
          details: nil))
      return
    }

    do {
      try captureDevice.lockForConfiguration()
    } catch let error as NSError {
      completion(DefaultCamera.flutterErrorFromNSError(error))
      return
    }

    captureDevice.videoZoomFactor = zoom
    captureDevice.unlockForConfiguration()
    completion(nil)
  }

  func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    switch mode {
    case .torch:
      guard captureDevice.hasTorch else {
        completion(
          FlutterError(
            code: "setFlashModeFailed",
            message: "Device does not support torch mode",
            details: nil)
        )
        return
      }
      guard captureDevice.isTorchAvailable else {
        completion(
          FlutterError(
            code: "setFlashModeFailed",
            message: "Torch mode is currently not available",
            details: nil))
        return
      }
      if captureDevice.torchMode != .on {
        try? captureDevice.lockForConfiguration()
        captureDevice.torchMode = .on
        captureDevice.unlockForConfiguration()
      }
    case .off, .auto, .always:
      guard captureDevice.hasFlash else {
        completion(
          FlutterError(
            code: "setFlashModeFailed",
            message: "Device does not have flash capabilities",
            details: nil))
        return
      }
      let avFlashMode = FCPGetAVCaptureFlashModeForPigeonFlashMode(mode)
      guard capturePhotoOutput.supportedFlashModes.contains(NSNumber(value: avFlashMode.rawValue))
      else {
        completion(
          FlutterError(
            code: "setFlashModeFailed",
            message: "Device does not support this specific flash mode",
            details: nil))
        return
      }
      if captureDevice.torchMode != .off {
        try? captureDevice.lockForConfiguration()
        captureDevice.torchMode = .off
        captureDevice.unlockForConfiguration()
      }
    @unknown default:
      assertionFailure("Unknown flash mode")
    }

    flashMode = mode
    completion(nil)
  }

  func pausePreview() {
    isPreviewPaused = true
  }

  func resumePreview() {
    isPreviewPaused = false
  }

  func setDescriptionWhileRecording(
    _ cameraName: String, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    guard isRecording else {
      completion(
        FlutterError(
          code: "setDescriptionWhileRecordingFailed",
          message: "Device was not recording",
          details: nil))
      return
    }

    captureDevice = captureDeviceFactory(cameraName)

    let oldConnection = captureVideoOutput.connection(withMediaType: .video)

    // Stop video capture from the old output.
    captureVideoOutput.setSampleBufferDelegate(nil, queue: nil)

    // Remove the old video capture connections.
    videoCaptureSession.beginConfiguration()
    videoCaptureSession.removeInput(captureVideoInput)
    videoCaptureSession.removeOutput(captureVideoOutput.avOutput)

    let newConnection: AVCaptureConnection

    do {
      (captureVideoInput, captureVideoOutput, newConnection) = try DefaultCamera.createConnection(
        captureDevice: captureDevice,
        videoFormat: videoFormat,
        captureDeviceInputFactory: captureDeviceInputFactory)

      captureVideoOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
    } catch {
      completion(
        FlutterError(
          code: "VideoError",
          message: "Unable to create video connection",
          details: nil))
      return
    }

    // Keep the same orientation the old connections had.
    if let oldConnection = oldConnection, newConnection.isVideoOrientationSupported {
      newConnection.videoOrientation = oldConnection.videoOrientation
    }

    // Add the new connections to the session.
    if !videoCaptureSession.canAddInput(captureVideoInput) {
      completion(
        FlutterError(
          code: "VideoError",
          message: "Unable to switch video input",
          details: nil))
    }
    videoCaptureSession.addInputWithNoConnections(captureVideoInput)

    if !videoCaptureSession.canAddOutput(captureVideoOutput.avOutput) {
      completion(
        FlutterError(
          code: "VideoError",
          message: "Unable to switch video output",
          details: nil))
    }
    videoCaptureSession.addOutputWithNoConnections(captureVideoOutput.avOutput)

    if !videoCaptureSession.canAddConnection(newConnection) {
      completion(
        FlutterError(
          code: "VideoError",
          message: "Unable to switch video connection",
          details: nil))
    }
    videoCaptureSession.addConnection(newConnection)
    videoCaptureSession.commitConfiguration()

    completion(nil)
  }

  func stopImageStream() {
    if isStreamingImages {
      isStreamingImages = false
      imageStreamHandler = nil
    } else {
      reportErrorMessage("Images from camera are not streaming!")
    }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    if output == captureVideoOutput.avOutput {
      if let newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {

        pixelBufferSynchronizationQueue.sync {
          latestPixelBuffer = newBuffer
        }

        onFrameAvailable?()
      }
    }

    guard CMSampleBufferDataIsReady(sampleBuffer) else {
      reportErrorMessage("sample buffer is not ready. Skipping sample")
      return
    }

    if isStreamingImages {
      if let eventSink = imageStreamHandler?.eventSink,
        streamingPendingFramesCount < maxStreamingPendingFramesCount
      {
        streamingPendingFramesCount += 1

        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        // Must lock base address before accessing the pixel data
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        let imageWidth = CVPixelBufferGetWidth(pixelBuffer)
        let imageHeight = CVPixelBufferGetHeight(pixelBuffer)

        var planes: [[String: Any]] = []

        let isPlanar = CVPixelBufferIsPlanar(pixelBuffer)
        let planeCount = isPlanar ? CVPixelBufferGetPlaneCount(pixelBuffer) : 1

        for i in 0..<planeCount {
          let planeAddress: UnsafeMutableRawPointer?
          let bytesPerRow: Int
          let height: Int
          let width: Int

          if isPlanar {
            planeAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, i)
            bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i)
            height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i)
            width = CVPixelBufferGetWidthOfPlane(pixelBuffer, i)
          } else {
            planeAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            height = CVPixelBufferGetHeight(pixelBuffer)
            width = CVPixelBufferGetWidth(pixelBuffer)
          }

          let length = bytesPerRow * height
          let bytes = Data(bytes: planeAddress!, count: length)

          let planeBuffer: [String: Any] = [
            "bytesPerRow": bytesPerRow,
            "width": width,
            "height": height,
            "bytes": FlutterStandardTypedData(bytes: bytes),
          ]
          planes.append(planeBuffer)
        }

        // Lock the base address before accessing pixel data, and unlock it afterwards.
        // Done accessing the `pixelBuffer` at this point.
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        let imageBuffer: [String: Any] = [
          "width": imageWidth,
          "height": imageHeight,
          "format": videoFormat,
          "planes": planes,
          "lensAperture": Double(captureDevice.lensAperture()),
          "sensorExposureTime": Int(captureDevice.exposureDuration().seconds * 1_000_000_000),
          "sensorSensitivity": Double(captureDevice.iso()),
        ]

        DispatchQueue.main.async {
          eventSink(imageBuffer)
        }
      }
    }

    if isRecording && !isRecordingPaused {
      if videoWriter?.status == .failed, let error = videoWriter?.error {
        reportErrorMessage("\(error)")
        return
      }

      // ignore audio samples until the first video sample arrives to avoid black frames
      // https://github.com/flutter/flutter/issues/57831
      if isFirstVideoSample && output != captureVideoOutput.avOutput {
        return
      }

      var currentSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

      if isFirstVideoSample {
        videoWriter?.startSession(atSourceTime: currentSampleTime)
        // fix sample times not being numeric when pause/resume happens before first sample buffer
        // arrives
        // https://github.com/flutter/flutter/issues/132014
        lastVideoSampleTime = currentSampleTime
        lastAudioSampleTime = currentSampleTime
        isFirstVideoSample = false
      }

      if output == captureVideoOutput.avOutput {
        if videoIsDisconnected {
          videoIsDisconnected = false

          videoTimeOffset =
            videoTimeOffset.value == 0
            ? CMTimeSubtract(currentSampleTime, lastVideoSampleTime)
            : CMTimeAdd(videoTimeOffset, CMTimeSubtract(currentSampleTime, lastVideoSampleTime))

          return
        }

        lastVideoSampleTime = currentSampleTime

        let nextBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let nextSampleTime = CMTimeSubtract(lastVideoSampleTime, videoTimeOffset)
        // do not append sample buffer when readyForMoreMediaData is NO to avoid crash
        // https://github.com/flutter/flutter/issues/132073
        if videoWriterInput?.readyForMoreMediaData ?? false {
          videoAdaptor?.append(nextBuffer!, withPresentationTime: nextSampleTime)
        }
      } else {
        let dur = CMSampleBufferGetDuration(sampleBuffer)

        if dur.value > 0 {
          currentSampleTime = CMTimeAdd(currentSampleTime, dur)
        }

        if audioIsDisconnected {
          audioIsDisconnected = false

          audioTimeOffset =
            audioTimeOffset.value == 0
            ? CMTimeSubtract(currentSampleTime, lastAudioSampleTime)
            : CMTimeAdd(audioTimeOffset, CMTimeSubtract(currentSampleTime, lastAudioSampleTime))

          return
        }

        lastAudioSampleTime = currentSampleTime

        if audioTimeOffset.value != 0 {
          if let adjustedSampleBuffer = copySampleBufferWithAdjustedTime(
            sampleBuffer,
            by: audioTimeOffset)
          {
            newAudioSample(adjustedSampleBuffer)
          }
        } else {
          newAudioSample(sampleBuffer)
        }
      }
    }
  }

  private func copySampleBufferWithAdjustedTime(_ sample: CMSampleBuffer, by offset: CMTime)
    -> CMSampleBuffer?
  {
    var count: CMItemCount = 0
    CMSampleBufferGetSampleTimingInfoArray(
      sample, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count)

    let timingInfo = UnsafeMutablePointer<CMSampleTimingInfo>.allocate(capacity: Int(count))
    defer { timingInfo.deallocate() }

    CMSampleBufferGetSampleTimingInfoArray(
      sample, entryCount: count, arrayToFill: timingInfo, entriesNeededOut: &count)

    for i in 0..<count {
      timingInfo[Int(i)].decodeTimeStamp = CMTimeSubtract(
        timingInfo[Int(i)].decodeTimeStamp, offset)
      timingInfo[Int(i)].presentationTimeStamp = CMTimeSubtract(
        timingInfo[Int(i)].presentationTimeStamp, offset)
    }

    var adjustedSampleBuffer: CMSampleBuffer?
    CMSampleBufferCreateCopyWithNewTiming(
      allocator: nil,
      sampleBuffer: sample,
      sampleTimingEntryCount: count,
      sampleTimingArray: timingInfo,
      sampleBufferOut: &adjustedSampleBuffer)

    return adjustedSampleBuffer
  }

  private func newAudioSample(_ sampleBuffer: CMSampleBuffer) {
    guard videoWriter?.status == .writing else {
      if videoWriter?.status == .failed, let error = videoWriter?.error {
        reportErrorMessage("\(error)")
      }
      return
    }
    if audioWriterInput?.readyForMoreMediaData ?? false {
      if !(audioWriterInput?.append(sampleBuffer) ?? false) {
        reportErrorMessage("Unable to write to audio input")
      }
    }
  }

  func close() {
    stop()
    for input in videoCaptureSession.inputs {
      videoCaptureSession.removeInput(FLTDefaultCaptureInput(input: input))
    }
    for output in videoCaptureSession.outputs {
      videoCaptureSession.removeOutput(output)
    }
    for input in audioCaptureSession.inputs {
      audioCaptureSession.removeInput(FLTDefaultCaptureInput(input: input))
    }
    for output in audioCaptureSession.outputs {
      audioCaptureSession.removeOutput(output)
    }
  }

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    var pixelBuffer: CVPixelBuffer?
    pixelBufferSynchronizationQueue.sync {
      pixelBuffer = latestPixelBuffer
      latestPixelBuffer = nil
    }

    if let buffer = pixelBuffer {
      return Unmanaged.passRetained(buffer)
    } else {
      return nil
    }
  }

  private func reportErrorMessage(_ errorMessage: String) {
    FLTEnsureToRunOnMainQueue { [weak self] in
      self?.dartAPI?.reportError(errorMessage) { _ in
        // Ignore any errors, as this is just an event broadcast.
      }
    }
  }

  deinit {
    motionManager.stopAccelerometerUpdates()
  }
}
