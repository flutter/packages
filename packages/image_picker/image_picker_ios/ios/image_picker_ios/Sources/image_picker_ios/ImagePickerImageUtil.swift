// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Animated GIF frames plus the delay interval between them.
final class GIFInfo {
  let images: [UIImage]
  let interval: TimeInterval

  init(images: [UIImage], interval: TimeInterval) {
    self.images = images
    self.interval = interval
  }
}

/// Image scaling helpers used when a max width/height is requested.
enum ImagePickerImageUtil {
  private static func drawScaledImage(_ imageToScale: UIImage?, width: Double, height: Double)
    -> UIImage?
  {
    guard let imageToScale, width > 0, height > 0 else {
      return nil
    }
    // The source format can request an unsupported 10-bit integer bitmap context,
    // producing an empty scaled image. Use a fresh standard-range format while
    // preserving the source scale and opacity.
    let format = UIGraphicsImageRendererFormat()
    format.scale = imageToScale.imageRendererFormat.scale
    format.opaque = imageToScale.imageRendererFormat.opaque
    format.preferredRange = .standard
    let imageRenderer = UIGraphicsImageRenderer(
      size: CGSize(width: width, height: height),
      format: format)
    return imageRenderer.image { rendererContext in
      let cgContext = rendererContext.cgContext
      // Flip vertically to translate between UIKit and Quartz.
      cgContext.translateBy(x: 0, y: height)
      cgContext.scaleBy(x: 1, y: -1)
      if let cgImage = imageToScale.cgImage {
        cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
      }
    }
  }

  /// Resizes the given image to fit within maxWidth (if non-nil) and maxHeight (if non-nil).
  static func scaledImage(
    _ image: UIImage?,
    maxWidth: NSNumber?,
    maxHeight: NSNumber?,
    isMetadataAvailable: Bool
  ) -> UIImage? {
    let originalWidth = image?.size.width ?? 0
    let originalHeight = image?.size.height ?? 0

    let hasMaxWidth = maxWidth != nil
    let hasMaxHeight = maxHeight != nil

    if (originalWidth == maxWidth?.doubleValue && originalHeight == maxHeight?.doubleValue)
      || (!hasMaxWidth && !hasMaxHeight)
    {
      // Nothing to scale.
      return image
    }

    let aspectRatio = originalWidth / originalHeight

    var width =
      hasMaxWidth ? min(round(maxWidth!.doubleValue), originalWidth) : originalWidth
    var height =
      hasMaxHeight ? min(round(maxHeight!.doubleValue), originalHeight) : originalHeight

    let shouldDownscaleWidth = hasMaxWidth && maxWidth!.doubleValue < originalWidth
    let shouldDownscaleHeight = hasMaxHeight && maxHeight!.doubleValue < originalHeight
    let shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight

    if shouldDownscale {
      let widthForMaxHeight = height * aspectRatio
      let heightForMaxWidth = width / aspectRatio

      if heightForMaxWidth > height {
        width = round(widthForMaxHeight)
      } else {
        height = round(heightForMaxWidth)
      }
    }

    guard let image, let cgImage = image.cgImage else {
      return nil
    }

    if !isMetadataAvailable {
      let imageToScale = UIImage(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
      return drawScaledImage(imageToScale, width: width, height: height)
    }

    // Scaling the image always rotate itself based on the current imageOrientation of the original
    // Image. Set to orientationUp for the original image before scaling, so the scaled image doesn't
    // mess up with the pixels.
    let imageToScale = UIImage(cgImage: cgImage, scale: 1, orientation: .up)

    // The image orientation is manually set to UIImageOrientationUp which swapped the aspect ratio in
    // some scenarios. For example, when the original image has orientation left, the horizontal
    // pixels should be scaled to `width` and the vertical pixels should be scaled to `height`. After
    // setting the orientation to up, we end up scaling the horizontal pixels to `height` and vertical
    // to `width`. Below swap will solve this issue.
    if image.imageOrientation == .left || image.imageOrientation == .right
      || image.imageOrientation == .leftMirrored || image.imageOrientation == .rightMirrored
    {
      let temp = width
      width = height
      height = temp
    }
    return drawScaledImage(imageToScale, width: width, height: height)
  }

  /// Resize all gif animation frames.
  static func scaledGIFImage(_ data: Data, maxWidth: NSNumber?, maxHeight: NSNumber?) -> GIFInfo {
    let options: [CFString: Any] = [
      kCGImageSourceShouldCache: true,
      kCGImageSourceTypeIdentifierHint: UTType.gif.identifier,
    ]

    let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary)!

    let numberOfFrames = CGImageSourceGetCount(imageSource)
    var images: [UIImage] = []
    images.reserveCapacity(numberOfFrames)

    var interval: TimeInterval = 0.0
    for index in 0..<numberOfFrames {
      let imageRef = CGImageSourceCreateImageAtIndex(imageSource, index, options as CFDictionary)

      let properties =
        CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as NSDictionary?
      let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? NSDictionary

      var delay = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
      if delay == nil {
        delay = gifProperties?[kCGImagePropertyGIFDelayTime] as? NSNumber
      }

      if interval == 0.0 {
        interval = delay?.doubleValue ?? 0
      }

      var image: UIImage?
      if let imageRef {
        image = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
        image = scaledImage(
          image, maxWidth: maxWidth, maxHeight: maxHeight, isMetadataAvailable: true)
      }
      if let image {
        images.append(image)
      }
    }

    return GIFInfo(images: images, interval: interval)
  }
}
