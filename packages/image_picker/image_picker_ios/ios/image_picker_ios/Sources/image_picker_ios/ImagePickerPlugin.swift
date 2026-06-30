// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import MobileCoreServices
import Photos
import PhotosUI
import UIKit
import UniformTypeIdentifiers

typealias FlutterResultAdapter = ([String]?, Error?) -> Void

class ImagePickerMethodCallContext {
    let result: FlutterResultAdapter
    var maxSize: MaxSize?
    var imageQuality: Double?
    var maxItemCount: Int = 0
    var requestFullMetadata: Bool = false
    var maxDuration: TimeInterval = 0
    var includeImages: Bool = false
    var includeVideo: Bool = false

    init(result: @escaping FlutterResultAdapter) {
        self.result = result
    }
}

protocol DeviceCapabilityHandler {
    func isSourceTypeAvailable(_ sourceType: UIImagePickerController.SourceType) -> Bool
    func isCameraDeviceAvailable(_ cameraDevice: UIImagePickerController.CameraDevice) -> Bool
    func cameraAuthorizationStatus() -> AVAuthorizationStatus
    func requestCameraAccess(completionHandler: @escaping (Bool) -> Void)
    func photoLibraryAuthorizationStatus() -> PHAuthorizationStatus
    func requestPhotoLibraryAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
}

final class DefaultDeviceCapabilityHandler: DeviceCapabilityHandler {
    func isSourceTypeAvailable(_ sourceType: UIImagePickerController.SourceType) -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(sourceType)
    }

    func isCameraDeviceAvailable(_ cameraDevice: UIImagePickerController.CameraDevice) -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(cameraDevice)
    }

    func cameraAuthorizationStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestCameraAccess(completionHandler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completionHandler)
    }

    func photoLibraryAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    func requestPhotoLibraryAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(handler)
    }
}

@objc(ImagePickerPlugin)
public class ImagePickerPlugin: NSObject, FlutterPlugin, ImagePickerApi,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    PHPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate
{
    var imagePickerControllerOverrides: [UIImagePickerController]?
    let viewProvider: ViewProvider
    let deviceCapabilityHandler: DeviceCapabilityHandler
    var interactionBlockerWindow: UIWindow?
    weak var previousKeyWindow: UIWindow?

    var callContext: ImagePickerMethodCallContext?

    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ImagePickerPlugin(
            viewProvider: DefaultViewProvider(registrar: registrar),
            deviceCapabilityHandler: DefaultDeviceCapabilityHandler()
        )
        ImagePickerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        registrar.publish(instance)
    }

    init(
        viewProvider: ViewProvider,
        deviceCapabilityHandler: DeviceCapabilityHandler = DefaultDeviceCapabilityHandler()
    ) {
        self.viewProvider = viewProvider
        self.deviceCapabilityHandler = deviceCapabilityHandler
        super.init()
    }

    func createImagePickerController() -> UIImagePickerController {
        if let picker = imagePickerControllerOverrides?.first {
            imagePickerControllerOverrides?.removeFirst()
            return picker
        }
        return UIImagePickerController()
    }

    func setImagePickerControllerOverrides(_ overrides: [UIImagePickerController]) {
        imagePickerControllerOverrides = overrides
    }

    func cameraDevice(for source: SourceSpecification) -> UIImagePickerController.CameraDevice {
        switch source.camera {
        case .front:
            return .front
        case .rear:
            return .rear
        }
    }

    @available(iOS 14, *)
    func launchPHPicker(with context: ImagePickerMethodCallContext) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = max(0, context.maxItemCount)
        config.preferredAssetRepresentationMode = .current

        var filters: [PHPickerFilter] = []
        if context.includeImages {
            filters.append(.images)
        }
        if context.includeVideo {
            filters.append(.videos)
        }
        if !filters.isEmpty {
            config.filter = .any(of: filters)
        }

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        pickerViewController.presentationController?.delegate = self
        callContext = context

        showPhotoLibrary(with: pickerViewController)
    }

    func launchUIImagePicker(
        with source: SourceSpecification, context: ImagePickerMethodCallContext
    ) {
        let imagePickerController = createImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self

        var mediaTypes: [String] = []
        if context.includeImages {
            if #available(iOS 14.0, *) {
                mediaTypes.append(UTType.image.identifier)
            } else {
                mediaTypes.append(kUTTypeImage as String)
            }
        }
        if context.includeVideo {
            if #available(iOS 14.0, *) {
                mediaTypes.append(UTType.movie.identifier)
            } else {
                mediaTypes.append(kUTTypeMovie as String)
            }
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
                with: imagePickerController, camera: cameraDevice(for: source)
            )
        case .gallery:
            if context.requestFullMetadata {
                checkPhotoAuthorization(with: imagePickerController)
            } else {
                showPhotoLibrary(with: imagePickerController)
            }
        }
    }

    func pickImage(
        source: SourceSpecification, maxSize: MaxSize, imageQuality: Int64?,
        requestFullMetadata: Bool,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        cancelInProgressCall()
        let context = ImagePickerMethodCallContext { paths, error in
            if let error = error {
                completion(.failure(error))
            } else if let paths = paths, paths.count > 1 {
                let pigeonError = PigeonError(
                    code: "invalid_result", message: "Incorrect number of return paths provided",
                    details: nil
                )
                completion(.failure(pigeonError))
            } else {
                completion(.success(paths?.first))
            }
        }
        context.includeImages = true
        context.maxSize = maxSize
        context.imageQuality = imageQuality.map(Double.init)
        context.maxItemCount = 1
        context.requestFullMetadata = requestFullMetadata

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

    func pickMultiImage(
        maxSize: MaxSize, imageQuality: Int64?, requestFullMetadata: Bool, limit: Int64?,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        cancelInProgressCall()
        let context = ImagePickerMethodCallContext { paths, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(paths ?? []))
            }
        }
        context.includeImages = true
        context.maxSize = maxSize
        context.imageQuality = imageQuality.map(Double.init)
        context.requestFullMetadata = requestFullMetadata
        context.maxItemCount = Int(limit ?? 0)

        if #available(iOS 14, *) {
            launchPHPicker(with: context)
        } else {
            launchUIImagePicker(
                with: SourceSpecification(type: .gallery, camera: .rear), context: context
            )
        }
    }

    func pickMedia(
        mediaSelectionOptions: MediaSelectionOptions,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        cancelInProgressCall()
        let context = ImagePickerMethodCallContext { paths, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(paths ?? []))
            }
        }
        context.maxSize = mediaSelectionOptions.maxSize
        context.imageQuality = mediaSelectionOptions.imageQuality.map(Double.init)
        context.requestFullMetadata = mediaSelectionOptions.requestFullMetadata
        context.includeImages = true
        context.includeVideo = true
        if !mediaSelectionOptions.allowMultiple {
            context.maxItemCount = 1
        } else if let limit = mediaSelectionOptions.limit {
            context.maxItemCount = Int(limit)
        }

        if #available(iOS 14, *) {
            launchPHPicker(with: context)
        } else {
            launchUIImagePicker(
                with: SourceSpecification(type: .gallery, camera: .rear), context: context
            )
        }
    }

    func pickVideo(
        source: SourceSpecification, maxDurationSeconds: Int64?,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        cancelInProgressCall()
        let context = ImagePickerMethodCallContext { paths, error in
            if let error = error {
                completion(.failure(error))
            } else if let paths = paths, paths.count > 1 {
                let pigeonError = PigeonError(
                    code: "invalid_result", message: "Incorrect number of return paths provided",
                    details: nil
                )
                completion(.failure(pigeonError))
            } else {
                completion(.success(paths?.first))
            }
        }
        context.includeVideo = true
        context.maxItemCount = 1
        context.maxDuration = TimeInterval(maxDurationSeconds ?? 0)

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

    func pickMultiVideo(
        maxDurationSeconds: Int64?, limit: Int64?,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        cancelInProgressCall()
        let context = ImagePickerMethodCallContext { paths, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(paths ?? []))
            }
        }
        context.includeVideo = true
        context.maxItemCount = Int(limit ?? 0)
        context.maxDuration = TimeInterval(maxDurationSeconds ?? 0)

        if #available(iOS 14, *) {
            launchPHPicker(with: context)
        } else {
            launchUIImagePicker(
                with: SourceSpecification(type: .gallery, camera: .rear), context: context
            )
        }
    }

    func cancelInProgressCall() {
        if callContext != nil {
            let pigeonError = PigeonError(
                code: "multiple_request", message: "Cancelled by a second request", details: nil
            )
            sendCallResult(error: pigeonError)
            callContext = nil
        }
    }

    func showCamera(
        _ device: UIImagePickerController.CameraDevice,
        with imagePickerController: UIImagePickerController
    ) {
        if imagePickerController.isBeingPresented {
            return
        }

        if deviceCapabilityHandler.isSourceTypeAvailable(.camera),
           deviceCapabilityHandler.isCameraDeviceAvailable(device)
        {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = device
            let presentingController = presentingViewControllerForImagePickerInNewWindow()
            presentingController.present(imagePickerController, animated: true)
        } else {
            let cameraErrorAlert = UIAlertController(
                title: NSLocalizedString("Error", comment: "Alert title when camera unavailable"),
                message: NSLocalizedString("Camera not available.", comment: "Alert message when camera unavailable"),
                preferredStyle: .alert
            )
            cameraErrorAlert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("OK", comment: "Alert button when camera unavailable"),
                    style: .default
                )
            )
            viewProvider.viewController?.present(cameraErrorAlert, animated: true)
            sendCallResult(pathList: nil)
        }
    }

    func checkCameraAuthorization(
        with imagePickerController: UIImagePickerController,
        camera device: UIImagePickerController.CameraDevice
    ) {
        let status = deviceCapabilityHandler.cameraAuthorizationStatus()

        switch status {
        case .authorized:
            showCamera(device, with: imagePickerController)
        case .notDetermined:
            deviceCapabilityHandler.requestCameraAccess { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showCamera(device, with: imagePickerController)
                    } else {
                        self?.errorNoCameraAccess(.denied)
                    }
                }
            }
        case .denied, .restricted:
            errorNoCameraAccess(status)
        @unknown default:
            errorNoCameraAccess(status)
        }
    }

    func checkPhotoAuthorization(with pickerViewController: UIViewController) {
        let status = deviceCapabilityHandler.photoLibraryAuthorizationStatus()
        switch status {
        case .notDetermined:
            deviceCapabilityHandler.requestPhotoLibraryAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if #available(iOS 14, *) {
                        if status == .authorized || status == .limited {
                            self?.showPhotoLibrary(with: pickerViewController)
                        } else {
                            self?.errorNoPhotoAccess(status)
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        case .authorized, .limited:
            showPhotoLibrary(with: pickerViewController)
        case .denied, .restricted:
            errorNoPhotoAccess(status)
        @unknown default:
            errorNoPhotoAccess(status)
        }
    }

    func errorNoCameraAccess(_ status: AVAuthorizationStatus) {
        let code = status == .restricted ? "camera_access_restricted" : "camera_access_denied"
        let message =
            status == .restricted
                ? "The user is not allowed to use the camera." : "The user did not allow camera access."
        let pigeonError = PigeonError(code: code, message: message, details: nil)
        sendCallResult(error: pigeonError)
    }

    func errorNoPhotoAccess(_ status: PHAuthorizationStatus) {
        let code = status == .restricted ? "photo_access_restricted" : "photo_access_denied"
        let message =
            status == .restricted
                ? "The user is not allowed to use the photo library." : "The user did not allow photo library access."
        let pigeonError = PigeonError(code: code, message: message, details: nil)
        sendCallResult(error: pigeonError)
    }

    func showPhotoLibrary(with pickerViewController: UIViewController) {
        if let imagePicker = pickerViewController as? UIImagePickerController {
            imagePicker.sourceType = .photoLibrary
        }
        viewProvider.viewController?.present(pickerViewController, animated: true)
    }

    func getDesiredImageQuality(_ imageQuality: Double?) -> Double {
        guard let quality = imageQuality else { return 1.0 }
        if quality < 0 || quality > 100 {
            return 1.0
        }
        return quality / 100.0
    }

    public func presentationControllerDidDismiss(_: UIPresentationController) {
        sendCallResult(pathList: nil)
    }

    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.isEmpty {
            sendCallResult(pathList: nil)
            return
        }

        handlePickerResults(results)
    }

    @available(iOS 14, *)
    func handlePickerResults(_ results: [PHPickerResult]) {
        let saveQueue = OperationQueue()
        saveQueue.name = "Flutter Save Image Queue"
        saveQueue.qualityOfService = .userInitiated

        guard let currentCallContext = callContext else { return }
        let maxWidth = currentCallContext.maxSize?.width
        let maxHeight = currentCallContext.maxSize?.height
        let imageQuality = currentCallContext.imageQuality
        let desiredImageQuality = getDesiredImageQuality(imageQuality)
        let requestFullMetadata = currentCallContext.requestFullMetadata

        var pathList = [String?](repeating: nil, count: results.count)
        var saveError: Error?

        let sendListOperation = BlockOperation {
            DispatchQueue.main.async {
                if let error = saveError {
                    self.sendCallResult(error: error)
                } else {
                    self.sendCallResult(pathList: pathList.compactMap { $0 })
                }
            }
        }

        for (index, result) in results.enumerated() {
            let saveOperation = PHPickerSaveImageToPathOperation(
                itemProvider: result.itemProvider,
                maxHeight: maxHeight,
                maxWidth: maxWidth,
                desiredImageQuality: desiredImageQuality,
                fullMetadata: requestFullMetadata
            ) { savedPath, error in
                if let savedPath = savedPath {
                    pathList[index] = savedPath
                } else {
                    saveError = error
                }
            }
            sendListOperation.addDependency(saveOperation)
            saveQueue.addOperation(saveOperation)
        }

        OperationQueue.main.addOperation(sendListOperation)
    }

    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let videoURL = info[.mediaURL] as? URL
        picker.dismiss(animated: true) { [weak self] in
            self?.removeInteractionBlocker()
        }

        if callContext == nil {
            return
        }

        if let videoURL = videoURL {
            if #available(iOS 13.0, *) {
                guard let destination = ImagePickerPhotoAssetUtil.saveVideo(from: videoURL) else {
                    let pigeonError = PigeonError(
                        code: "flutter_image_picker_copy_video_error", message: "Could not cache the video file.",
                        details: nil
                    )
                    sendCallResult(error: pigeonError)
                    return
                }
                sendCallResult(pathList: [destination.path])
            } else {
                sendCallResult(pathList: [videoURL.path])
            }
        } else {
            var image = info[.editedImage] as? UIImage
            if image == nil {
                image = info[.originalImage] as? UIImage
            }

            guard let image = image else {
                let pigeonError = PigeonError(
                    code: "invalid_image", message: "Could not get image from picker", details: nil
                )
                sendCallResult(error: pigeonError)
                return
            }

            let maxWidth = callContext?.maxSize?.width
            let maxHeight = callContext?.maxSize?.height
            let imageQuality = callContext?.imageQuality
            let desiredImageQuality = getDesiredImageQuality(imageQuality)

            var originalAsset: PHAsset?
            if callContext?.requestFullMetadata == true {
                originalAsset = ImagePickerPhotoAssetUtil.getAsset(from: info)
            }

            var processedImage = image
            if maxWidth != nil || maxHeight != nil {
                processedImage = ImagePickerImageUtil.scaledImage(
                    image,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    isMetadataAvailable: true
                )
            }

            if let originalAsset = originalAsset {
                let resultHandler: (Data?, [AnyHashable: Any]?) -> Void = {
                    [weak self] imageData, _ in
                    self?.saveImage(
                        withOriginalImageData: imageData,
                        image: processedImage,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        imageQuality: desiredImageQuality
                    )
                }

                if #available(iOS 13.0, *) {
                    PHImageManager.default().requestImageDataAndOrientation(for: originalAsset, options: nil) {
                        data, _, _, info in
                        resultHandler(data, info)
                    }
                } else {
                    PHImageManager.default().requestImageData(for: originalAsset, options: nil) {
                        data, _, _, info in
                        resultHandler(data, info)
                    }
                }
            } else {
                saveImage(withPickerInfo: info, image: processedImage, imageQuality: desiredImageQuality)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.removeInteractionBlocker()
        }
        sendCallResult(pathList: nil)
    }

    private func saveImage(
        withOriginalImageData originalImageData: Data?,
        image: UIImage,
        maxWidth: Double?,
        maxHeight: Double?,
        imageQuality: Double?
    ) {
        let savedPath = ImagePickerPhotoAssetUtil.saveImage(
            with: originalImageData,
            image: image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: imageQuality
        )
        sendCallResult(pathList: savedPath.map { [$0] } ?? [])
    }

    private func saveImage(
        withPickerInfo info: [UIImagePickerController.InfoKey: Any],
        image: UIImage,
        imageQuality: Double?
    ) {
        let savedPath = ImagePickerPhotoAssetUtil.saveImage(
            with: info,
            image: image,
            imageQuality: imageQuality
        )
        sendCallResult(pathList: savedPath.map { [$0] } ?? [])
    }

    func sendCallResult(pathList: [String]? = nil, error: Error? = nil) {
        guard let context = callContext else { return }
        context.result(pathList, error)
        callContext = nil
    }

    func presentingViewControllerForImagePickerInNewWindow() -> UIViewController {
        if let blocker = interactionBlockerWindow,
           let rootVC = blocker.rootViewController
        {
            return rootVC
        }

        guard let topController = viewProvider.viewController else {
            return UIViewController()
        }

        guard let presentingWindow = topController.viewIfLoaded?.window else {
            return topController
        }

        previousKeyWindow = presentingWindow

        let blockerWindow: UIWindow

        if #available(iOS 13.0, *) {
            if let windowScene = presentingWindow.windowScene {
                blockerWindow = UIWindow(windowScene: windowScene)
            } else {
                blockerWindow = UIWindow(frame: presentingWindow.bounds)
            }
        } else {
            blockerWindow = UIWindow(frame: presentingWindow.bounds)
        }

        blockerWindow.frame = presentingWindow.bounds
        blockerWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blockerWindow.windowLevel = presentingWindow.windowLevel + 1

        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.isUserInteractionEnabled = true

        blockerWindow.rootViewController = vc
        blockerWindow.makeKeyAndVisible()

        interactionBlockerWindow = blockerWindow
        return vc
    }

    func removeInteractionBlocker() {
        guard let blocker = interactionBlockerWindow else { return }
        blocker.isHidden = true
        previousKeyWindow?.makeKey()
        interactionBlockerWindow = nil
        previousKeyWindow = nil
    }
}
