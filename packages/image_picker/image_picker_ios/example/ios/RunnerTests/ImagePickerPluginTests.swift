// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos
import PhotosUI
import Testing
import UIKit
import UniformTypeIdentifiers

@testable import image_picker_ios

@Suite
@MainActor
struct ImagePickerPluginTests {
  private func pluginWithAuthorizedCamera() -> (
    FLTImagePickerPlugin, FakeCameraAvailability, FakeCameraPermissionChecker
  ) {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let camera = FakeCameraAvailability()
    camera.sourceTypeAvailable = true
    camera.cameraDeviceAvailable = true
    plugin.cameraAvailability = camera
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .authorized
    plugin.cameraPermissionChecker = permissions
    return (plugin, camera, permissions)
  }

  @Test func pluginPickImageDeviceBack() {
    let (plugin, _, _) = pluginWithAuthorizedCamera()
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }
    #expect(controller.cameraDevice == .rear)
  }

  @Test func pluginPickImageDeviceFront() {
    let (plugin, _, _) = pluginWithAuthorizedCamera()
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .front),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }
    #expect(controller.cameraDevice == .front)
  }

  @Test func pluginPickVideoDeviceBack() {
    let (plugin, _, _) = pluginWithAuthorizedCamera()
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickVideo(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxDuration: nil
    ) { _, _ in }
    #expect(controller.cameraDevice == .rear)
  }

  @Test func pluginPickVideoDeviceFront() {
    let (plugin, _, _) = pluginWithAuthorizedCamera()
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickVideo(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .front),
      maxDuration: nil
    ) { _, _ in }
    #expect(controller.cameraDevice == .front)
  }

  @Test func pickMultiImageShouldUseUIImagePickerControllerOnPreiOS14() {
    if #available(iOS 14, *) {
      return
    }
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .authorized
    plugin.photoLibraryPermissionChecker = photo
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickMultiImage(
      with: FLTMaxSize.make(withWidth: 100, height: 200), quality: 50, fullMetadata: true,
      limit: nil
    ) { _, _ in }
    #expect(controller.sourceType == .photoLibrary)
  }

  @Test func pickMediaShouldUseUIImagePickerControllerOnPreiOS14() {
    if #available(iOS 14, *) {
      return
    }
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .authorized
    plugin.photoLibraryPermissionChecker = photo
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickMedia(
      with: FLTMediaSelectionOptions.make(
        with: FLTMaxSize.make(withWidth: 100, height: 200),
        imageQuality: 50,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: nil)
    ) { _, _ in }
    #expect(controller.sourceType == .photoLibrary)
  }

  @Test func pickImageWithoutFullMetadata() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    plugin.photoLibraryPermissionChecker = photo
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .front),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: false
    ) { _, _ in }
    #expect(photo.authorizationStatusCallCount == 0)
  }

  @Test func pickMultiImageWithoutFullMetadata() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    plugin.photoLibraryPermissionChecker = photo
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    plugin.pickMultiImage(
      with: FLTMaxSize(), quality: nil, fullMetadata: false, limit: nil
    ) { _, _ in }
    #expect(photo.authorizationStatusCallCount == 0)
  }

  @Test func pickMediaWithoutFullMetadata() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    plugin.photoLibraryPermissionChecker = photo
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    plugin.pickMedia(
      with: FLTMediaSelectionOptions.make(
        with: FLTMaxSize(),
        imageQuality: nil,
        requestFullMetadata: false,
        allowMultiple: true,
        limit: nil)
    ) { _, _ in }
    #expect(photo.authorizationStatusCallCount == 0)
  }

  @Test func pluginPickImageDeviceCancelClickMultipleTimes() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      return
    }
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }
    plugin.imagePickerControllerDidCancel(controller)
    plugin.imagePickerControllerDidCancel(controller)
  }

  @Test func cameraPickerInteractionBlockerWindowIsAddedAndRemoved() {
    let (_, camera, permissions) = pluginWithAuthorizedCamera()
    let scene = UIApplication.shared.connectedScenes.first as! UIWindowScene
    let window = UIWindow(windowScene: scene)
    window.frame = scene.coordinateSpace.bounds
    let rootViewController = UIViewController()
    window.rootViewController = rootViewController
    rootViewController.loadViewIfNeeded()
    window.makeKeyAndVisible()

    let viewProvider = StubViewProvider(viewController: rootViewController)
    let hostedPlugin = FLTImagePickerPlugin(viewProvider: viewProvider)
    hostedPlugin.cameraAvailability = camera
    hostedPlugin.cameraPermissionChecker = permissions
    let controller = RecordingImagePickerController()
    hostedPlugin.setImagePickerControllerOverrides([controller])
    hostedPlugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }

    #expect(hostedPlugin.interactionBlockerWindow != nil)
    #expect(hostedPlugin.previousKeyWindow === window)
    #expect(hostedPlugin.interactionBlockerWindow!.windowLevel > window.windowLevel)
    #expect(!window.isKeyWindow)

    hostedPlugin.removeInteractionBlocker()
    #expect(hostedPlugin.interactionBlockerWindow == nil)
    #expect(hostedPlugin.previousKeyWindow == nil)
    #expect(window.isKeyWindow)
  }

  @Test func pickingVideoWithDuration() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickVideo(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxDuration: 95
    ) { _, _ in }
    #expect(controller.videoMaximumDuration == 95)
  }

  @Test func pickingMultiVideoWithDuration() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMultiVideo(withMaxDuration: 95, limit: nil) { _, _ in }
    #expect(plugin.callContext?.maxDuration == 95)
  }

  @Test func pluginMultiImagePathHasNullItem() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await confirmation("result") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { _, error in
        #expect(error?.code == "create_error")
        confirmed()
      }
      plugin.sendCallResult(withSavedPathList: [NSNull()])
    }
  }

  @Test func pluginMultiImagePathHasItem() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let pathList = ["test"]
    await confirmation("result") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result as? [String] == pathList)
        confirmed()
      }
      plugin.sendCallResult(withSavedPathList: pathList)
    }
  }

  @Test func pluginMediaPathHasNoItem() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await confirmation("result") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result as? [String] == [])
        confirmed()
      }
      plugin.sendCallResult(withSavedPathList: [])
    }
  }

  @Test func pluginMediaPathConvertsNilToEmptyList() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await confirmation("result") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result as? [String] == [])
        confirmed()
      }
      plugin.sendCallResult(withSavedPathList: nil)
    }
  }

  @Test func pluginMediaPathHasItem() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let pathList = ["test"]
    await confirmation("result") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result as? [String] == pathList)
        confirmed()
      }
      plugin.sendCallResult(withSavedPathList: pathList)
    }
  }

  @Test func sendsImageInvalidSourceError() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let picker = PHPickerViewController(configuration: PHPickerConfiguration())
    let failItem = FakePickerItem(itemProvider: NSItemProvider(), assetIdentifier: nil)
    await confirmation("result") { confirmed in
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        plugin.callContext = FLTImagePickerMethodCallContext { result, error in
          #expect(Thread.isMainThread)
          #expect(result == nil)
          #expect(error?.code == "invalid_source")
          confirmed()
          continuation.resume()
        }
        plugin.processPickerItems([failItem, failItem], fromPicker: picker)
      }
    }
  }

  @Test func sendsImageInvalidErrorWhenOneFails() async throws {
    let loadDataError = NSError(domain: "PHPickerDomain", code: 1234)
    let failItem = FakePickerItem(
      itemProvider: FailingDataItemProvider(error: loadDataError), assetIdentifier: nil)
    let tiffURL = try #require(
      ImagePickerTestImages.bundle.url(forResource: "tiffImage", withExtension: "tiff"))
    let tiffItem = FakePickerItem(
      itemProvider: NSItemProvider(contentsOf: tiffURL)!, assetIdentifier: nil)
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let picker = PHPickerViewController(configuration: PHPickerConfiguration())
    await confirmation("result") { confirmed in
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        plugin.callContext = FLTImagePickerMethodCallContext { result, error in
          #expect(Thread.isMainThread)
          #expect(result == nil)
          #expect(error?.code == "invalid_image")
          confirmed()
          continuation.resume()
        }
        plugin.processPickerItems([failItem, tiffItem], fromPicker: picker)
      }
    }
  }

  @Test func savesImages() async throws {
    let tiffURL = try #require(
      ImagePickerTestImages.bundle.url(forResource: "tiffImage", withExtension: "tiff"))
    let pngURL = try #require(
      ImagePickerTestImages.bundle.url(forResource: "pngImage", withExtension: "png"))
    let tiffItem = FakePickerItem(
      itemProvider: NSItemProvider(contentsOf: tiffURL)!, assetIdentifier: nil)
    let pngItem = FakePickerItem(
      itemProvider: NSItemProvider(contentsOf: pngURL)!, assetIdentifier: nil)
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let picker = PHPickerViewController(configuration: PHPickerConfiguration())
    await confirmation("result") { confirmed in
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        plugin.callContext = FLTImagePickerMethodCallContext { result, error in
          #expect(Thread.isMainThread)
          #expect(result?.count == 2)
          #expect(error == nil)
          confirmed()
          continuation.resume()
        }
        plugin.processPickerItems([tiffItem, pngItem], fromPicker: picker)
      }
    }
  }

  @Test func pickImageDoesntRequestAuthorization() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .notDetermined
    plugin.photoLibraryPermissionChecker = photo
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .front),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }
    #expect(photo.requestAuthorizationCallCount == 0)
  }

  @Test func pickMultiImageDuplicateCallCancels() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await confirmation("first call") { confirmed in
      plugin.pickMultiImage(
        with: FLTMaxSize.make(withWidth: 100, height: 100), quality: nil, fullMetadata: true,
        limit: nil
      ) { _, error in
        #expect(error?.code == "multiple_request")
        confirmed()
      }
      plugin.pickMultiImage(
        with: FLTMaxSize.make(withWidth: 100, height: 100), quality: nil, fullMetadata: true,
        limit: nil
      ) { _, _ in }
    }
  }

  @Test func pickMediaDuplicateCallCancels() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let options = FLTMediaSelectionOptions.make(
      with: FLTMaxSize.make(withWidth: 100, height: 200),
      imageQuality: 50,
      requestFullMetadata: true,
      allowMultiple: true,
      limit: nil)
    await confirmation("first call") { confirmed in
      plugin.pickMedia(with: options) { _, error in
        #expect(error?.code == "multiple_request")
        confirmed()
      }
      plugin.pickMedia(with: options) { _, _ in }
    }
  }

  @Test func pickVideoDuplicateCallCancels() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .notDetermined
    permissions.completesRequestAccess = false
    plugin.cameraPermissionChecker = permissions
    let source = FLTSourceSpecification.make(with: .camera, camera: .rear)
    await confirmation("first call") { confirmed in
      plugin.pickVideo(withSource: source, maxDuration: nil) { _, error in
        #expect(error?.code == "multiple_request")
        confirmed()
      }
      plugin.pickVideo(withSource: source, maxDuration: nil) { _, _ in }
    }
  }

  @Test func pickMultiImageWithLimit() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMultiImage(
      with: FLTMaxSize(), quality: nil, fullMetadata: false, limit: 2
    ) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 2)
  }

  @Test func pickMediaWithLimitAllowsMultiple() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMedia(
      with: FLTMediaSelectionOptions.make(
        with: FLTMaxSize.make(withWidth: 100, height: 200),
        imageQuality: nil,
        requestFullMetadata: false,
        allowMultiple: true,
        limit: 2)
    ) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 2)
  }

  @Test func pickMediaWithLimitMultipleNotAllowed() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMedia(
      with: FLTMediaSelectionOptions.make(
        with: FLTMaxSize.make(withWidth: 100, height: 200),
        imageQuality: nil,
        requestFullMetadata: false,
        allowMultiple: false,
        limit: 2)
    ) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 1)
  }

  @Test func pickMultiImageWithoutLimit() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMultiImage(
      with: FLTMaxSize(), quality: nil, fullMetadata: false, limit: nil
    ) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 0)
  }

  @Test func pickMediaWithoutLimitAllowsMultiple() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMedia(
      with: FLTMediaSelectionOptions.make(
        with: FLTMaxSize.make(withWidth: 100, height: 200),
        imageQuality: nil,
        requestFullMetadata: false,
        allowMultiple: true,
        limit: nil)
    ) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 0)
  }

  @Test func pickMultiVideoWithLimit() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMultiVideo(withMaxDuration: nil, limit: 2) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 2)
  }

  @Test func pickMultiVideoWithoutLimit() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.pickMultiVideo(withMaxDuration: nil, limit: nil) { _, _ in }
    #expect(plugin.callContext?.maxItemCount == 0)
  }

  @Test func pickVideoSetsCurrentRepresentationMode() {
    let creator = RecordingPHPickerCreator()
    let plugin = FLTImagePickerPlugin(
      viewProvider: StubViewProvider(viewController: UIViewController()))
    plugin.phPickerCreator = creator
    plugin.pickVideo(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear),
      maxDuration: nil
    ) { _, _ in }
    #expect(
      creator.lastConfiguration?.preferredAssetRepresentationMode == .current)
  }

  @Test func pickImageInvalidResultWhenMultiplePathsReturned() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    var completionCount = 0
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: false
      ) { result, error in
        completionCount += 1
        if completionCount == 1 {
          #expect(result == nil)
          #expect(error?.code == "invalid_result")
        } else {
          #expect(result == "a")
          continuation.resume()
        }
      }
      plugin.sendCallResult(withSavedPathList: ["a", "b"])
    }
    #expect(completionCount == 2)
  }

  @Test func pickVideoInvalidResultWhenMultiplePathsReturned() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    var completionCount = 0
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.pickVideo(
        withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear),
        maxDuration: nil
      ) { result, error in
        completionCount += 1
        if completionCount == 1 {
          #expect(result == nil)
          #expect(error?.code == "invalid_result")
        } else {
          #expect(result == "a")
          continuation.resume()
        }
      }
      plugin.sendCallResult(withSavedPathList: ["a", "b"])
    }
    #expect(completionCount == 2)
  }

  @Test func phPickerCancelSendsEmptyPathList() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let picker = PHPickerViewController(configuration: PHPickerConfiguration())
    await confirmation("cancelled") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, error in
        #expect(result as? [String] == [])
        #expect(error == nil)
        confirmed()
      }
      plugin.picker(picker, didFinishPicking: [])
    }
  }

  @Test func presentationControllerDidDismissSendsEmptyPathList() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let presented = UIViewController()
    let presenting = UIViewController()
    let presentationController = UIPresentationController(
      presentedViewController: presented, presenting: presenting)
    await confirmation("dismissed") { confirmed in
      plugin.callContext = FLTImagePickerMethodCallContext { result, error in
        #expect(result as? [String] == [])
        #expect(error == nil)
        confirmed()
      }
      plugin.presentationControllerDidDismiss(presentationController)
    }
  }

  @Test func desiredImageQualityClampsOutOfRangeValues() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    #expect(abs(plugin.getDesiredImageQuality(-1).doubleValue - 1.0) < 0.0001)
  }

  @Test func desiredImageQualityScalesValidPercent() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    #expect(abs(plugin.getDesiredImageQuality(50).doubleValue - 0.5) < 0.0001)
  }

  @Test func desiredImageQualityOver100IsClamped() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    #expect(abs(plugin.getDesiredImageQuality(150).doubleValue - 1.0) < 0.0001)
  }

  @Test func cameraAccessDeniedReturnsError() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .denied
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("denied") { confirmed in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { _, error in
        #expect(error?.code == "camera_access_denied")
        confirmed()
      }
    }
  }

  @Test func cameraAccessRestrictedReturnsError() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .restricted
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("restricted") { confirmed in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { _, error in
        #expect(error?.code == "camera_access_restricted")
        confirmed()
      }
    }
  }

  @Test func cameraAccessNotDeterminedDenied() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .notDetermined
    permissions.requestAccessGranted = false
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { _, error in
        #expect(error?.code == "camera_access_denied")
        continuation.resume()
      }
    }
  }

  @Test func cameraAccessNotDeterminedGrantedPresentsCamera() async {
    let (plugin, camera, permissions) = pluginWithAuthorizedCamera()
    permissions.status = .notDetermined
    permissions.requestAccessGranted = true
    camera.sourceTypeAvailable = true
    camera.cameraDeviceAvailable = true
    let controller = RecordingImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    plugin.pickImage(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
      maxSize: FLTMaxSize(),
      quality: nil,
      fullMetadata: true
    ) { _, _ in }
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      DispatchQueue.main.async {
        #expect(controller.sourceType == .camera)
        continuation.resume()
      }
    }
  }

  @Test func showCameraWhenUnavailableSendsNilPathList() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let camera = FakeCameraAvailability()
    camera.sourceTypeAvailable = false
    plugin.cameraAvailability = camera
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .authorized
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("unavailable") { confirmed in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { result, error in
        #expect(result == nil)
        #expect(error == nil)
        confirmed()
      }
    }
  }

  @Test func showCameraReturnsEarlyWhenAlreadyBeingPresented() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let picker = RecordingImagePickerController()
    picker.isBeingPresentedOverride = true
    let originalSource = picker.sourceType
    plugin.showCamera(.rear, withImagePicker: picker)
    #expect(picker.sourceType == originalSource)
  }

  @Test func cameraAccessUnknownStatusTreatedAsDenied() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = AVAuthorizationStatus(rawValue: 999)!
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("unknown denied") { confirmed in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { _, error in
        #expect(error?.code == "camera_access_denied")
        confirmed()
      }
    }
  }

  @Test func showCameraUnavailableAlertOKHandler() async {
    let host = RecordingViewController()
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider(viewController: host))
    let camera = FakeCameraAvailability()
    camera.sourceTypeAvailable = false
    plugin.cameraAvailability = camera
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .authorized
    plugin.cameraPermissionChecker = permissions
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("unavailable") { confirmed in
      plugin.pickImage(
        withSource: FLTSourceSpecification.make(with: .camera, camera: .rear),
        maxSize: FLTMaxSize(),
        quality: nil,
        fullMetadata: true
      ) { result, error in
        #expect(result == nil)
        #expect(error == nil)
        confirmed()
      }
    }
    let alert = host.presented as? UIAlertController
    #expect(alert != nil)
    if let action = alert?.actions.first,
      let handler = action.value(forKey: "handler") as? (UIAlertAction) -> Void
    {
      handler(action)
    }
  }

  @Test func presentingViewControllerWithoutWindowReturnsHostController() {
    let host = UIViewController()
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider(viewController: host))
    #expect(plugin.presentingViewControllerForImagePickerInNewWindow() === host)
  }

  @Test func presentingViewControllerReusesExistingBlockerWindow() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    let rootViewController = UIViewController()
    window.rootViewController = rootViewController
    rootViewController.loadViewIfNeeded()
    let plugin = FLTImagePickerPlugin(
      viewProvider: StubViewProvider(viewController: rootViewController))
    let first = plugin.presentingViewControllerForImagePickerInNewWindow()
    let second = plugin.presentingViewControllerForImagePickerInNewWindow()
    #expect(first === second)
    plugin.removeInteractionBlocker()
  }

  @Test func presentingViewControllerWithoutWindowSceneUsesFrame() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    let rootViewController = UIViewController()
    window.rootViewController = rootViewController
    rootViewController.loadViewIfNeeded()
    let plugin = FLTImagePickerPlugin(
      viewProvider: StubViewProvider(viewController: rootViewController))
    #expect(plugin.presentingViewControllerForImagePickerInNewWindow() != nil)
    plugin.removeInteractionBlocker()
  }

  @Test func launchUIImagePickerGalleryWithoutFullMetadataSkipsAuthorization() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    plugin.photoLibraryPermissionChecker = photo
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    let context = FLTImagePickerMethodCallContext { _, _ in }
    context.includeImages = true
    context.requestFullMetadata = false
    plugin.launchUIImagePicker(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    #expect(controller.sourceType == .photoLibrary)
    #expect(photo.authorizationStatusCallCount == 0)
  }

  @Test func photoAccessDeniedReturnsError() async {
    await expectPhotoAccessError(.denied, code: "photo_access_denied")
  }

  @Test func photoAccessRestrictedReturnsError() async {
    await expectPhotoAccessError(.restricted, code: "photo_access_restricted")
  }

  @Test func photoAccessAuthorizedShowsLibrary() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .authorized
    plugin.photoLibraryPermissionChecker = photo
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    let context = FLTImagePickerMethodCallContext { _, _ in }
    context.includeImages = true
    context.requestFullMetadata = true
    plugin.launchUIImagePicker(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    #expect(controller.sourceType == .photoLibrary)
  }

  @Test func photoAccessNotDeterminedGrantedShowsLibrary() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .notDetermined
    photo.requestAuthorizationResult = .authorized
    plugin.photoLibraryPermissionChecker = photo
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    let context = FLTImagePickerMethodCallContext { _, _ in }
    context.includeImages = true
    context.requestFullMetadata = true
    plugin.launchUIImagePicker(
      withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      DispatchQueue.main.async {
        #expect(controller.sourceType == .photoLibrary)
        continuation.resume()
      }
    }
  }

  @Test func photoAccessNotDeterminedDeniedReturnsError() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = .notDetermined
    photo.requestAuthorizationResult = .denied
    plugin.photoLibraryPermissionChecker = photo
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      let context = FLTImagePickerMethodCallContext { _, error in
        #expect(error?.code == "photo_access_denied")
        continuation.resume()
      }
      context.includeImages = true
      context.requestFullMetadata = true
      plugin.launchUIImagePicker(
        withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    }
  }

  @Test func photoAccessLimitedReturnsDeniedError() async {
    await expectPhotoAccessError(.limited, code: "photo_access_denied")
  }

  @Test func photoAccessUnknownStatusTreatedAsDenied() async {
    await expectPhotoAccessError(PHAuthorizationStatus(rawValue: 999)!, code: "photo_access_denied")
  }

  @Test func launchUIImagePickerInvalidSourceReturnsError() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("invalid source") { confirmed in
      let context = FLTImagePickerMethodCallContext { _, error in
        #expect(error?.code == "invalid_source")
        confirmed()
      }
      context.includeImages = true
      let source = FLTSourceSpecification.make(with: .gallery, camera: .rear)
      source.type = FLTSourceType(rawValue: 99)!
      plugin.launchUIImagePicker(withSource: source, context: context)
    }
  }

  @Test func launchUIImagePickerSetsImageAndVideoMediaTypes() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let permissions = FakeCameraPermissionChecker()
    permissions.status = .denied
    plugin.cameraPermissionChecker = permissions
    let controller = UIImagePickerController()
    plugin.setImagePickerControllerOverrides([controller])
    let context = FLTImagePickerMethodCallContext { _, _ in }
    context.includeImages = true
    context.includeVideo = true
    context.maxDuration = 42
    plugin.launchUIImagePicker(
      withSource: FLTSourceSpecification.make(with: .camera, camera: .rear), context: context)
    #expect(controller.videoMaximumDuration == 42)
    #expect(controller.videoQuality == .typeHigh)
    #expect(controller.mediaTypes.contains(UTType.image.identifier))
    #expect(controller.mediaTypes.contains(UTType.movie.identifier))
  }

  @Test func imagePickerDidFinishPickingOriginalImage() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result?.count == 1)
        #expect(FileManager.default.fileExists(atPath: result?.first ?? ""))
        continuation.resume()
      }
      plugin.callContext?.maxSize = FLTMaxSize()
      plugin.callContext?.requestFullMetadata = false
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [.originalImage: image])
    }
  }

  @Test func imagePickerDidFinishPickingPrefersEditedImage() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let original = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let edited = UIImage(data: ImagePickerTestImages.pngTestData)!
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result?.count == 1)
        continuation.resume()
      }
      plugin.callContext?.maxSize = FLTMaxSize()
      plugin.callContext?.requestFullMetadata = false
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [
          .originalImage: original,
          .editedImage: edited,
        ])
    }
  }

  @Test func imagePickerDidFinishPickingScalesImage() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result?.count == 1)
        let saved = UIImage(contentsOfFile: result?.first ?? "")
        #expect(saved?.size.width == 3)
        #expect(saved?.size.height == 2)
        continuation.resume()
      }
      plugin.callContext?.maxSize = FLTMaxSize.make(withWidth: 3, height: 2)
      plugin.callContext?.requestFullMetadata = false
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [.originalImage: image])
    }
  }

  @Test func imagePickerDidFinishPickingFullMetadataWithoutAsset() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result?.count == 1)
        continuation.resume()
      }
      plugin.callContext?.maxSize = FLTMaxSize()
      plugin.callContext?.requestFullMetadata = true
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [.originalImage: image])
    }
  }

  @Test func imagePickerDidFinishPickingVideo() async {
    let sourcePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".mov")
    #expect(
      FileManager.default.createFile(
        atPath: sourcePath, contents: Data("video".utf8), attributes: nil))
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { result, _ in
        #expect(result?.count == 1)
        #expect(FileManager.default.fileExists(atPath: result?.first ?? ""))
        continuation.resume()
      }
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [.mediaURL: URL(fileURLWithPath: sourcePath)])
    }
    try? FileManager.default.removeItem(atPath: sourcePath)
  }

  @Test func imagePickerDidFinishPickingVideoCopyFailure() async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      plugin.callContext = FLTImagePickerMethodCallContext { _, error in
        #expect(error?.code == "flutter_image_picker_copy_video_error")
        continuation.resume()
      }
      plugin.imagePickerController(
        UIImagePickerController(),
        didFinishPickingMediaWithInfo: [
          .mediaURL: URL(fileURLWithPath: "/this/path/does/not/exist.mov")
        ])
    }
  }

  @Test func imagePickerDidFinishPickingIgnoredWhenNoCallContext() {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    plugin.imagePickerController(
      UIImagePickerController(),
      didFinishPickingMediaWithInfo: [.originalImage: image])
  }

  private func expectPhotoAccessError(_ status: PHAuthorizationStatus, code: String) async {
    let plugin = FLTImagePickerPlugin(viewProvider: StubViewProvider())
    let photo = FakePhotoLibraryPermissionChecker()
    photo.status = status
    plugin.photoLibraryPermissionChecker = photo
    plugin.setImagePickerControllerOverrides([UIImagePickerController()])
    await confirmation("photo error") { confirmed in
      let context = FLTImagePickerMethodCallContext { _, error in
        #expect(error?.code == code)
        confirmed()
      }
      context.includeImages = true
      context.requestFullMetadata = true
      plugin.launchUIImagePicker(
        withSource: FLTSourceSpecification.make(with: .gallery, camera: .rear), context: context)
    }
  }
}
