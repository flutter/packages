// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import ObjectiveC
import Photos
import PhotosUI
import UIKit
import UniformTypeIdentifiers

#if canImport(image_picker_ios_objc)
  import image_picker_ios_objc
#endif

/// The return handler used for all method calls, which internally adapts the provided result list
/// to return either a list or a single element depending on the original call.
typealias FlutterResultAdapter = ([String]?, FlutterError?) -> Void

/// A container class for context to use when handling a method call from the Dart side.
final class ImagePickerMethodCallContext {
  /// Initializes a new context that calls `result` on completion of the operation.
  init(result: @escaping FlutterResultAdapter) {
    self.result = result
  }

  /// The callback to provide results to the Dart caller.
  var result: FlutterResultAdapter

  /// The maximum size to enforce on the results.
  ///
  /// If nil, no resizing is done.
  var maxSize: FLTMaxSize?

  /// The image quality to resample the results to.
  ///
  /// If nil, no resampling is done.
  var imageQuality: NSNumber?

  /// Maximum number of items to select. 0 indicates no maximum.
  var maxItemCount: Int = 0

  /// Whether the image should be picked with full metadata (requires gallery permissions).
  var requestFullMetadata = false

  /// Maximum duration for videos. 0 indicates no maximum.
  var maxDuration: TimeInterval = 0

  /// Whether the picker should include images in the list.
  var includeImages = false

  /// Whether the picker should include videos in the list.
  var includeVideo = false
}

/// iOS implementation of the image_picker plugin.
public final class ImagePickerPlugin: NSObject, FlutterPlugin, FLTImagePickerApi,
  UINavigationControllerDelegate, UIImagePickerControllerDelegate,
  UIAdaptivePresentationControllerDelegate
{
  /// The context of the Flutter method call that is currently being handled, if any.
  var callContext: ImagePickerMethodCallContext?

  /// UIImagePickerController instances that will be used when a new controller would normally be
  /// created. Each call to createImagePickerController removes the current first element.
  var imagePickerControllerOverrides: [UIImagePickerController]?

  /// The view provider to use for displaying native view controllers.
  let viewProvider: FIPViewProvider

  /// Camera source/device availability. Overridable for tests.
  var cameraAvailability: CameraAvailabilityChecking = DefaultCameraAvailability()

  /// Camera authorization. Overridable for tests.
  var cameraPermissionChecker: CameraPermissionChecking = DefaultCameraPermissionChecker()

  /// Photo library authorization. Overridable for tests.
  var photoLibraryPermissionChecker: PhotoLibraryPermissionChecking =
    DefaultPhotoLibraryPermissionChecker()

  /// PHAsset image-data requests. Overridable for tests.
  var imageDataRequester: ImageDataRequesting = DefaultImageDataRequester()

  /// PHPicker factory. Overridable for tests. Stored as `Any` because the protocol is iOS 14+.
  private var phPickerCreatorStorage: Any?

  /// A temporary UIWindow placed above Flutter's window to swallow all user
  /// interactions while UIImagePickerController is dismissing.
  var interactionBlockerWindow: UIWindow?

  /// The previously active key window before the interactionBlockerWindow is shown.
  weak var previousKeyWindow: UIWindow?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ImagePickerPlugin(
      viewProvider: FIPDefaultViewProvider(registrar: registrar))
    SetUpFLTImagePickerApi(registrar.messenger(), instance)
  }

  init(viewProvider: FIPViewProvider) {
    self.viewProvider = viewProvider
  }

  func createImagePickerController() -> UIImagePickerController {
    if var overrides = imagePickerControllerOverrides, !overrides.isEmpty {
      let controller = overrides.removeFirst()
      imagePickerControllerOverrides = overrides
      return controller
    }
    return UIImagePickerController()
  }

  /// Sets UIImagePickerController instances that will be used when a new controller would normally
  /// be created. Should be used for testing purposes only.
  func setImagePickerControllerOverrides(_ imagePickerControllers: [UIImagePickerController]) {
    imagePickerControllerOverrides = imagePickerControllers
  }

  private func cameraDevice(for source: FLTSourceSpecification)
    -> UIImagePickerController.CameraDevice
  {
    switch source.camera {
    case .front:
      return .front
    case .rear:
      return .rear
    }
  }

  @available(iOS 14, *)
  func launchPHPicker(with context: ImagePickerMethodCallContext) {
    var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    config.selectionLimit = context.maxItemCount
    config.preferredAssetRepresentationMode = .current
    var filters: [PHPickerFilter] = []
    if context.includeImages {
      filters.append(.images)
    }
    if context.includeVideo {
      filters.append(.videos)
    }
    config.filter = PHPickerFilter.any(of: filters)

    let pickerViewController = phPickerCreator.makePicker(configuration: config)
    pickerViewController.delegate = self
    pickerViewController.presentationController?.delegate = self
    callContext = context

    showPhotoLibrary(withPHPicker: pickerViewController)
  }

  @available(iOS 14, *)
  var phPickerCreator: PHPickerCreating {
    get { (phPickerCreatorStorage as? PHPickerCreating) ?? DefaultPHPickerCreator() }
    set { phPickerCreatorStorage = newValue }
  }

  func launchUIImagePicker(
    with source: FLTSourceSpecification, context: ImagePickerMethodCallContext
  ) {
    let imagePickerController = createImagePickerController()
    imagePickerController.modalPresentationStyle = .currentContext
    imagePickerController.delegate = self
    var mediaTypes: [String] = []
    if context.includeImages {
      mediaTypes.append(UTType.image.identifier)
    }
    if context.includeVideo {
      mediaTypes.append(UTType.movie.identifier)
      imagePickerController.videoQuality = .typeHigh
    }
    imagePickerController.mediaTypes = mediaTypes
    if context.maxDuration != 0.0 {
      imagePickerController.videoMaximumDuration = context.maxDuration
    }

    callContext = context

    switch source.type {
    case .camera:
      checkCameraAuthorization(
        with: imagePickerController, camera: cameraDevice(for: source))
    case .gallery:
      if context.requestFullMetadata {
        checkPhotoAuthorization(with: imagePickerController)
      } else {
        showPhotoLibrary(with: imagePickerController)
      }
    @unknown default:
      sendCallResult(
        with: FlutterError(
          code: "invalid_source",
          message: "Invalid image source.",
          details: nil))
    }
  }

  public func pickImage(
    withSource source: FLTSourceSpecification, maxSize: FLTMaxSize, quality imageQuality: NSNumber?,
    fullMetadata: Bool, completion: @escaping (String?, FlutterError?) -> Void
  ) {
    cancelInProgressCall()
    let context = ImagePickerMethodCallContext { paths, error in
      if (paths?.count ?? 0) > 1 {
        completion(
          nil,
          FlutterError(
            code: "invalid_result",
            message: "Incorrect number of return paths provided",
            details: nil))
      }
      completion(paths?.first, error)
    }
    context.includeImages = true
    context.maxSize = maxSize
    context.imageQuality = imageQuality
    context.maxItemCount = 1
    context.requestFullMetadata = fullMetadata

    if source.type == .gallery {
      if #available(iOS 14, *) {
        launchPHPicker(with: context)
      } else {
        launchUIImagePicker(with: source, context: context)
      }
    } else {
      launchUIImagePicker(with: source, context: context)
    }
  }

  public func pickMultiImage(
    with maxSize: FLTMaxSize, quality imageQuality: NSNumber?, fullMetadata: Bool,
    limit: NSNumber?,
    completion: @escaping ([String]?, FlutterError?) -> Void
  ) {
    cancelInProgressCall()
    let context = ImagePickerMethodCallContext { paths, error in
      completion(paths, error)
    }
    context.includeImages = true
    context.maxSize = maxSize
    context.imageQuality = imageQuality
    context.requestFullMetadata = fullMetadata
    context.maxItemCount = limit?.intValue ?? 0

    if #available(iOS 14, *) {
      launchPHPicker(with: context)
    } else {
      launchUIImagePicker(
        with: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    }
  }

  public func pickMedia(
    with mediaSelectionOptions: FLTMediaSelectionOptions,
    completion: @escaping ([String]?, FlutterError?) -> Void
  ) {
    cancelInProgressCall()
    let context = ImagePickerMethodCallContext { paths, error in
      completion(paths, error)
    }
    context.maxSize = mediaSelectionOptions.maxSize
    context.imageQuality = mediaSelectionOptions.imageQuality
    context.requestFullMetadata = mediaSelectionOptions.requestFullMetadata
    context.includeImages = true
    context.includeVideo = true
    let limit = mediaSelectionOptions.limit
    if !mediaSelectionOptions.allowMultiple {
      context.maxItemCount = 1
    } else if let limit {
      context.maxItemCount = limit.intValue
    }

    if #available(iOS 14, *) {
      launchPHPicker(with: context)
    } else {
      launchUIImagePicker(
        with: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    }
  }

  public func pickVideo(
    withSource source: FLTSourceSpecification, maxDuration maxDurationSeconds: NSNumber?,
    completion: @escaping (String?, FlutterError?) -> Void
  ) {
    cancelInProgressCall()
    let context = ImagePickerMethodCallContext { paths, error in
      if (paths?.count ?? 0) > 1 {
        completion(
          nil,
          FlutterError(
            code: "invalid_result",
            message: "Incorrect number of return paths provided",
            details: nil))
      }
      completion(paths?.first, error)
    }
    context.includeVideo = true
    context.maxItemCount = 1
    context.maxDuration = maxDurationSeconds?.doubleValue ?? 0

    if source.type == .gallery {
      if #available(iOS 14, *) {
        launchPHPicker(with: context)
      } else {
        launchUIImagePicker(with: source, context: context)
      }
    } else {
      launchUIImagePicker(with: source, context: context)
    }
  }

  public func pickMultiVideo(
    withMaxDuration maxDurationSeconds: NSNumber?, limit: NSNumber?,
    completion: @escaping ([String]?, FlutterError?) -> Void
  ) {
    cancelInProgressCall()
    let context = ImagePickerMethodCallContext { paths, error in
      completion(paths, error)
    }
    context.includeVideo = true
    context.maxItemCount = limit?.intValue ?? 0
    context.maxDuration = maxDurationSeconds?.doubleValue ?? 0

    if #available(iOS 14, *) {
      launchPHPicker(with: context)
    } else {
      launchUIImagePicker(
        with: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    }
  }

  /// If a call is still in progress, cancels it by returning an error and then clearing state.
  func cancelInProgressCall() {
    if callContext != nil {
      sendCallResult(
        with: FlutterError(
          code: "multiple_request",
          message: "Cancelled by a second request",
          details: nil))
      callContext = nil
    }
  }

  func showCamera(
    _ device: UIImagePickerController.CameraDevice,
    with imagePickerController: UIImagePickerController
  ) {
    objc_sync_enter(self)
    let beingPresented = imagePickerController.isBeingPresented
    objc_sync_exit(self)
    if beingPresented {
      return
    }
    if cameraAvailability.isSourceTypeAvailable(.camera)
      && cameraAvailability.isCameraDeviceAvailable(device)
    {
      imagePickerController.sourceType = .camera
      imagePickerController.cameraDevice = device
      let presentingController = presentingViewControllerForImagePickerInNewWindow()
      presentingController?.present(imagePickerController, animated: true, completion: nil)
    } else {
      let cameraErrorAlert = UIAlertController(
        title: NSLocalizedString("Error", comment: "Alert title when camera unavailable"),
        message: NSLocalizedString(
          "Camera not available.", comment: "Alert message when camera unavailable"),
        preferredStyle: .alert)
      cameraErrorAlert.addAction(
        UIAlertAction(
          title: NSLocalizedString("OK", comment: "Alert button when camera unavailable"),
          style: .default, handler: { _ in }))
      viewProvider.viewController?.present(cameraErrorAlert, animated: true, completion: nil)
      sendCallResult(withSavedPathList: nil)
    }
  }

  func checkCameraAuthorization(
    with imagePickerController: UIImagePickerController,
    camera device: UIImagePickerController.CameraDevice
  ) {
    let status = cameraPermissionChecker.authorizationStatus(for: .video)
    switch status {
    case .authorized:
      showCamera(device, with: imagePickerController)
    case .notDetermined:
      cameraPermissionChecker.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          if granted {
            self.showCamera(device, with: imagePickerController)
          } else {
            self.errorNoCameraAccess(.denied)
          }
        }
      }
    case .denied, .restricted:
      errorNoCameraAccess(status)
    @unknown default:
      errorNoCameraAccess(status)
    }
  }

  func checkPhotoAuthorization(with imagePickerController: UIImagePickerController) {
    let status = photoLibraryPermissionChecker.authorizationStatus()
    switch status {
    case .notDetermined:
      photoLibraryPermissionChecker.requestAuthorization { status in
        DispatchQueue.main.async {
          if status == .authorized {
            self.showPhotoLibrary(with: imagePickerController)
          } else {
            self.errorNoPhotoAccess(status)
          }
        }
      }
    case .authorized:
      showPhotoLibrary(with: imagePickerController)
    case .denied, .restricted:
      errorNoPhotoAccess(status)
    case .limited:
      // Matches the Objective-C `default` branch; Limited is not treated as authorized here.
      errorNoPhotoAccess(status)
    @unknown default:
      errorNoPhotoAccess(status)
    }
  }

  func errorNoCameraAccess(_ status: AVAuthorizationStatus) {
    switch status {
    case .restricted:
      sendCallResult(
        with: FlutterError(
          code: "camera_access_restricted",
          message: "The user is not allowed to use the camera.",
          details: nil))
    default:
      sendCallResult(
        with: FlutterError(
          code: "camera_access_denied",
          message: "The user did not allow camera access.",
          details: nil))
    }
  }

  func errorNoPhotoAccess(_ status: PHAuthorizationStatus) {
    switch status {
    case .restricted:
      sendCallResult(
        with: FlutterError(
          code: "photo_access_restricted",
          message: "The user is not allowed to use the photo.",
          details: nil))
    default:
      sendCallResult(
        with: FlutterError(
          code: "photo_access_denied",
          message: "The user did not allow photo access.",
          details: nil))
    }
  }

  @available(iOS 14, *)
  func showPhotoLibrary(withPHPicker pickerViewController: PHPickerViewController) {
    viewProvider.viewController?.present(pickerViewController, animated: true, completion: nil)
  }

  func showPhotoLibrary(with imagePickerController: UIImagePickerController) {
    imagePickerController.sourceType = .photoLibrary
    viewProvider.viewController?.present(imagePickerController, animated: true, completion: nil)
  }

  func desiredImageQuality(_ imageQuality: NSNumber?) -> NSNumber {
    guard let imageQuality else {
      return 1
    }
    if imageQuality.intValue < 0 || imageQuality.intValue > 100 {
      return 1
    }
    return NSNumber(value: imageQuality.floatValue / 100)
  }

  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    sendCallResult(withSavedPathList: nil)
  }

  /// Processes picker results. Exposed for tests that cannot construct PHPickerResult.
  @available(iOS 14, *)
  func processPickerItems(_ results: [PickerItem], fromPicker picker: PHPickerViewController) {
    picker.dismiss(animated: true, completion: nil)
    if results.isEmpty {
      sendCallResult(withSavedPathList: nil)
      return
    }
    var saveQueue: OperationQueue? = OperationQueue()
    saveQueue?.name = "Flutter Save Image Queue"
    saveQueue?.qualityOfService = .userInitiated

    let currentCallContext = callContext
    let maxWidth = currentCallContext?.maxSize?.width
    let maxHeight = currentCallContext?.maxSize?.height
    let desiredImageQuality = self.desiredImageQuality(currentCallContext?.imageQuality)
    let requestFullMetadata = currentCallContext?.requestFullMetadata ?? false
    // Item-provider completions run concurrently on a private queue.
    var pathList = [String?](repeating: nil, count: results.count)
    var saveError: FlutterError?
    let lock = NSLock()

    let sendListOperation = BlockOperation {
      lock.lock()
      let finishedError = saveError
      let finishedPaths = pathList
      lock.unlock()
      if let finishedError {
        self.sendCallResult(with: finishedError)
      } else {
        self.sendCallResult(withSavedPathList: finishedPaths)
      }
      saveQueue = nil
    }

    for (index, result) in results.enumerated() {
      guard
        let saveOperation = FLTPHPickerSaveImageToPathOperation(
          result: result,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          desiredImageQuality: desiredImageQuality,
          fullMetadata: requestFullMetadata,
          savedPathBlock: { savedPath, error in
            lock.lock()
            defer { lock.unlock() }
            if let savedPath {
              pathList[index] = savedPath
            } else {
              saveError = error
            }
          })
      else {
        continue
      }
      sendListOperation.addDependency(saveOperation)
      saveQueue?.addOperation(saveOperation)
    }

    OperationQueue.main.addOperation(sendListOperation)
  }

  public func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    let videoURL = info[.mediaURL] as? URL
    picker.dismiss(animated: true) {
      self.removeInteractionBlocker()
    }
    if callContext == nil {
      return
    }
    if let videoURL {
      guard let destination = FLTImagePickerPhotoAssetUtil.saveVideo(from: videoURL) else {
        sendCallResult(
          with: FlutterError(
            code: "flutter_image_picker_copy_video_error",
            message: "Could not cache the video file.",
            details: nil))
        return
      }
      sendCallResult(withSavedPathList: [destination.path])
    } else {
      var image = info[.editedImage] as? UIImage
      if image == nil {
        image = info[.originalImage] as? UIImage
      }
      let maxWidth = callContext?.maxSize?.width
      let maxHeight = callContext?.maxSize?.height
      let imageQuality = callContext?.imageQuality
      let desiredImageQuality = self.desiredImageQuality(imageQuality)

      var originalAsset: PHAsset?
      if callContext?.requestFullMetadata == true {
        originalAsset = FLTImagePickerPhotoAssetUtil.getAssetFromImagePickerInfo(
          info.reduce(into: [:]) { result, item in
            result[item.key.rawValue] = item.value
          })
      }

      if maxWidth != nil || maxHeight != nil {
        image = FLTImagePickerImageUtil.scaledImage(
          image, maxWidth: maxWidth, maxHeight: maxHeight, isMetadataAvailable: true)
      }

      if originalAsset == nil {
        saveImage(
          withPickerInfo: info.reduce(into: [:]) { result, item in
            result[item.key.rawValue] = item.value
          }, image: image ?? UIImage(), imageQuality: desiredImageQuality)
      } else if let originalAsset {
        imageDataRequester.requestImageDataAndOrientation(
          for: originalAsset, options: nil
        ) { imageData, _, _, _ in
          self.saveImage(
            withOriginalImageData: imageData, image: image, maxWidth: maxWidth,
            maxHeight: maxHeight, imageQuality: desiredImageQuality)
        }
      }
    }
  }

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.removeInteractionBlocker()
    }
    sendCallResult(withSavedPathList: nil)
  }

  func saveImage(
    withOriginalImageData originalImageData: Data?, image: UIImage?, maxWidth: NSNumber?,
    maxHeight: NSNumber?, imageQuality: NSNumber?
  ) {
    let savedPath = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: originalImageData, image: image ?? UIImage(),
      maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality)
    sendCallResult(withSavedPathList: [savedPath])
  }

  func saveImage(
    withPickerInfo info: [String: Any]?, image: UIImage, imageQuality: NSNumber?
  ) {
    let savedPath = FLTImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: info, image: image, imageQuality: imageQuality)
    sendCallResult(withSavedPathList: [savedPath])
  }

  /// Validates the provided paths list, then sends it via `callContext.result`.
  func sendCallResult(withSavedPathList pathList: [String?]?) {
    guard let callContext else {
      return
    }

    if let pathList, pathList.contains(where: { $0 == nil }) {
      callContext.result(
        nil,
        FlutterError(
          code: "create_error",
          message: "pathList's items should not be null",
          details: nil))
    } else {
      let paths = pathList?.compactMap { $0 } ?? []
      callContext.result(paths, nil)
    }
    self.callContext = nil
  }

  func sendCallResult(with error: FlutterError) {
    guard let callContext else {
      return
    }
    callContext.result(nil, error)
    self.callContext = nil
  }

  /// Why a separate UIWindow for the interaction blocker?
  /// Flutter renders inside a UIWindow owned by FlutterViewController. UIImagePickerController is
  /// presented in that same window and dismisses with an animation; during that brief transition,
  /// taps can “leak” to the Flutter view underneath.
  ///
  /// A view-based blocker (added to the host view hierarchy) isn’t reliable because the host view’s
  /// bounds/constraints/rotation/transitions can change during presentation/dismissal, causing the
  /// blocker to move or be removed.
  ///
  /// Instead we create a dedicated UIWindow (windowLevel + 1) with its own root VC to swallow all
  /// touches during the dismissal window, then restore the previous key window afterward.
  /// The image picker is presented on this blocker window so it appears above everything.
  func presentingViewControllerForImagePickerInNewWindow() -> UIViewController? {
    if let interactionBlockerWindow {
      return interactionBlockerWindow.rootViewController
    }
    let topController = viewProvider.viewController
    guard let presentingWindow = topController?.view.window else {
      return topController
    }
    previousKeyWindow = presentingWindow
    let blockerWindow: UIWindow
    if let windowScene = presentingWindow.windowScene {
      blockerWindow = UIWindow(windowScene: windowScene)
    } else {
      blockerWindow = UIWindow(frame: presentingWindow.bounds)
    }
    blockerWindow.frame = presentingWindow.bounds
    blockerWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blockerWindow.windowLevel = presentingWindow.windowLevel + 1
    let viewController = UIViewController()
    viewController.view.backgroundColor = .clear
    viewController.view.isUserInteractionEnabled = true
    blockerWindow.rootViewController = viewController
    blockerWindow.makeKeyAndVisible()
    interactionBlockerWindow = blockerWindow
    return viewController
  }

  /// Removes the temporary interaction-blocking window and restores the previous key window.
  func removeInteractionBlocker() {
    guard interactionBlockerWindow != nil else {
      return
    }
    interactionBlockerWindow?.isHidden = true
    previousKeyWindow?.makeKey()
    interactionBlockerWindow = nil
    previousKeyWindow = nil
  }
}

@available(iOS 14, *)
private final class BridgedPickerItem: NSObject, PickerItem {
  let itemProvider: NSItemProvider
  let assetIdentifier: String?

  init(_ result: PHPickerResult) {
    self.itemProvider = result.itemProvider
    self.assetIdentifier = result.assetIdentifier
  }
}

@available(iOS 14, *)
extension ImagePickerPlugin: PHPickerViewControllerDelegate {
  public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    processPickerItems(results.map { BridgedPickerItem($0) }, fromPicker: picker)
  }
}
