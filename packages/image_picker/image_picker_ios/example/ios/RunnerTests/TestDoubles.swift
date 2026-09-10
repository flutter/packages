// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Photos
import PhotosUI
import UIKit
import UniformTypeIdentifiers

@testable import image_picker_ios

final class StubViewProvider: NSObject, FIPViewProvider {
  var viewController: UIViewController?

  init(viewController: UIViewController? = nil) {
    self.viewController = viewController
  }
}

/// Records `sourceType` / `cameraDevice` without UIKit's availability checks.
///
/// `UIImagePickerController` throws if `sourceType` is set to `.camera` when
/// the class method `isSourceTypeAvailable(.camera)` is false (Simulator).
/// Original tests used an OCMock class mock of that method; this subclass is
/// the Swift Testing equivalent.
final class RecordingImagePickerController: UIImagePickerController {
  private var recordedSourceType: UIImagePickerController.SourceType = .photoLibrary
  private var recordedCameraDevice: UIImagePickerController.CameraDevice = .rear
  var isBeingPresentedOverride: Bool?

  override var sourceType: UIImagePickerController.SourceType {
    get { recordedSourceType }
    set { recordedSourceType = newValue }
  }

  override var cameraDevice: UIImagePickerController.CameraDevice {
    get { recordedCameraDevice }
    set { recordedCameraDevice = newValue }
  }

  override var isBeingPresented: Bool {
    isBeingPresentedOverride ?? super.isBeingPresented
  }
}

final class RecordingViewController: UIViewController {
  private(set) var presented: UIViewController?

  override func present(
    _ viewControllerToPresent: UIViewController, animated flag: Bool,
    completion: (() -> Void)? = nil
  ) {
    presented = viewControllerToPresent
    completion?()
  }
}

final class FakeCameraAvailability: NSObject, CameraAvailabilityChecking {
  var sourceTypeAvailable = false
  var cameraDeviceAvailable = false

  func isSourceTypeAvailable(_ sourceType: UIImagePickerController.SourceType) -> Bool {
    sourceTypeAvailable
  }

  func isCameraDeviceAvailable(_ cameraDevice: UIImagePickerController.CameraDevice) -> Bool {
    cameraDeviceAvailable
  }
}

final class FakeCameraPermissionChecker: NSObject, CameraPermissionChecking {
  var status: AVAuthorizationStatus = .notDetermined
  var requestAccessCallCount = 0
  /// When false, `requestAccess` stores the handler without invoking it.
  var completesRequestAccess = true
  /// Value passed to the `requestAccess` handler. Independent of `status` so
  /// not-determined → granted/denied can be tested separately.
  var requestAccessGranted = false

  func authorizationStatus(forMediaType mediaType: AVMediaType) -> AVAuthorizationStatus {
    status
  }

  func requestAccess(
    forMediaType mediaType: AVMediaType,
    completionHandler handler: @escaping @Sendable (Bool) -> Void
  ) {
    requestAccessCallCount += 1
    guard completesRequestAccess else { return }
    handler(requestAccessGranted)
  }
}

final class FakePhotoLibraryPermissionChecker: NSObject, PhotoLibraryPermissionChecking {
  var status: PHAuthorizationStatus = .notDetermined
  var authorizationStatusCallCount = 0
  var requestAuthorizationCallCount = 0
  /// When set, `requestAuthorization` reports this status instead of `status`.
  var requestAuthorizationResult: PHAuthorizationStatus?

  func authorizationStatus() -> PHAuthorizationStatus {
    authorizationStatusCallCount += 1
    return status
  }

  func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
    requestAuthorizationCallCount += 1
    handler(requestAuthorizationResult ?? status)
  }
}

/// A `PickerItem` stand-in that does not require constructing a `PHPickerResult`.
final class FakePickerItem: NSObject, PickerItem {
  let itemProvider: NSItemProvider
  let assetIdentifier: String?

  init(itemProvider: NSItemProvider, assetIdentifier: String?) {
    self.itemProvider = itemProvider
    self.assetIdentifier = assetIdentifier
  }
}

final class RecordingPHPickerCreator: NSObject, PHPickerCreating {
  private(set) var lastConfiguration: __PHPickerConfiguration?
  var picker = PHPickerViewController(configuration: PHPickerConfiguration())

  func makePicker(configuration: __PHPickerConfiguration) -> PHPickerViewController {
    lastConfiguration = configuration
    return picker
  }
}

/// NSItemProvider that reports image conformance but fails to load data.
final class FailingDataItemProvider: NSItemProvider {
  let loadError: Error

  init(error: Error) {
    self.loadError = error
    super.init()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
    true
  }

  override func loadDataRepresentation(
    forTypeIdentifier typeIdentifier: String,
    completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void
  ) -> Progress {
    completionHandler(nil, loadError)
    return Progress()
  }
}

/// NSItemProvider that reports movie conformance and optionally loads a file URL.
final class MovieItemProvider: NSItemProvider {
  let movieURL: URL?
  let loadError: Error?

  init(movieURL: URL? = nil, loadError: Error? = nil) {
    self.movieURL = movieURL
    self.loadError = loadError
    super.init()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
    typeIdentifier == UTType.movie.identifier
  }

  override var registeredTypeIdentifiers: [String] {
    [UTType.movie.identifier]
  }

  override func loadFileRepresentation(
    forTypeIdentifier typeIdentifier: String,
    completionHandler: @escaping @Sendable (URL?, (any Error)?) -> Void
  ) -> Progress {
    completionHandler(movieURL, loadError)
    return Progress()
  }
}
