// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import ObjectiveC

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

public final class CameraPlugin: NSObject, FlutterPlugin {
  private let registry: FlutterTextureRegistry
  private let messenger: FlutterBinaryMessenger
  private let globalEventAPI: FCPCameraGlobalEventApi
  private let deviceDiscoverer: CameraDeviceDiscoverer
  private let permissionManager: CameraPermissionManager
  private let captureDeviceFactory: VideoCaptureDeviceFactory
  private let captureSessionFactory: CaptureSessionFactory
  private let captureDeviceInputFactory: CaptureDeviceInputFactory

  /// All FLTCam's state access and capture session related operations should be on run on this queue.
  private let captureSessionQueue: DispatchQueue

  /// An internal camera object that manages camera's state and performs camera operations.
  var camera: Camera?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CameraPlugin(
      registry: registrar.textures(),
      messenger: registrar.messenger(),
      globalAPI: FCPCameraGlobalEventApi(binaryMessenger: registrar.messenger()),
      deviceDiscoverer: DefaultCameraDeviceDiscoverer(),
      permissionManager: CameraPermissionManager(
        permissionService: DefaultPermissionService()),
      deviceFactory: { name in
        // TODO(RobertOdrowaz) Implement better error handling and remove non-null assertion
        AVCaptureDevice(uniqueID: name)!
      },
      captureSessionFactory: { AVCaptureSession() },
      captureDeviceInputFactory: DefaultCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )

    SetUpFCPCameraApi(registrar.messenger(), instance)
  }

  init(
    registry: FlutterTextureRegistry,
    messenger: FlutterBinaryMessenger,
    globalAPI: FCPCameraGlobalEventApi,
    deviceDiscoverer: CameraDeviceDiscoverer,
    permissionManager: CameraPermissionManager,
    deviceFactory: @escaping VideoCaptureDeviceFactory,
    captureSessionFactory: @escaping CaptureSessionFactory,
    captureDeviceInputFactory: CaptureDeviceInputFactory,
    captureSessionQueue: DispatchQueue
  ) {
    self.registry = registry
    self.messenger = messenger
    self.globalEventAPI = globalAPI
    self.deviceDiscoverer = deviceDiscoverer
    self.permissionManager = permissionManager
    self.captureDeviceFactory = deviceFactory
    self.captureSessionFactory = captureSessionFactory
    self.captureDeviceInputFactory = captureDeviceInputFactory
    self.captureSessionQueue = captureSessionQueue

    super.init()

    captureSessionQueue.setSpecific(
      key: captureSessionQueueSpecificKey, value: captureSessionQueueSpecificValue)

    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(
      forName: UIDevice.orientationDidChangeNotification,
      object: UIDevice.current,
      queue: .main
    ) { [weak self] notification in
      self?.orientationChanged(notification)
    }
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }

  private static func flutterErrorFromNSError(_ error: NSError) -> FlutterError {
    return FlutterError(
      code: "Error \(error.code)",
      message: error.localizedDescription,
      details: error.domain)
  }

  func orientationChanged(_ notification: Notification) {
    guard let device = notification.object as? UIDevice else { return }
    let orientation = device.orientation

    if orientation == .faceUp || orientation == .faceDown {
      // Do not change when oriented flat.
      return
    }

    self.captureSessionQueue.async { [weak self] in
      guard let strongSelf = self else { return }
      // `Camera.deviceOrientation` must be set on capture session queue.
      strongSelf.camera?.deviceOrientation = orientation
      // `CameraPlugin.sendDeviceOrientation` can be called on any queue.
      strongSelf.sendDeviceOrientation(orientation)
    }
  }

  func sendDeviceOrientation(_ orientation: UIDeviceOrientation) {
    DispatchQueue.main.async { [weak self] in
      self?.globalEventAPI.deviceOrientationChangedOrientation(
        FCPGetPigeonDeviceOrientationForOrientation(orientation)
      ) { _ in
        // Ignore errors; this is essentially a broadcast stream, and
        // it's fine if the other end doesn't receive the message
        // (e.g., if it doesn't currently have a listener set up).
      }
    }
  }
}

extension CameraPlugin: FCPCameraApi {
  public func availableCameras(
    completion: @escaping ([FCPPlatformCameraDescription]?, FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      guard let strongSelf = self else { return }

      let discoveryDevices: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera,
        .builtInTelephotoCamera,
        .builtInUltraWideCamera,
      ]

      let devices = strongSelf.deviceDiscoverer.discoverySession(
        withDeviceTypes: discoveryDevices,
        mediaType: .video,
        position: .unspecified)

      var reply: [FCPPlatformCameraDescription] = []

      for device in devices {
        let lensFacing = strongSelf.platformLensDirection(for: device)
        let lensType = strongSelf.platformLensType(for: device)
        let cameraDescription = FCPPlatformCameraDescription.make(
          withName: device.uniqueID,
          lensDirection: lensFacing,
          lensType: lensType
        )
        reply.append(cameraDescription)
      }

      completion(reply, nil)
    }
  }

  private func platformLensDirection(for device: CaptureDevice) -> FCPPlatformCameraLensDirection {
    switch device.position {
    case .back:
      return .back
    case .front:
      return .front
    case .unspecified:
      return .external
    @unknown default:
      return .external
    }
  }

  private func platformLensType(for device: CaptureDevice) -> FCPPlatformCameraLensType {
    switch device.deviceType {
    case .builtInWideAngleCamera:
      return .wide
    case .builtInTelephotoCamera:
      return .telephoto
    case .builtInUltraWideCamera:
      return .ultraWide
    case .builtInDualWideCamera:
      return .wide
    default:
      return .unknown
    }
  }

  public func createCamera(
    withName cameraName: String,
    settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {
    // Create FLTCam only if granted camera access (and audio access if audio is enabled)
    captureSessionQueue.async { [weak self] in
      self?.permissionManager.requestCameraPermission { error in
        guard let strongSelf = self else { return }

        if let error = error {
          completion(nil, error)
          return
        }

        // Request audio permission on `create` call with `enableAudio` argument instead of the
        // `prepareForVideoRecording` call. This is because `prepareForVideoRecording` call is
        // optional, and used as a workaround to fix a missing frame issue on iOS.
        if settings.enableAudio {
          // Setup audio capture session only if granted audio access.
          strongSelf.permissionManager.requestAudioPermission { [weak self] audioError in
            // cannot use the outter `strongSelf`
            guard let strongSelf = self else { return }

            if let audioError = audioError {
              completion(nil, audioError)
              return
            }

            strongSelf.createCameraOnSessionQueue(
              withName: cameraName,
              settings: settings,
              completion: completion)
          }
        } else {
          strongSelf.createCameraOnSessionQueue(
            withName: cameraName,
            settings: settings,
            completion: completion)
        }
      }
    }
  }

  func createCameraOnSessionQueue(
    withName: String,
    settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.sessionQueueCreateCamera(name: withName, settings: settings, completion: completion)
    }
  }

  // This must be called on captureSessionQueue. It is extracted from createCameraOnSessionQueue
  // to make it easier to reason about strong/weak self pointers.
  private func sessionQueueCreateCamera(
    name: String,
    settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {
    let mediaSettingsAVWrapper = FLTCamMediaSettingsAVWrapper()

    let camConfiguration = CameraConfiguration(
      mediaSettings: settings,
      mediaSettingsWrapper: mediaSettingsAVWrapper,
      captureDeviceFactory: captureDeviceFactory,
      audioCaptureDeviceFactory: { AVCaptureDevice.default(for: .audio)! },
      captureSessionFactory: captureSessionFactory,
      captureSessionQueue: captureSessionQueue,
      captureDeviceInputFactory: captureDeviceInputFactory,
      initialCameraName: name
    )

    do {
      let newCamera = try DefaultCamera(configuration: camConfiguration)

      camera?.close()
      camera = newCamera

      FLTEnsureToRunOnMainQueue { [weak self] in
        guard let strongSelf = self else { return }
        completion(NSNumber(value: strongSelf.registry.register(newCamera)), nil)
      }
    } catch let error as NSError {
      completion(nil, CameraPlugin.flutterErrorFromNSError(error))
    }
  }

  public func initializeCamera(
    _ cameraId: Int,
    withImageFormat imageFormat: FCPPlatformImageFormatGroup,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.sessionQueueInitializeCamera(
        cameraId,
        withImageFormat: imageFormat,
        completion: completion)
    }
  }

  // This must be called on captureSessionQueue. It is extracted from initializeCamera to make it
  // easier to reason about strong/weak self pointers.
  private func sessionQueueInitializeCamera(
    _ cameraId: Int,
    withImageFormat imageFormat: FCPPlatformImageFormatGroup,
    completion: @escaping (FlutterError?) -> Void
  ) {
    guard let camera = camera else { return }

    camera.videoFormat = FCPGetPixelFormatForPigeonFormat(imageFormat)

    camera.onFrameAvailable = { [weak self] in
      guard let camera = self?.camera else { return }
      if !camera.isPreviewPaused {
        FLTEnsureToRunOnMainQueue {
          self?.registry.textureFrameAvailable(Int64(cameraId))
        }
      }
    }

    camera.dartAPI = FCPCameraEventApi(
      binaryMessenger: messenger,
      messageChannelSuffix: "\(cameraId)"
    )

    camera.reportInitializationState()
    sendDeviceOrientation(UIDevice.current.orientation)
    camera.start()
    completion(nil)
  }

  public func startImageStream(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      guard let strongSelf = self else {
        completion(nil)
        return
      }
      strongSelf.camera?.startImageStream(with: strongSelf.messenger, completion: completion)
    }
  }

  public func stopImageStream(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.stopImageStream()
      completion(nil)
    }
  }

  public func receivedImageStreamData(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.receivedImageStreamData()
      completion(nil)
    }
  }

  public func disposeCamera(_ cameraId: Int, completion: @escaping (FlutterError?) -> Void) {
    registry.unregisterTexture(Int64(cameraId))
    captureSessionQueue.async { [weak self] in
      if let strongSelf = self {
        strongSelf.camera?.close()
        strongSelf.camera = nil
      }
      completion(nil)
    }
  }

  public func lockCapture(
    _ orientation: FCPPlatformDeviceOrientation,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.lockCaptureOrientation(orientation)
      completion(nil)
    }
  }

  public func unlockCaptureOrientation(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.unlockCaptureOrientation()
      completion(nil)
    }
  }

  public func takePicture(completion: @escaping (String?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.captureToFile(completion: completion)
    }
  }

  public func prepareForVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setUpCaptureSessionForAudioIfNeeded()
      completion(nil)
    }
  }

  public func startVideoRecording(
    withStreaming enableStream: Bool,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.camera?.startVideoRecording(
        completion: completion,
        messengerForStreaming: enableStream ? strongSelf.messenger : nil)
    }
  }

  public func stopVideoRecording(completion: @escaping (String?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.stopVideoRecording(completion: completion)
    }
  }

  public func pauseVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.pauseVideoRecording()
      completion(nil)
    }
  }

  public func resumeVideoRecording(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.resumeVideoRecording()
      completion(nil)
    }
  }

  public func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setFlashMode(mode, withCompletion: completion)
    }
  }

  public func setExposureMode(
    _ mode: FCPPlatformExposureMode,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setExposureMode(mode)
      completion(nil)
    }
  }

  public func setExposurePoint(
    _ point: FCPPlatformPoint?,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setExposurePoint(point, withCompletion: completion)
    }
  }

  public func getMinimumExposureOffset(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      if let minOffset = self?.camera?.minimumExposureOffset {
        completion(NSNumber(value: minOffset), nil)
      } else {
        completion(nil, nil)
      }
    }
  }

  public func getMaximumExposureOffset(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      if let maxOffset = self?.camera?.maximumExposureOffset {
        completion(NSNumber(value: maxOffset), nil)
      } else {
        completion(nil, nil)
      }
    }
  }

  public func setExposureOffset(_ offset: Double, completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setExposureOffset(offset)
      completion(nil)
    }
  }

  public func setFocusMode(
    _ mode: FCPPlatformFocusMode,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setFocusMode(mode)
      completion(nil)
    }
  }

  public func setFocus(_ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setFocusPoint(point, completion: completion)
    }
  }

  public func getMinimumZoomLevel(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      if let minZoom = self?.camera?.minimumAvailableZoomFactor {
        completion(NSNumber(value: minZoom), nil)
      } else {
        completion(nil, nil)
      }
    }
  }

  public func getMaximumZoomLevel(_ completion: @escaping (NSNumber?, FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      if let maxZoom = self?.camera?.maximumAvailableZoomFactor {
        completion(NSNumber(value: maxZoom), nil)
      } else {
        completion(nil, nil)
      }
    }
  }

  public func setZoomLevel(_ zoom: Double, completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setZoomLevel(zoom, withCompletion: completion)
    }
  }

  public func pausePreview(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.pausePreview()
      completion(nil)
    }
  }

  public func resumePreview(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.resumePreview()
      completion(nil)
    }
  }

  public func updateDescriptionWhileRecordingCameraName(
    _ cameraName: String,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setDescriptionWhileRecording(cameraName, withCompletion: completion)
    }
  }

  public func setImageFileFormat(
    _ format: FCPPlatformImageFileFormat,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setImageFileFormat(format)
      completion(nil)
    }
  }
}
