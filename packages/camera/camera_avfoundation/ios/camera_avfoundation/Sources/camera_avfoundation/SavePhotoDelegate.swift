// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import Foundation
import ImageIO
import UIKit
import UniformTypeIdentifiers

/// The completion handler block for save photo operations.
/// Can be called from either main queue or IO queue.
/// If success, `path` will be present and `error` will be nil. Otherwise, `path` will be nil and
/// `error` will be present.
/// path - the path for successfully saved photo file.
/// error - photo capture error or IO error.
typealias SavePhotoDelegateCompletionHandler = (String?, Error?) -> Void

/// Delegate object that handles photo capture results.
class SavePhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  /// The file path for the captured photo.
  private let path: String

  /// The queue on which captured photos are written to disk.
  private let ioQueue: DispatchQueue

  /// The JPEG compression quality (1-100), or nil for default quality.
  private let imageQuality: Int64?

  /// The completion handler block for capture and save photo operations.
  let completionHandler: SavePhotoDelegateCompletionHandler

  /// The path for captured photo file.
  /// Exposed for unit tests to verify the captured photo file path.
  var filePath: String {
    path
  }

  /// Initialize a photo capture delegate.
  /// path - the path for captured photo file.
  /// ioQueue - the queue on which captured photos are written to disk.
  /// imageQuality - optional JPEG compression quality (1-100). When nil or 100,
  ///   the original photo data is used without re-encoding.
  /// completionHandler - The completion handler block for save photo operations. Can
  /// be called from either main queue or IO queue.
  init(
    path: String,
    ioQueue: DispatchQueue,
    imageQuality: Int64? = nil,
    completionHandler: @escaping SavePhotoDelegateCompletionHandler
  ) {
    self.path = path
    self.ioQueue = ioQueue
    self.imageQuality = imageQuality
    self.completionHandler = completionHandler
    super.init()
  }

  /// Handler to write captured photo data into a file.
  /// - Parameters:
  ///   - error: The capture error
  ///   - photoDataProvider: A closure that provides photo data
  func handlePhotoCaptureResult(
    error: Error?,
    photoDataProvider: @escaping () -> WritableData?
  ) {
    if let error = error {
      completionHandler(nil, error)
      return
    }

    ioQueue.async { [weak self] in
      guard let strongSelf = self else { return }

      do {
        let data = photoDataProvider()
        try data?.writeToPath(strongSelf.path, options: .atomic)
        strongSelf.completionHandler(strongSelf.path, nil)
      } catch {
        strongSelf.completionHandler(nil, error)
      }
    }
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    handlePhotoCaptureResult(error: error) { [weak self] in
      guard let originalData = photo.fileDataRepresentation() else {
        return nil
      }
      // Only re-encode when a quality below 100 was explicitly requested.
      // The caller (DefaultCamera.captureToFile) only sets imageQuality for
      // JPEG captures, so the data is guaranteed to be JPEG at this point.
      guard let quality = self?.imageQuality, quality < 100 else {
        return originalData
      }
      return Self.reencodeJPEG(data: originalData, quality: quality)
    }
  }

  /// Re-encodes JPEG data at the given quality while preserving EXIF metadata.
  ///
  /// Uses `CGImageDestination` rather than `UIImage.jpegData(compressionQuality:)`
  /// because the latter strips EXIF metadata (GPS, orientation, camera info, etc.).
  ///
  /// - Parameters:
  ///   - data: The original JPEG file data including EXIF metadata.
  ///   - quality: JPEG compression quality from 1 (maximum compression) to 99
  ///     (near-lossless). Values are mapped to the 0.0–1.0 scale used by
  ///     `kCGImageDestinationLossyCompressionQuality`.
  /// - Returns: Re-encoded JPEG data, or the original data if re-encoding fails.
  static func reencodeJPEG(data: Data, quality: Int64) -> Data? {
    // Create an image source to read the pixel data and EXIF metadata.
    guard
      let source = CGImageSourceCreateWithData(data as CFData, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      return data
    }

    // Copy all original EXIF/metadata properties so they are preserved in the output.
    let metadata =
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] ?? [:]

    let mutableData = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        mutableData as CFMutableData,
        UTType.jpeg.identifier as CFString,
        1,  // imageCount: single image
        nil)
    else {
      return data
    }

    var properties = metadata
    properties[kCGImageDestinationLossyCompressionQuality] = CGFloat(quality) / 100.0

    CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)

    guard CGImageDestinationFinalize(destination) else {
      return data
    }

    return mutableData as Data
  }
}
