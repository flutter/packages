// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

extension NSImage {
  /// Resizes the image to fit within the specified max size (width and height),
  /// while maintaining the aspect ratio.
  ///
  /// - Parameter maxSize: The maximum allowed size (width and height).
  /// - Returns: A resized `NSImage` that fits within the max dimensions.
  func resized(maxSize: NSSize) -> NSImage {
    let originalSize = self.size

    let widthScale = maxSize.width / originalSize.width
    let heightScale = maxSize.height / originalSize.height

    let scaleFactor = min(widthScale, heightScale)

    let newSize = NSSize(
      width: originalSize.width * scaleFactor,
      height: originalSize.height * scaleFactor
    )

    let resizedImage = NSImage(size: newSize, flipped: false) { rect in
      self.draw(
        in: rect, from: NSRect(origin: .zero, size: originalSize), operation: .sourceOver,
        fraction: 1.0)
      return true
    }
    return resizedImage
  }

  /// Returns the image resized to fit within the specified maximum size.
  ///
  /// If the image needs resizing based on `maxSize`, it is resized while maintaining
  /// its aspect ratio. Otherwise, the original image is returned.
  ///
  /// - Parameter maxSize: The maximum width and height for the image. Return the original image if `nil`.
  /// - Returns: A resized `NSImage` or the original image.
  func resizedOrOriginal(maxSize: MaxSize?) -> NSImage {
    guard let maxSize = maxSize else {
      return self
    }
    return shouldResize(maxSize: maxSize)
      ? self.resized(maxSize: maxSize.toNSSize(image: self)) : self
  }

  /// Checks if the image needs resizing based on the provided max size.
  /// Returns `false` if the max size has no dimensions or if the image is within the limits.
  ///
  /// - Parameter maxSize: The maximum allowable size for the image.
  /// - Returns: `true` if the image exceeds either the max width or height; otherwise, `false`.
  func shouldResize(maxSize: MaxSize) -> Bool {
    if !maxSize.hasAnyDimension() {
      return false
    }
    let imageSize = self.size

    if let maxWidth = maxSize.width, imageSize.width > maxWidth {
      return true
    }
    if let maxHeight = maxSize.height, imageSize.height > maxHeight {
      return true
    }

    // No resizing needed if both dimensions are within the limits
    return false
  }
}

extension MaxSize {
  /// Returns `true` if either width or height is not nil.
  func hasAnyDimension() -> Bool {
    return self.width != nil || self.height != nil
  }

  /// Converts a `MaxSize`, which contains optional width and height values,
  /// into a non-optional `NSSize`. If either the width or height is not provided (`nil`),
  /// It defaults to the original image size.
  ///
  /// - Parameter image: An `NSImage` used to provide default width and height values
  ///   if the corresponding dimensions in `MaxSize` are not defined.
  /// - Returns: A `NSSize` with the appropriate width and height (non-optional).
  func toNSSize(image: NSImage) -> NSSize {
    let imageSize = image.size
    return NSSize(
      width: self.width ?? imageSize.width,
      height: self.height ?? imageSize.width
    )
  }
}
