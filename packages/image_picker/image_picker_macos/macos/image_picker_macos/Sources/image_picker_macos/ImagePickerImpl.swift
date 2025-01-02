// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import PhotosUI

/// An implementation of [image_picker](https://pub.dev/packages/image_picker) for macOS using [PHPicker](https://developer.apple.com/documentation/photokit/phpickerviewcontroller).
///
/// The package [image_picker_macos](https://pub.dev/packages/image_picker_macos) depends on [file_selector_macos](https://pub.dev/packages/file_selector_macos)
/// for picking images, videos, and media. It has limited support for resizing and compression and uses the system file picker, this implementation is used by the Dart plugin
/// to use [PHPickerViewController](https://developer.apple.com/documentation/photokit/phpickerviewcontroller) which is supported on macOS 13.0+
/// otherwise fallback to file selector if unsupported or the user prefers the file selector implementation.
class ImagePickerImpl: NSObject, ImagePickerApi {
  /// Returns `true` if the current macOS version supports this feature.
  ///
  /// `PHPicker` is supported on macOS 13.0+.
  /// For more information, see [PHPickerViewController](https://developer.apple.com/documentation/photokit/phpickerviewcontroller).
  func supportsPHPicker() -> Bool {
    guard #available(macOS 13.0, *) else {
      return false
    }
    return true
  }

  private var pickImagesDelegate: PickImagesDelegate?
  private var pickVideosDelegate: PickVideosDelegate?
  private var pickMediaDelegate: PickMediaDelegate?

  func pickImages(
    options: ImageSelectionOptions, generalOptions: GeneralOptions,
    completion: @escaping (Result<[String], any Error>) -> Void
  ) {
    guard #available(macOS 13.0, *) else {
      completion(
        .failure(
          PigeonError(
            code: "UNSUPPORTED_PHPICKER",
            message:
              "PHPicker is only supported on macOS 13.0 or newer. Use `supportsPHPicker()` to check.",
            details: nil)))
      return
    }

    var config = PHPickerConfiguration()
    config.selectionLimit = Int(generalOptions.limit)
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)

    pickImagesDelegate = PickImagesDelegate(
      completion: completion,
      options: options
    )
    picker.delegate = pickImagesDelegate

    showPHPicker(
      picker,
      noActiveWindow: {
        completion(
          .failure(
            PigeonError(
              code: "WINDOW_NOT_FOUND", message: "No active window to present the picker.",
              details: nil)))
      })
  }

  func pickVideos(
    generalOptions: GeneralOptions, completion: @escaping (Result<[String], any Error>) -> Void
  ) {
    guard #available(macOS 13.0, *) else {
      completion(
        .failure(
          PigeonError(
            code: "UNSUPPORTED_PHPICKER",
            message:
              "PHPicker is only supported on macOS 13.0 or newer. Use `supportsPHPicker()` to check.",
            details: nil)))
      return
    }

    if generalOptions.limit != nil && generalOptions.limit != 1 {
      completion(
        .failure(
          PigeonError(
            code: "UNIMPLEMENTED", message: "Multi-video selection is not implemented", details: nil
          )))
      return
    }

    var config = PHPickerConfiguration()
    config.selectionLimit = 1
    config.filter = .videos

    let picker = PHPickerViewController(configuration: config)
    pickVideosDelegate = PickVideosDelegate(completion: completion)
    picker.delegate = pickVideosDelegate

    showPHPicker(
      picker,
      noActiveWindow: {
        completion(
          .failure(
            PigeonError(
              code: "WINDOW_NOT_FOUND", message: "No active window to present the picker.",
              details: nil)))
      })
  }

  func pickMedia(
    options: MediaSelectionOptions, generalOptions: GeneralOptions,
    completion: @escaping (Result<[String], any Error>) -> Void
  ) {
    guard #available(macOS 13.0, *) else {
      completion(
        .failure(
          PigeonError(
            code: "UNSUPPORTED_PHPICKER",
            message:
              "PHPicker is only supported on macOS 13.0 or newer. Use `supportsPHPicker()` to check.",
            details: nil)))
      return
    }

    var config = PHPickerConfiguration()
    config.selectionLimit = Int(generalOptions.limit)
    config.filter = PHPickerFilter.any(of: [.images, .videos])

    let picker = PHPickerViewController(configuration: config)
    pickMediaDelegate = PickMediaDelegate(completion: completion, options: options)
    picker.delegate = pickMediaDelegate

    showPHPicker(
      picker,
      noActiveWindow: {
        completion(
          .failure(
            PigeonError(
              code: "WINDOW_NOT_FOUND", message: "No active window to present the picker.",
              details: nil)))
      })
  }

  @available(macOS 13, *)
  private func showPHPicker(_ picker: PHPickerViewController, noActiveWindow: @escaping () -> Void)
  {
    guard let window = NSApplication.shared.keyWindow else {
      noActiveWindow()
      return
    }
    // TODO(EchoEllet): IMPORTANT The window size of the picker is smaller than expected, see the video in https://discord.com/channels/608014603317936148/1295165633931120642/1295470850283147335
    window.contentViewController?.presentAsSheet(picker)
  }
}

class PickImagesDelegate: PHPickerViewControllerDelegate {
  private let completion: ((Result<[String], any Error>) -> Void)
  private let options: ImageSelectionOptions

  init(
    completion: @escaping ((Result<[String], any Error>) -> Void), options: ImageSelectionOptions
  ) {
    self.completion = completion
    self.options = options
  }

  @available(macOS 13, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(nil)

    if results.isEmpty {
      completion(.success([]))
      return
    }

    var savedFilePaths: [String] = []

    Task {
      for result in results {
        let itemProvider = result.itemProvider
        guard itemProvider.canLoadObject(ofClass: NSImage.self) else {
          completion(
            .failure(
              PigeonError(
                code: "INVALID_SELECTION", message: "One of the selected items is not an image",
                details: nil)))
          return
        }

        guard
          let tempImagePath = await PickImageHandler(
            completion: completion, options: options
          ).processAndSave(itemProvider: itemProvider)
        else { return }
        savedFilePaths.append(tempImagePath)
      }
      completion(.success(savedFilePaths))
    }
  }
}

// Currently, multi-video selection is unimplemented.
class PickVideosDelegate: PHPickerViewControllerDelegate {
  private let completion: ((Result<[String], any Error>) -> Void)

  init(completion: @escaping ((Result<[String], any Error>) -> Void)) {
    self.completion = completion
  }

  @available(macOS 13, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(nil)

    guard let itemProvider = results.first?.itemProvider else {
      completion(.success([]))
      return
    }

    let canLoadVideo = itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
    if !canLoadVideo {
      completion(
        .failure(
          PigeonError(
            code: "INVALID_SELECTION", message: "The selected item is not a video", details: nil)))
      return
    }

    Task {
      guard
        let tempVideoPath = await PickVideoHandler(completion: completion)
          .processAndSave(itemProvider: itemProvider)
      else { return }

      completion(.success([tempVideoPath]))
    }

  }
}

class PickMediaDelegate: PHPickerViewControllerDelegate {
  private let completion: ((Result<[String], any Error>) -> Void)
  private let options: MediaSelectionOptions

  init(completion: @escaping (Result<[String], any Error>) -> Void, options: MediaSelectionOptions)
  {
    self.completion = completion
    self.options = options
  }

  @available(macOS 13, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(nil)

    if results.isEmpty {
      completion(.success([]))
      return
    }

    var savedFilePaths: [String] = []

    Task {
      for result in results {
        let itemProvider = result.itemProvider

        let canLoadImage = itemProvider.canLoadObject(ofClass: NSImage.self)
        if canLoadImage {
          guard
            let tempImagePath = await PickImageHandler(
              completion: completion, options: options.imageSelectionOptions
            ).processAndSave(itemProvider: itemProvider)
          else { return }
          savedFilePaths.append(tempImagePath)
        }

        let canLoadVideo = itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
        if canLoadVideo {
          guard
            let tempVideoPath = await PickVideoHandler(completion: completion).processAndSave(
              itemProvider: itemProvider)
          else { return }
          savedFilePaths.append(tempVideoPath)
        }
      }

      completion(.success(savedFilePaths))
    }
  }

}

extension NSItemProvider {
  @available(macOS 10.15, *)
  @MainActor
  func loadObject<T: NSItemProviderReading>(ofClass: T.Type) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
      loadObject(ofClass: ofClass) { (object, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let object = object as? T {
          continuation.resume(returning: object)
        } else {
          continuation.resume(throwing: NSError(domain: "INVALID_OBJECT", code: -1, userInfo: nil))
        }
      }
    }
  }
  @available(macOS 13.0, *)
  @MainActor
  func loadDataRepresentation(for contentType: UTType) async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
      loadDataRepresentation(for: contentType) { (data, error) in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let data = data as? Data {
          continuation.resume(returning: data)
        } else {
          continuation.resume(throwing: NSError(domain: "INVALID_OBJECT", code: -1, userInfo: nil))
        }
      }
    }
  }
}

/// Gets the appropriate file type based on whether the image should be compressed.
///
/// - Parameter quality: Determines if the image should be compressed based on the quality.
/// - Returns: The image file type (`png` or `jpeg`).
func imageFileType(quality: Int64?) -> NSBitmapImageRep.FileType {
  let shouldCompress = quality != nil && shouldCompressImage(quality: quality!)
  // TODO(EchoEllet): The picked image can be JPEG even if it can represented as a PNG, should we always store as PNG in case quality is 100 but the image itself is JPEG or other type?
  return shouldCompress ? NSBitmapImageRep.FileType.jpeg : NSBitmapImageRep.FileType.png
}

/// Gets the file extension based from the image file type.
///
/// - Parameter fileType: The image file type.
/// - Returns: The image file extension.
func imageFileExt(fileType: NSBitmapImageRep.FileType) -> String {
  switch fileType {
  case .jpeg: return "jpeg"
  case .png: return "png"
  default:
    fatalError(
      "Case is not covered since only PNG and JPEG will be used: \(String(describing: fileType))")
  }
}

/// Generates a unique image file name with a UUID and the specified file type.
///
/// The file name includes a UUID followed by the appropriate file extension.
/// For example, if the file type is JPEG, the result will be `UUID.jpeg`.
///
/// - Parameter imageFileType: The file type for determining the extension.
/// - Returns: A unique image file name.
func generateUniqueImageFileName(imageFileType: NSBitmapImageRep.FileType) -> String {
  return UUID().uuidString + ".\(imageFileExt(fileType: imageFileType))"
}

/// Generates a unique file path for a temporary image in the system's temporary directory.
///
/// - Parameter imageFileType: The file type of the image (e.g., PNG, JPEG).
/// - Returns: A `URL` representing the unique file path for the temporary image.
func generateTempImageFilePath(imageFileType: NSBitmapImageRep.FileType) -> URL {
  let tempDirectory = FileManager.default.temporaryDirectory

  let uniqueFileName = generateUniqueImageFileName(imageFileType: imageFileType)
  let filePath = tempDirectory.appendingPathComponent(uniqueFileName)
  return filePath
}

/// Shared image handling between `PickImageDelegate` and `PickMediaDelegate`.
class PickImageHandler {
  let completion: ((Result<[String], any Error>) -> Void)
  let options: ImageSelectionOptions

  init(completion: @escaping (Result<[String], any Error>) -> Void, options: ImageSelectionOptions)
  {
    self.completion = completion
    self.options = options
  }

  /// Load an image, process it if needed, copy it to a temporary directory, and return the file path.
  ///
  /// Returns `nil` if an error occurs, and handles.
  @available(macOS 10.15, *)
  func processAndSave(itemProvider: NSItemProvider) async -> String? {
    do {
      let image = try await itemProvider.loadObject(ofClass: NSImage.self)
      guard let processedImage = processImage(image) else { return nil }
      guard let tempImagePath = copyImageToTempDir(processedImage) else { return nil }
      return tempImagePath
    } catch {
      completion(
        .failure(
          PigeonError(
            code: "IMAGE_LOAD_FAILED",
            message: "Error loading image: \(error.localizedDescription)", details: nil)))
      return nil
    }
  }

  /// Copy an image to a temporary directory and return the file path.
  ///
  /// Returns `nil` if an error occurs, and handles.
  private func copyImageToTempDir(_ image: NSImage) -> String? {
    let imageFileType = imageFileType(quality: options.quality)

    guard let tiffData = image.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData),
      let imageData = bitmapRep.representation(using: imageFileType, properties: [:])
    else {
      completion(
        .failure(
          PigeonError(
            code: "IMAGE_CONVERSION_FAILED", message: "Failed to convert NSImage to TIFF data.",
            details: nil)))
      return nil
    }

    let filePath = generateTempImageFilePath(imageFileType: imageFileType)

    do {
      try imageData.write(to: filePath)
      return filePath.pathString()
    } catch {
      completion(
        .failure(
          PigeonError(
            code: "IMAGE_SAVE_FAILED", message: "Error saving image to file: \(error)", details: nil
          )))
      return nil
    }
  }

  /// Resize and compress the image if needed, then return the image.
  ///
  /// Returns `nil` if an error occurs, and handles.
  private func processImage(_ image: NSImage) -> NSImage? {
    do {
      let processedImage = try image.resizedOrOriginal(maxSize: options.maxSize)
        .compressedOrOriginal(quality: options.quality)
      return processedImage
    } catch {
      completion(
        .failure(
          PigeonError(
            code: "IMAGE_PROCESSING_FAILED",
            message: "Error processing image: \(error.localizedDescription)", details: nil)))
      return nil
    }
  }
}

/// Shared image handling between `PickVideosDelegate` and `PickMediaDelegate`.
class PickVideoHandler {
  let completion: ((Result<[String], any Error>) -> Void)

  init(completion: @escaping (Result<[String], any Error>) -> Void) {
    self.completion = completion
  }

  @available(macOS 13.0, *)
  func processAndSave(itemProvider: NSItemProvider) async -> String? {
    do {
      let videoType = UTType.movie
      let tempVideoFileName = generateUniqueVideoFileName(
        videoFileExt: videoType.preferredFilenameExtension ?? "mov")
      let tempVideoUrl = FileManager.default.temporaryDirectory.appendingPathComponent(
        tempVideoFileName)

      let videoData = try await itemProvider.loadDataRepresentation(for: videoType)
      try videoData.write(to: tempVideoUrl)

      let tempVideoPath = tempVideoUrl.pathString()

      return tempVideoPath
    } catch {
      completion(
        .failure(
          PigeonError(
            code: "VIDEO_LOAD_FAILED",
            message: "Error loading a video: \(error.localizedDescription)", details: nil)))
      return nil
    }
  }
}

/// Generates a unique video file name with a UUID and the specified file type.
///
/// The file name includes a UUID followed by the appropriate file extension.
/// For example, if the file type is QuickTime movie, the result will be `UUID.mov`.
///
/// - Parameter videoFileExt: The file extension.
/// - Returns: A unique image file name.
func generateUniqueVideoFileName(videoFileExt: String) -> String {
  return UUID().uuidString + ".\(videoFileExt)"
}

extension URL {
  /// Returns the file path as a `String` for the current `URL`.
  ///
  /// On macOS 13 and later, this method calls `URL.path()`,
  /// while for earlier versions it uses the `URL.path` property.
  ///
  /// Uses `URL.path()` on newer macOS versions to avoid future deprecation warnings for `URL.path`.
  ///
  /// - Returns: A `String` representing the file path.
  func pathString() -> String {
    if #available(macOS 13.0, *) {
      return self.path()
    } else {
      return self.path
    }
  }
}
