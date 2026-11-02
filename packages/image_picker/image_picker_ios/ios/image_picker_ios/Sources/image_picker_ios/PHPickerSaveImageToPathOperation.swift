// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import PhotosUI
import UniformTypeIdentifiers

/// Returns either the saved path, or an error. Both cannot be set.
typealias GetSavedPath = (String?, FlutterError?) -> Void

/// Saves a PHPicker result to a temporary path on a background operation queue.
@available(iOS 14, *)
final class PHPickerSaveImageToPathOperation: Operation, @unchecked Sendable {
  private let result: PickerItem
  private let maxHeight: NSNumber?
  private let maxWidth: NSNumber?
  private let desiredImageQuality: NSNumber
  private let getSavedPath: GetSavedPath

  private var executingState = false
  private var finishedState = false

  override var isAsynchronous: Bool { true }

  override var isExecuting: Bool { executingState }

  override var isFinished: Bool { finishedState }

  init?(
    result: PickerItem?,
    maxHeight: NSNumber?,
    maxWidth: NSNumber?,
    desiredImageQuality: NSNumber,
    fullMetadata _: Bool,
    savedPathBlock: @escaping GetSavedPath
  ) {
    guard let result else {
      return nil
    }
    self.result = result
    self.maxHeight = maxHeight
    self.maxWidth = maxWidth
    self.desiredImageQuality = desiredImageQuality
    self.getSavedPath = savedPathBlock
    super.init()
  }

  private func setExecuting(_ value: Bool) {
    willChangeValue(forKey: "isExecuting")
    executingState = value
    didChangeValue(forKey: "isExecuting")
  }

  private func setFinished(_ value: Bool) {
    willChangeValue(forKey: "isFinished")
    finishedState = value
    didChangeValue(forKey: "isFinished")
  }

  private func completeOperation(path savedPath: String?, error: FlutterError?) {
    getSavedPath(savedPath, error)
    setExecuting(false)
    setFinished(true)
  }

  override func start() {
    if isCancelled {
      setFinished(true)
      return
    }
    setExecuting(true)

    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) {
        data, error in
        if let data {
          self.processImage(data)
        } else {
          let flutterError = FlutterError(
            code: "invalid_image",
            message: error?.localizedDescription,
            details: (error as NSError?)?.domain)
          self.completeOperation(path: nil, error: flutterError)
        }
      }
    } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
      processVideo()
    } else {
      let flutterError = FlutterError(
        code: "invalid_source",
        message: "Invalid media source.",
        details: nil)
      completeOperation(path: nil, error: flutterError)
    }
  }

  private func processImage(_ pickerImageData: Data) {
    var localImage = UIImage(data: pickerImageData)
    if localImage == nil {
      completeOperation(
        path: nil,
        error: FlutterError(
          code: "invalid_image",
          message: "Could not decode image data.",
          details: nil))
      return
    }
    if maxWidth != nil || maxHeight != nil {
      localImage = ImagePickerImageUtil.scaledImage(
        localImage,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        isMetadataAvailable: true)
    }
    let savedPath = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      pickerImageData,
      image: localImage,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: desiredImageQuality)
    completeOperation(path: savedPath, error: nil)
  }

  private func processVideo() {
    let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first
    result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier ?? "") {
      videoURL, error in
      if let error {
        let flutterError = FlutterError(
          code: "invalid_image",
          message: error.localizedDescription,
          details: (error as NSError).domain)
        self.completeOperation(path: nil, error: flutterError)
        return
      }

      guard let videoURL,
        let destination = ImagePickerPhotoAssetUtil.saveVideo(from: videoURL)
      else {
        self.completeOperation(
          path: nil,
          error: FlutterError(
            code: "flutter_image_picker_copy_video_error",
            message: "Could not cache the video file.",
            details: nil))
        return
      }

      self.completeOperation(path: destination.path, error: nil)
    }
  }
}
