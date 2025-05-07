// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMotion
import Flutter

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A class that manages camera's state and performs camera operations.
protocol FLTCam: FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate,
  AVCaptureAudioDataOutputSampleBufferDelegate
{
  /// The API instance used to communicate with the Dart side of the plugin.
  /// Once initially set, this should only ever be accessed on the main thread.
  var dartAPI: FCPCameraEventApi? { get set }

  var onFrameAvailable: (() -> Void)? { get set }

  /// Format used for video and image streaming.
  var videoFormat: FourCharCode { get set }

  var isPreviewPaused: Bool { get }

  var minimumAvailableZoomFactor: CGFloat { get }
  var maximumAvailableZoomFactor: CGFloat { get }
  var minimumExposureOffset: CGFloat { get }
  var maximumExposureOffset: CGFloat { get }

  func setUpCaptureSessionForAudioIfNeeded()

  func reportInitializationState()

  /// Acknowledges the receipt of one image stream frame.
  func receivedImageStreamData()

  func start()
  func stop()

  /// Starts recording a video with an optional streaming messenger.
  func startVideoRecording(
    completion: @escaping (_ error: FlutterError?) -> Void,
    messengerForStreaming: FlutterBinaryMessenger?
  )
  func pauseVideoRecording()
  func resumeVideoRecording()
  func stopVideoRecording(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func captureToFile(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func setDeviceOrientation(_ orientation: UIDeviceOrientation)
  func lockCaptureOrientation(_ orientation: FCPPlatformDeviceOrientation)
  func unlockCaptureOrientation()

  func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat)

  func setExposureMode(_ mode: FCPPlatformExposureMode)
  func setExposureOffset(_ offset: Double)
  func setExposurePoint(
    _ point: FCPPlatformPoint?,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func setFocusMode(_ mode: FCPPlatformFocusMode)
  func setFocusPoint(
    _ point: FCPPlatformPoint?,
    completion: @escaping (_ error: FlutterError?) -> Void
  )

  func setZoomLevel(_ zoom: CGFloat, withCompletion: @escaping (_ error: FlutterError?) -> Void)

  func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func pausePreview()
  func resumePreview()

  func setDescriptionWhileRecording(
    _ cameraName: String,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func startImageStream(with: FlutterBinaryMessenger)
  func stopImageStream()

  // Override to make `AVCaptureVideoDataOutputSampleBufferDelegate`/
  // `AVCaptureAudioDataOutputSampleBufferDelegate` method non optional
  override func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  )

  func close()
}

class FLTDefaultCam: NSObject, FLTCam {
  var dartAPI: FCPCameraEventApi?
  var onFrameAvailable: (() -> Void)?

  var videoFormat: FourCharCode = kCVPixelFormatType_32BGRA {
    didSet {
      captureVideoOutput.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: videoFormat)
      ]
    }
  }

  private(set) var isPreviewPaused = false

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

  /// All FLTCam's state access and capture session related operations should be run on this queue.
  private let captureSessionQueue: DispatchQueue

  private let mediaSettings: FCPPlatformMediaSettings
  private let mediaSettingsAVWrapper: FLTCamMediaSettingsAVWrapper

  private let videoCaptureSession: FLTCaptureSession
  private let audioCaptureSession: FLTCaptureSession

  /// A wrapper for AVCaptureDevice creation to allow for dependency injection in tests.
  private let captureDeviceFactory: CaptureDeviceFactory
  private let audioCaptureDeviceFactory: AudioCaptureDeviceFactory
  private let captureDeviceInputFactory: FLTCaptureDeviceInputFactory
  private let assetWriterFactory: AssetWriterFactory
  private let inputPixelBufferAdaptorFactory: InputPixelBufferAdaptorFactory

  /// A wrapper for CMVideoFormatDescriptionGetDimensions.
  /// Allows for alternate implementations in tests.
  private let videoDimensionsForFormat: VideoDimensionsForFormat

  private let deviceOrientationProvider: FLTDeviceOrientationProviding
  private let motionManager = CMMotionManager()

  private(set) var captureDevice: FLTCaptureDevice
  // Setter exposed for tests.
  var captureVideoOutput: FLTCaptureVideoDataOutput
  // Setter exposed for tests.
  var capturePhotoOutput: FLTCapturePhotoOutput
  private var captureVideoInput: FLTCaptureInput

  private var videoWriter: FLTAssetWriter?
  private var videoWriterInput: FLTAssetWriterInput?
  private var audioWriterInput: FLTAssetWriterInput?
  private var assetWriterPixelBufferAdaptor: FLTAssetWriterInputPixelBufferAdaptor?
  private var videoAdaptor: FLTAssetWriterInputPixelBufferAdaptor?

  /// A dictionary to retain all in-progress FLTSavePhotoDelegates. The key of the dictionary is the
  /// AVCapturePhotoSettings's uniqueID for each photo capture operation, and the value is the
  /// FLTSavePhotoDelegate that handles the result of each photo capture operation. Note that photo
  /// capture operations may overlap, so FLTCam has to keep track of multiple delegates in progress,
  /// instead of just a single delegate reference.
  private(set) var inProgressSavePhotoDelegates = [Int64: FLTSavePhotoDelegate]()

  private var imageStreamHandler: FLTImageStreamHandler?

  private var textureId: Int64?
  private var previewSize: CGSize?
  private var deviceOrientation = UIDeviceOrientation.unknown

  /// Tracks the latest pixel buffer sent from AVFoundation's sample buffer delegate callback.
  /// Used to deliver the latest pixel buffer to the flutter engine via the `copyPixelBuffer` API.
  private var latestPixelBuffer: CVPixelBuffer?

  private var videoRecordingPath: String?
  private var isRecording = false
  private var isRecordingPaused = false
  private var isFirstVideoSample = false
  private var videoIsDisconnected = false
  private var audioIsDisconnected = false
  private var isAudioSetup = false
  private var lastVideoSampleTime = CMTime.zero
  private var lastAudioSampleTime = CMTime.zero
  private var videoTimeOffset = CMTime.zero
  private var audioTimeOffset = CMTime.zero

  /// True when images from the camera are being streamed.
  private(set) var isStreamingImages = false

  /// Number of frames currently pending processing.
  private var streamingPendingFramesCount = 0

  /// Maximum number of frames pending processing.
  /// To limit memory consumption, limit the number of frames pending processing.
  /// After some testing, 4 was determined to be the best maximuńm value.
  /// https://github.com/flutter/plugins/pull/4520#discussion_r766335637
  private var maxStreamingPendingFramesCount = 4

  private var fileFormat = FCPPlatformImageFileFormat.jpeg
  private var lockedCaptureOrientation = UIDeviceOrientation.unknown
  private var exposureMode = FCPPlatformExposureMode.auto
  private var focusMode = FCPPlatformFocusMode.auto
  private var flashMode: FCPPlatformFlashMode

  private static func flutterErrorFromNSError(_ error: NSError) -> FlutterError {
    return FlutterError(
      code: "Error \(error.code)",
      message: error.localizedDescription,
      details: error.domain)
  }

  // Returns frame rate supported by format closest to targetFrameRate.
  private static func bestFrameRate(for format: FLTCaptureDeviceFormat, targetFrameRate: Double)
    -> Double
  {
    var bestFrameRate = 0.0
    var minDistance = Double.greatestFiniteMagnitude
    for range in format.videoSupportedFrameRateRanges {
      let frameRate = min(
        max(targetFrameRate, Double(range.minFrameRate)), Double(range.maxFrameRate))
      let distance = abs(frameRate - targetFrameRate)
      if distance < minDistance {
        bestFrameRate = frameRate
        minDistance = distance
      }
    }
    return bestFrameRate
  }

  // Finds format with same resolution as current activeFormat in captureDevice for which
  // bestFrameRateForFormat returned frame rate closest to mediaSettings.framesPerSecond.
  // Preferred are formats with the same subtype as current activeFormat. Sets this format
  // as activeFormat and also updates mediaSettings.framesPerSecond to value which
  // bestFrameRateForFormat returned for that format.
  private static func selectBestFormatForRequestedFrameRate(
    captureDevice: FLTCaptureDevice,
    mediaSettings: FCPPlatformMediaSettings,
    targetFrameRate: Double,
    videoDimensionsForFormat: (FLTCaptureDeviceFormat) -> CMVideoDimensions
  ) {
    let targetResolution = videoDimensionsForFormat(captureDevice.activeFormat)
    let preferredSubType = CMFormatDescriptionGetMediaSubType(
      captureDevice.activeFormat.formatDescription)
    var bestFormat = captureDevice.activeFormat
    var _bestFrameRate = bestFrameRate(for: bestFormat, targetFrameRate: targetFrameRate)
    var minDistance = abs(_bestFrameRate - targetFrameRate)
    var isBestSubTypePreferred = true

    for format in captureDevice.formats {
      let resolution = videoDimensionsForFormat(format)
      if resolution.width != targetResolution.width || resolution.height != targetResolution.height
      {
        continue
      }
      let frameRate = bestFrameRate(for: format, targetFrameRate: targetFrameRate)
      let distance = abs(frameRate - targetFrameRate)
      let subType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
      let isSubTypePreferred = subType == preferredSubType
      if distance < minDistance
        || (distance == minDistance && isSubTypePreferred && !isBestSubTypePreferred)
      {
        bestFormat = format
        _bestFrameRate = frameRate
        minDistance = distance
        isBestSubTypePreferred = isSubTypePreferred
      }
    }
    captureDevice.activeFormat = bestFormat
    mediaSettings.framesPerSecond = NSNumber(value: _bestFrameRate)
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
      kCVPixelBufferPixelFormatTypeKey as String: videoFormat as Any
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

  init(configuration: FLTCamConfiguration) throws {
    captureSessionQueue = configuration.captureSessionQueue
    mediaSettings = configuration.mediaSettings
    mediaSettingsAVWrapper = configuration.mediaSettingsWrapper
    videoCaptureSession = configuration.videoCaptureSession
    audioCaptureSession = configuration.audioCaptureSession
    captureDeviceFactory = configuration.captureDeviceFactory
    audioCaptureDeviceFactory = configuration.audioCaptureDeviceFactory
    captureDeviceInputFactory = configuration.captureDeviceInputFactory
    assetWriterFactory = configuration.assetWriterFactory
    inputPixelBufferAdaptorFactory = configuration.inputPixelBufferAdaptorFactory
    videoDimensionsForFormat = configuration.videoDimensionsForFormat
    deviceOrientationProvider = configuration.deviceOrientationProvider

    captureDevice = captureDeviceFactory(configuration.initialCameraName)
    flashMode = captureDevice.hasFlash ? .auto : .off

    capturePhotoOutput = FLTDefaultCapturePhotoOutput(photoOutput: AVCapturePhotoOutput())
    capturePhotoOutput.highResolutionCaptureEnabled = true

    videoCaptureSession.automaticallyConfiguresApplicationAudioSession = false
    audioCaptureSession.automaticallyConfiguresApplicationAudioSession = false

    deviceOrientation = configuration.orientation

    let connection: AVCaptureConnection
    (captureVideoInput, captureVideoOutput, connection) = try FLTDefaultCam.createConnection(
      captureDevice: captureDevice,
      videoFormat: videoFormat,
      captureDeviceInputFactory: configuration.captureDeviceInputFactory)

    super.init()

    captureVideoOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)

    videoCaptureSession.addInputWithNoConnections(captureVideoInput)
    videoCaptureSession.addOutputWithNoConnections(captureVideoOutput.avOutput)
    videoCaptureSession.addConnection(connection)

    videoCaptureSession.addOutput(capturePhotoOutput.avOutput)

    motionManager.startAccelerometerUpdates()

    if let targetFrameRate = mediaSettings.framesPerSecond {
      // The frame rate can be changed only on a locked for configuration device.
      try mediaSettingsAVWrapper.lockDevice(captureDevice)
      mediaSettingsAVWrapper.beginConfiguration(for: videoCaptureSession)

      // Possible values for presets are hard-coded in FLT interface having
      // corresponding AVCaptureSessionPreset counterparts.
      // If _resolutionPreset is not supported by camera there is
      // fallback to lower resolution presets.
      // If none can be selected there is error condition.
      do {
        try setCaptureSessionPreset(mediaSettings.resolutionPreset)
      } catch {
        videoCaptureSession.commitConfiguration()
        captureDevice.unlockForConfiguration()
        throw error
      }

      FLTDefaultCam.selectBestFormatForRequestedFrameRate(
        captureDevice: captureDevice,
        mediaSettings: mediaSettings,
        targetFrameRate: targetFrameRate.doubleValue,
        videoDimensionsForFormat: videoDimensionsForFormat
      )

      if let framesPerSecond = mediaSettings.framesPerSecond {
        // Set frame rate with 1/10 precision allowing non-integral values.
        let fpsNominator = floor(framesPerSecond.doubleValue * 10.0)
        let duration = CMTimeMake(value: 10, timescale: Int32(fpsNominator))

        mediaSettingsAVWrapper.setMinFrameDuration(duration, on: captureDevice)
        mediaSettingsAVWrapper.setMaxFrameDuration(duration, on: captureDevice)
      }

      mediaSettingsAVWrapper.commitConfiguration(for: videoCaptureSession)
      mediaSettingsAVWrapper.unlockDevice(captureDevice)
    } else {
      // If the frame rate is not important fall to a less restrictive
      // behavior (no configuration locking).
      try setCaptureSessionPreset(mediaSettings.resolutionPreset)
    }

    updateOrientation()
  }

  private func setCaptureSessionPreset(
    _ resolutionPreset: FCPPlatformResolutionPreset
  ) throws {
    switch resolutionPreset {
    case .max:
      if let bestFormat = highestResolutionFormat(forCaptureDevice: captureDevice) {
        videoCaptureSession.sessionPreset = .inputPriority
        if (try? captureDevice.lockForConfiguration()) != nil {
          // Set the best device format found and finish the device configuration.
          captureDevice.activeFormat = bestFormat
          captureDevice.unlockForConfiguration()
          break
        }
      }
      fallthrough
    case .ultraHigh:
      if videoCaptureSession.canSetSessionPreset(.hd4K3840x2160) {
        videoCaptureSession.sessionPreset = .hd4K3840x2160
        break
      }
      if videoCaptureSession.canSetSessionPreset(.high) {
        videoCaptureSession.sessionPreset = .high
        break
      }
      fallthrough
    case .veryHigh:
      if videoCaptureSession.canSetSessionPreset(.hd1920x1080) {
        videoCaptureSession.sessionPreset = .hd1920x1080
        break
      }
      fallthrough
    case .high:
      if videoCaptureSession.canSetSessionPreset(.hd1280x720) {
        videoCaptureSession.sessionPreset = .hd1280x720
        break
      }
      fallthrough
    case .medium:
      if videoCaptureSession.canSetSessionPreset(.vga640x480) {
        videoCaptureSession.sessionPreset = .vga640x480
        break
      }
      fallthrough
    case .low:
      if videoCaptureSession.canSetSessionPreset(.cif352x288) {
        videoCaptureSession.sessionPreset = .cif352x288
        break
      }
      fallthrough
    default:
      if videoCaptureSession.canSetSessionPreset(.low) {
        videoCaptureSession.sessionPreset = .low
      } else {
        throw NSError(
          domain: NSCocoaErrorDomain,
          code: URLError.unknown.rawValue,
          userInfo: [
            NSLocalizedDescriptionKey: "No capture session available for current capture session."
          ])
      }
    }

    let size = videoDimensionsForFormat(captureDevice.activeFormat)
    previewSize = CGSize(width: CGFloat(size.width), height: CGFloat(size.height))
    audioCaptureSession.sessionPreset = videoCaptureSession.sessionPreset
  }

  /// Finds the highest available resolution in terms of pixel count for the given device.
  /// Preferred are formats with the same subtype as current activeFormat.
  private func highestResolutionFormat(forCaptureDevice captureDevice: FLTCaptureDevice)
    -> FLTCaptureDeviceFormat?
  {
    let preferredSubType = CMFormatDescriptionGetMediaSubType(
      captureDevice.activeFormat.formatDescription)
    var bestFormat: FLTCaptureDeviceFormat? = nil
    var maxPixelCount: UInt = 0
    var isBestSubTypePreferred = false

    for format in captureDevice.formats {
      let resolution = videoDimensionsForFormat(format)
      let height = UInt(resolution.height)
      let width = UInt(resolution.width)
      let pixelCount = height * width
      let subType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
      let isSubTypePreferred = subType == preferredSubType

      if pixelCount > maxPixelCount
        || (pixelCount == maxPixelCount && isSubTypePreferred && !isBestSubTypePreferred)
      {
        bestFormat = format
        maxPixelCount = pixelCount
        isBestSubTypePreferred = isSubTypePreferred
      }
    }

    return bestFormat
  }

  func setUpCaptureSessionForAudioIfNeeded() {
    // Don't setup audio twice or we will lose the audio.
    guard !mediaSettings.enableAudio || !isAudioSetup else { return }

    let audioDevice = audioCaptureDeviceFactory()
    do {
      // Create a device input with the device and add it to the session.
      // Setup the audio input.
      let audioInput = try captureDeviceInputFactory.deviceInput(with: audioDevice)

      // Setup the audio output.
      let audioOutput = AVCaptureAudioDataOutput()

      let block = {
        // Set up options implicit to AVAudioSessionCategoryPlayback to avoid conflicts with other
        // plugins like video_player.
        FLTDefaultCam.upgradeAudioSessionCategory(
          requestedCategory: .playAndRecord,
          options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay]
        )
      }

      if !Thread.isMainThread {
        DispatchQueue.main.sync(execute: block)
      } else {
        block()
      }

      if audioCaptureSession.canAddInput(audioInput) {
        audioCaptureSession.addInput(audioInput)

        if audioCaptureSession.canAddOutput(audioOutput) {
          audioCaptureSession.addOutput(audioOutput)
          audioOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
          isAudioSetup = true
        } else {
          reportErrorMessage("Unable to add Audio input/output to session capture")
          isAudioSetup = false
        }
      }
    } catch let error as NSError {
      reportErrorMessage(error.description)
    }
  }

  // This function, although slightly modified, is also in video_player_avfoundation.
  // Both need to do the same thing and run on the same thread (for example main thread).
  // Configure application wide audio session manually to prevent overwriting flag
  // MixWithOthers by capture session.
  // Only change category if it is considered an upgrade which means it can only enable
  // ability to play in silent mode or ability to record audio but never disables it,
  // that could affect other plugins which depend on this global state. Only change
  // category or options if there is change to prevent unnecessary lags and silence.
  private static func upgradeAudioSessionCategory(
    requestedCategory: AVAudioSession.Category,
    options: AVAudioSession.CategoryOptions
  ) {
    let playCategories: Set<AVAudioSession.Category> = [.playback, .playAndRecord]
    let recordCategories: Set<AVAudioSession.Category> = [.record, .playAndRecord]
    let requiredCategories: Set<AVAudioSession.Category> = [
      requestedCategory, AVAudioSession.sharedInstance().category,
    ]

    let requiresPlay = !requiredCategories.isDisjoint(with: playCategories)
    let requiresRecord = !requiredCategories.isDisjoint(with: recordCategories)

    var finalCategory = requestedCategory
    if requiresPlay && requiresRecord {
      finalCategory = .playAndRecord
    } else if requiresPlay {
      finalCategory = .playback
    } else if requiresRecord {
      finalCategory = .record
    }

    let finalOptions = AVAudioSession.sharedInstance().categoryOptions.union(options)

    if finalCategory == AVAudioSession.sharedInstance().category
      && finalOptions == AVAudioSession.sharedInstance().categoryOptions
    {
      return
    }

    try? AVAudioSession.sharedInstance().setCategory(finalCategory, options: finalOptions)
  }

  func reportInitializationState() {
    // Get all the state on the current thread, not the main thread.
    let state = FCPPlatformCameraState.make(
      withPreviewSize: FCPPlatformSize.make(
        withWidth: Double(previewSize!.width),
        height: Double(previewSize!.height)
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
      startImageStream(with: messenger)
    }

    let videoRecordingPath: String
    do {
      videoRecordingPath = try getTemporaryFilePath(
        withExtension: "mp4",
        subfolder: "videos",
        prefix: "REC_")
      self.videoRecordingPath = videoRecordingPath
    } catch let error as NSError {
      completion(FLTDefaultCam.flutterErrorFromNSError(error))
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
    // in which _isRecording is YES but _videoWriter.status is AVAssetWriterStatusUnknown
    // in stopVideoRecording if it is called after startVideoRecording but before
    // didOutputSampleBuffer had chance to call startWriting and lag at start of video
    // https://github.com/flutter/flutter/issues/132016
    // https://github.com/flutter/flutter/issues/151319
    videoWriter?.startWriting()
    isFirstVideoSample = true
    isRecording = true
    isRecordingPaused = false
    videoTimeOffset = CMTimeMake(value: 0, timescale: 1)
    audioTimeOffset = CMTimeMake(value: 0, timescale: 1)
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
      var acl = AudioChannelLayout()
      acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono

      let aclSize = MemoryLayout.size(ofValue: acl)
      let aclData = Data(bytes: &acl, count: aclSize)

      var audioSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVChannelLayoutKey: aclData,
      ]

      if let audioBitrate = mediaSettings.audioBitrate {
        audioSettings[AVEncoderBitRateKey] = audioBitrate
      }

      let newAudioWriterInput = mediaSettingsAVWrapper.assetWriterAudioInput(
        withOutputSettings: audioSettings)
      newAudioWriterInput.expectsMediaDataInRealTime = true
      mediaSettingsAVWrapper.addInput(newAudioWriterInput, to: videoWriter)
      self.audioWriterInput = newAudioWriterInput
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
    if isRecording {
      isRecording = false

      // When `isRecording` is true, `startWriting` was already called, so `videoWriter.status`
      // is always either `.writing` or `.failed`. `finishWriting` does not throw exceptions,
      // so there is no need to check `videoWriter.status` beforehand.
      videoWriter?.finishWriting {
        if self.videoWriter?.status == .completed {
          self.updateOrientation()
          completion(self.videoRecordingPath, nil)
          self.videoRecordingPath = nil
        } else {
          completion(
            nil,
            FlutterError(
              code: "IOError",
              message: "AVAssetWriter could not finish writing!",
              details: nil))
        }
      }
    } else {
      let error = NSError(
        domain: NSCocoaErrorDomain,
        code: URLError.resourceUnavailable.rawValue,
        userInfo: [NSLocalizedDescriptionKey: "Video is not recording!"]
      )
      completion(nil, FLTDefaultCam.flutterErrorFromNSError(error))
    }
  }

  func captureToFile(completion: @escaping (String?, FlutterError?) -> Void) {
    var settings = AVCapturePhotoSettings()

    if mediaSettings.resolutionPreset == .max {
      settings.isHighResolutionPhotoEnabled = true
    }

    var fileExtension: String

    let isHEVCCodecAvailable = capturePhotoOutput.availablePhotoCodecTypes.contains(
      AVVideoCodecType.hevc)

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
      completion(nil, FLTDefaultCam.flutterErrorFromNSError(error))
      return
    }

    let savePhotoDelegate = FLTSavePhotoDelegate(
      path: path,
      ioQueue: photoIOQueue,
      completionHandler: { [weak self] path, error in
        guard let strongSelf = self else { return }

        strongSelf.captureSessionQueue.async {
          if let strongSelf = self {
            strongSelf.inProgressSavePhotoDelegates.removeValue(
              forKey: settings.uniqueID)
          }
        }

        if let error = error {
          completion(nil, FLTDefaultCam.flutterErrorFromNSError(error as NSError))
        } else {
          assert(path != nil, "Path must not be nil if no error.")
          completion(path, nil)
        }
      }
    )

    assert(
      DispatchQueue.getSpecific(key: fltCaptureSessionQueueSpecificKey)
        == fltCaptureSessionQueueSpecificValue,
      "save photo delegate references must be updated on the capture session queue")
    inProgressSavePhotoDelegates[settings.uniqueID] = savePhotoDelegate
    capturePhotoOutput.capturePhoto(with: settings, delegate: savePhotoDelegate)

  }

  private func getTemporaryFilePath(withExtension ext: String, subfolder: String, prefix: String)
    throws
    -> String
  {
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileDir = docDir.appendingPathComponent("camera").appendingPathComponent(subfolder)
    let fileName = prefix + UUID().uuidString
    let file = fileDir.appendingPathComponent(fileName).appendingPathExtension(ext).path

    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: fileDir.path) {
      try fileManager.createDirectory(
        at: fileDir,
        withIntermediateDirectories: true,
        attributes: nil)
    }

    return file
  }

  func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
    if deviceOrientation == orientation {
      return
    }

    deviceOrientation = orientation
    updateOrientation()
  }

  private func updateOrientation() {
    guard !isRecording else { return }

    let orientation: UIDeviceOrientation =
      (lockedCaptureOrientation != .unknown)
      ? lockedCaptureOrientation
      : deviceOrientation

    updateOrientation(orientation, forCaptureOutput: capturePhotoOutput)
    updateOrientation(orientation, forCaptureOutput: captureVideoOutput)
  }

  private func updateOrientation(
    _ orientation: UIDeviceOrientation, forCaptureOutput captureOutput: FLTCaptureOutput
  ) {
    if let connection = captureOutput.connection(withMediaType: .video),
      connection.isVideoOrientationSupported
    {
      connection.videoOrientation = getVideoOrientation(forDeviceOrientation: orientation)
    }
  }

  private func getVideoOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation)
    -> AVCaptureVideoOrientation
  {
    switch deviceOrientation {
    case .portrait:
      return .portrait
    case .landscapeLeft:
      return .landscapeRight
    case .landscapeRight:
      return .landscapeLeft
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return .portrait
    }
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
      cgPoint(for: point ?? FCPPlatformPoint.makeWith(x: 0.5, y: 0.5), withOrientation: orientation)
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
      completion(FLTDefaultCam.flutterErrorFromNSError(error))
      return
    }

    captureDevice.videoZoomFactor = zoom
    captureDevice.unlockForConfiguration()
    completion(nil)
  }

  func setFlashMode(
    _ mode: FCPPlatformFlashMode, withCompletion completion: @escaping (FlutterError?) -> Void
  ) {
    if mode == .torch {
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
    } else {
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
      (captureVideoInput, captureVideoOutput, newConnection) = try FLTDefaultCam.createConnection(
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

  func startImageStream(with messenger: FlutterBinaryMessenger) {
    startImageStream(
      with: messenger,
      imageStreamHandler: FLTImageStreamHandler(captureSessionQueue: captureSessionQueue)
    )
  }

  func startImageStream(
    with messenger: FlutterBinaryMessenger,
    imageStreamHandler: FLTImageStreamHandler
  ) {
    if isStreamingImages {
      reportErrorMessage("Images from camera are already streaming!")
      return
    }

    let eventChannel = FlutterEventChannel(
      name: "plugins.flutter.io/camera_avfoundation/imageStream",
      binaryMessenger: messenger
    )
    let threadSafeEventChannel = FLTThreadSafeEventChannel(eventChannel: eventChannel)

    self.imageStreamHandler = imageStreamHandler
    threadSafeEventChannel.setStreamHandler(imageStreamHandler) { [weak self] in
      guard let strongSelf = self else { return }

      strongSelf.captureSessionQueue.async { [weak self] in
        guard let strongSelf = self else { return }

        strongSelf.isStreamingImages = true
        strongSelf.streamingPendingFramesCount = 0
      }
    }
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
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    captureOutput(output, didOutput: sampleBuffer)
  }

  func captureOutput(_ output: AVCaptureOutput?, didOutput sampleBuffer: CMSampleBuffer) {
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
          "lensAperture": captureDevice.lensAperture,
          "sensorExposureTime": NSNumber(
            value: captureDevice.exposureDuration().seconds * 1_000_000_000),
          "sensorSensitivity": NSNumber(value: captureDevice.iso()),
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
