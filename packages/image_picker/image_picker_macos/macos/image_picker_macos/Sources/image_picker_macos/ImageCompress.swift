// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

/// Determines if the image should be compressed based on the quality.
///
/// - Parameter quality: The quality level (0-100). A quality less than 100 indicates compression.
/// - Returns: Whether the image should be compressed.
func shouldCompressImage(quality: Int64) -> Bool {
  return quality != 100
}

extension NSImage {
  /// Compresses the image to the specified quality.
  ///
  /// - Parameter quality: The quality of the image (0 to 100).
  /// - Returns: An optional `NSImage` that represents the compressed image.
  func compressed(quality: Int64) throws -> NSImage {
    guard let tiffData = self.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData)
    else {
      // TODO(EchoEllet): Is there a convention for the error code? ImageConversionError or IMAGE_CONVERSION_ERROR or image-conversion-error. Update all codes.
      throw PigeonError(
        code: "ImageConversionError", message: "Failed to convert NSImage to TIFF data.",
        details: nil)
    }

    // Convert quality from 0-100 to 0.0-1.0
    let compressionQuality = max(0.0, min(1.0, Double(quality) / 100.0))

    guard
      let compressedData = bitmapRep.representation(
        using: .jpeg, properties: [.compressionFactor: compressionQuality])
    else {
      throw PigeonError(
        code: "CompressionError", message: "Failed to compress image.", details: nil)
    }

    guard let compressedImage = NSImage(data: compressedData) else {
      throw PigeonError(
        code: "ImageCreationError", message: "Failed to create NSImage from compressed data.",
        details: nil)
    }

    return compressedImage
  }

  /// Returns the original image or a compressed version based on the specified quality.
  ///
  /// - Parameter quality: The compression quality as an optional value.
  ///                     If `nil` or if compression is not needed, the original image is returned.
  /// - Returns: The original or compressed `NSImage`.
  func compressedOrOriginal(quality: Int64?) throws -> NSImage {
    guard let quality = quality else {
      return self
    }
    if !shouldCompressImage(quality: quality) {
      return self
    }
    return try compressed(quality: quality)
  }
}
