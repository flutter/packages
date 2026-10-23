// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import UIKit

/// MIME types recognized when reading image data.
enum ImagePickerMIMEType: UInt {
  case png
  case jpeg
  case gif
  case other
}

/// Default suffix used when the original image type cannot be determined.
let kImagePickerDefaultSuffix = ".jpg"
/// Default MIME type used when the original image type cannot be determined.
let kImagePickerMIMETypeDefault = ImagePickerMIMEType.jpeg

private let kFirstByteJPEG: UInt8 = 0xFF
private let kFirstBytePNG: UInt8 = 0x89
private let kFirstByteGIF: UInt8 = 0x47

/// Utilities for reading and writing image metadata and converting image encodings.
enum ImagePickerMetaDataUtil {
  /// Retrieve MIME type by reading the image data. Only some popular types are supported.
  static func getImageMIMEType(fromImageData imageData: Data) -> ImagePickerMIMEType {
    var firstByte: UInt8 = 0
    imageData.copyBytes(to: &firstByte, count: min(1, imageData.count))
    switch firstByte {
    case kFirstByteJPEG:
      return .jpeg
    case kFirstBytePNG:
      return .png
    case kFirstByteGIF:
      return .gif
    default:
      return .other
    }
  }

  /// Returns the corresponding suffix from type, or nil for unknown types.
  static func imageTypeSuffix(from type: ImagePickerMIMEType) -> String? {
    switch type {
    case .jpeg:
      return ".jpg"
    case .png:
      return ".png"
    case .gif:
      return ".gif"
    default:
      return nil
    }
  }

  static func getMetaData(fromImageData imageData: Data) -> [String: Any]? {
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
      return nil
    }
    return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
  }

  /// Creates and returns data for a new image based on `imageData`, but with the given metadata.
  ///
  /// If creating a new image fails, returns nil.
  static func image(fromImage imageData: Data, withMetaData metadata: [String: Any]?) -> Data? {
    let targetData = NSMutableData()
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
      return nil
    }
    guard let sourceType = CGImageSourceGetType(source) else {
      return nil
    }
    guard
      let destination = CGImageDestinationCreateWithData(
        targetData, sourceType, 1, nil)
    else {
      return nil
    }
    CGImageDestinationAddImageFromSource(
      destination, source, 0, metadata as CFDictionary?)
    CGImageDestinationFinalize(destination)
    return targetData as Data
  }

  /// Converts `image` to `Data` with the type provided.
  ///
  /// The quality is for JPEG type only; it defaults to 1. Compressing a non-JPEG type logs a
  /// warning and returns the image with original quality. Converting to GIF is not supported
  /// and falls back to JPEG, matching the Objective-C implementation.
  static func convert(
    _ image: UIImage?, usingType type: ImagePickerMIMEType, quality: NSNumber?
  ) -> Data? {
    guard let image else { return nil }
    if quality != nil && type != .jpeg {
      let suffix = imageTypeSuffix(from: type) ?? ""
      NSLog(
        "image_picker: compressing is not supported for type %@. Returning the image with original quality",
        suffix)
    }

    switch type {
    case .jpeg:
      let qualityFloat: CGFloat = quality != nil ? CGFloat(truncating: quality!) : 1
      return image.jpegData(compressionQuality: qualityFloat)
    case .png:
      return image.pngData()
    default:
      let qualityFloat: CGFloat = quality != nil ? CGFloat(truncating: quality!) : 1
      return image.jpegData(compressionQuality: qualityFloat)
    }
  }
}
