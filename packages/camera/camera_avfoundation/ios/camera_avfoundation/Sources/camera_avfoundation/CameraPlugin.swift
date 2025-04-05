// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import ObjectiveC

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

public typealias CaptureNamedDeviceFactory = (String) -> FLTCaptureDevice

public final class CameraPlugin: NSObject, FlutterPlugin, FCPCameraApi {
  let registry: FlutterTextureRegistry
  let messenger: FlutterBinaryMessenger
  let globalEventAPI: FCPCameraGlobalEventApi
  let deviceDiscoverer: FLTCameraDeviceDiscovering
  let permissionManager: FLTCameraPermissionManager
  let captureDeviceFactory: CaptureNamedDeviceFactory
  let captureSessionFactory: CaptureSessionFactory
  let captureDeviceInputFactory: FLTCaptureDeviceInputFactory

  /// All FLTCam's state access and capture session related operations should be on run on this queue.
  var captureSessionQueue: DispatchQueue

  /// An internal camera object that manages camera's state and performs camera operations.
  var camera: FLTCam?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CameraPlugin(registry: registrar.textures(), messenger: registrar.messenger())

    SetUpFCPCameraApi(registrar.messenger(), instance)
  }

  convenience init(registry: FlutterTextureRegistry, messenger: FlutterBinaryMessenger) {
    self.init(
      registry: registry,
      messenger: messenger,
      globalAPI: FCPCameraGlobalEventApi(binaryMessenger: messenger),
      deviceDiscoverer: FLTDefaultCameraDeviceDiscoverer(),
      permissionManager: FLTCameraPermissionManager(
        permissionService: FLTDefaultPermissionService()),
      deviceFactory: { name in
        FLTDefaultCaptureDevice(device: AVCaptureDevice(uniqueID: name)!)
      },
      captureSessionFactory: { FLTDefaultCaptureSession(captureSession: AVCaptureSession()) },
      captureDeviceInputFactory: FLTDefaultCaptureDeviceInputFactory()
    )
  }

  public init(
    registry: FlutterTextureRegistry,
    messenger: FlutterBinaryMessenger,
    globalAPI: FCPCameraGlobalEventApi,
    deviceDiscoverer: FLTCameraDeviceDiscovering,
    permissionManager: FLTCameraPermissionManager,
    deviceFactory: @escaping CaptureNamedDeviceFactory,
    captureSessionFactory: @escaping CaptureSessionFactory,
    captureDeviceInputFactory: FLTCaptureDeviceInputFactory
  ) {
    self.registry = registry
    self.messenger = messenger
    self.globalEventAPI = globalAPI
    self.deviceDiscoverer = deviceDiscoverer
    self.permissionManager = permissionManager
    self.captureDeviceFactory = deviceFactory
    self.captureSessionFactory = captureSessionFactory
    self.captureDeviceInputFactory = captureDeviceInputFactory

    self.captureSessionQueue = DispatchQueue(label: "io.flutter.camera.captureSessionQueue")

    super.init()

    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)

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

  static func flutterErrorFromNSError(_ error: NSError) -> FlutterError {
    return FlutterError(
      code: "Error \(error.code)", message: error.localizedDescription, details: error.domain)
  }

  func orientationChanged(_ notification: Notification) {
    guard let device = notification.object as? UIDevice else { return }
    let orientation = device.orientation

    if orientation == .faceUp || orientation == .faceDown {
      // Do not change when oriented flat.
      return
    }

    self.captureSessionQueue.async { [weak self] in
      // `FLTCam.setDeviceOrientation` must be called on capture session queue.
      self?.camera?.setDeviceOrientation(orientation)
      // `CameraPlugin.sendDeviceOrientation` can be called on any queue.
      self?.sendDeviceOrientation(orientation)
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

  public func availableCameras(
    completion: @escaping ([FCPPlatformCameraDescription]?, FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      guard let self = self else { return }

      var discoveryDevices: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera,
        .builtInTelephotoCamera,
      ]

      if #available(iOS 13.0, *) {
        discoveryDevices.append(.builtInUltraWideCamera)
      }

      let devices = self.deviceDiscoverer.discoverySession(
        withDeviceTypes: discoveryDevices,
        mediaType: .video,
        position: .unspecified)

      var reply: [FCPPlatformCameraDescription] = []

      for device in devices {
        var lensFacing: FCPPlatformCameraLensDirection

        switch device.position {
        case .back:
          lensFacing = .back
        case .front:
          lensFacing = .front
        case .unspecified:
          lensFacing = .external
        @unknown default:
          lensFacing = .external
        }

        let cameraDescription = FCPPlatformCameraDescription.make(
          withName: device.uniqueID,
          lensDirection: lensFacing
        )
        reply.append(cameraDescription)
      }

      completion(reply, nil)
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
        } else {
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
              } else {
                strongSelf.createCameraOnSessionQueue(
                  withName: cameraName,
                  settings: settings,
                  completion: completion)
              }
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
  }

  public func createCameraOnSessionQueue(
    withName: String, settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.sessionQueueCreateCamera(name: withName, settings: settings, completion: completion)
    }
  }

  // This must be called on captureSessionQueue. It is extracted from
  // initializeCamera:withImageFormat:completion: to make it easier to reason about strong/weak
  // self pointers.
  private func sessionQueueCreateCamera(
    name: String,
    settings: FCPPlatformMediaSettings,
    completion: @escaping (NSNumber?, FlutterError?) -> Void
  ) {
    let mediaSettingsAVWrapper = FLTCamMediaSettingsAVWrapper()

    let camConfiguration = FLTCamConfiguration(
      mediaSettings: settings,
      mediaSettingsWrapper: mediaSettingsAVWrapper,
      captureDeviceFactory: { [self] in
        self.captureDeviceFactory(name)
      },
      captureSessionFactory: captureSessionFactory,
      captureSessionQueue: captureSessionQueue,
      captureDeviceInputFactory: captureDeviceInputFactory
    )

    var error: NSError?
    let newCamera = FLTCam(configuration: camConfiguration, error: &error)

    if let error = error {
      completion(nil, CameraPlugin.flutterErrorFromNSError(error))
    } else {
      camera?.close()
      camera = newCamera

      FLTEnsureToRunOnMainQueue { [weak self] in
        guard let self = self else { return }
        completion(NSNumber(value: self.registry.register(newCamera)), nil)
      }
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

  // This must be called on captureSessionQueue. It is extracted from
  // initializeCamera:withImageFormat:completion: to make it easier to reason about strong/weak
  // self pointers.
  private func sessionQueueInitializeCamera(
    _ cameraId: Int,
    withImageFormat imageFormat: FCPPlatformImageFormatGroup,
    completion: @escaping (FlutterError?) -> Void
  ) {
    camera?.videoFormat = FCPGetPixelFormatForPigeonFormat(imageFormat)

    camera?.onFrameAvailable = { [weak self] in
      if !(self?.camera?.isPreviewPaused ?? true) {
        FLTEnsureToRunOnMainQueue { [weak self] in
          self?.registry.textureFrameAvailable(Int64(cameraId))
        }
      }
    }

    camera?.dartAPI = FCPCameraEventApi(
      binaryMessenger: messenger,
      messageChannelSuffix: "\(cameraId)"
    )

    camera?.reportInitializationState()
    sendDeviceOrientation(UIDevice.current.orientation)
    camera?.start()
    completion(nil)
  }

  public func startImageStream(completion: @escaping (FlutterError?) -> Void) {
    captureSessionQueue.async { [weak self] in
      guard let self = self else { return }
      self.camera?.startImageStream(with: self.messenger)
      completion(nil)
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
      self?.camera?.close()
      self?.camera = nil
      completion(nil)
    }
  }

  public func lockCapture(
    _ orientation: FCPPlatformDeviceOrientation,
    completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.lockCapture(orientation)
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
    withStreaming enableStream: Bool, completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      guard let self = self else { return }
      self.camera?.startVideoRecording(
        completion: completion,
        messengerForStreaming: enableStream ? self.messenger : nil)
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
    _ mode: FCPPlatformFlashMode, completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setFlashMode(mode, withCompletion: completion)
    }
  }

  public func setExposureMode(
    _ mode: FCPPlatformExposureMode, completion: @escaping (FlutterError?) -> Void
  ) {
    captureSessionQueue.async { [weak self] in
      self?.camera?.setExposureMode(mode)
      completion(nil)
    }
  }

  public func setExposurePoint(
    _ point: FCPPlatformPoint?, completion: @escaping (FlutterError?) -> Void
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
    _ mode: FCPPlatformFocusMode, completion: @escaping (FlutterError?) -> Void
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
