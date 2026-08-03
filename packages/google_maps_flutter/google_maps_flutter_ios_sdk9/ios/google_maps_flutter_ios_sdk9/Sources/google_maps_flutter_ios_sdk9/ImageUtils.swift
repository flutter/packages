// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import UIKit

#if canImport(google_maps_flutter_ios_sdk9_objc)
  import google_maps_flutter_ios_sdk9_objc
#endif

/// Creates a UIImage from a Pigeon bitmap representation.
func makeIcon(
  from platformBitmap: FGMPlatformBitmap?,
  assetProvider: FGMAssetProvider,
  screenScale: CGFloat
) -> UIImage? {
  assert(screenScale > 0, "Screen scale must be greater than 0")

  guard let platformBitmap = platformBitmap else {
    return nil
  }

  let bitmap = platformBitmap.bitmap
  var image: UIImage?

  if let bitmapDefaultMarker = bitmap as? FGMPlatformBitmapDefaultMarker {
    let hue = bitmapDefaultMarker.hue?.doubleValue ?? 0
    image = GMSMarker.markerImage(
      with: UIColor(
        hue: CGFloat(hue) / 360.0,
        saturation: 1.0,
        brightness: 0.7,
        alpha: 1.0))
  } else if let bitmapAsset = bitmap as? FGMPlatformBitmapAsset {
    // Deprecated: This message handling for 'fromAsset' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if let pkg = bitmapAsset.pkg {
      if let key = assetProvider.lookupKey(forAsset: bitmapAsset.name, fromPackage: pkg) {
        image = assetProvider.imageNamed(key)
      }
    } else {
      if let key = assetProvider.lookupKey(forAsset: bitmapAsset.name) {
        image = assetProvider.imageNamed(key)
      }
    }
  } else if let bitmapAssetImage = bitmap as? FGMPlatformBitmapAssetImage {
    // Deprecated: This message handling for 'fromAssetImage' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if let key = assetProvider.lookupKey(forAsset: bitmapAssetImage.name) {
      if let assetImage = assetProvider.imageNamed(key) {
        image = scaledImage(assetImage, scale: bitmapAssetImage.scale)
      }
    }
  } else if let bitmapBytes = bitmap as? FGMPlatformBitmapBytes {
    // Deprecated: This message handling for 'fromBytes' has been replaced by 'bytes'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    image = UIImage(data: bitmapBytes.byteData.data, scale: screenScale)
  } else if let bitmapAssetMap = bitmap as? FGMPlatformBitmapAssetMap {
    if let key = assetProvider.lookupKey(forAsset: bitmapAssetMap.assetName) {
      image = assetProvider.imageNamed(key)
    }
    if let currentImage = image, bitmapAssetMap.bitmapScaling == .auto {
      let width = bitmapAssetMap.width
      let height = bitmapAssetMap.height
      if width != nil || height != nil {
        let tempImage = scaledImage(currentImage, scale: screenScale)
        image = scaledImage(tempImage, width: width, height: height, screenScale: screenScale)
      } else {
        image = scaledImage(currentImage, scale: CGFloat(bitmapAssetMap.imagePixelRatio))
      }
    }
  } else if let bitmapBytesMap = bitmap as? FGMPlatformBitmapBytesMap {
    let bytes = bitmapBytesMap.byteData
    image = UIImage(data: bytes.data, scale: screenScale)
    if let currentImage = image {
      if bitmapBytesMap.bitmapScaling == .auto {
        let width = bitmapBytesMap.width
        let height = bitmapBytesMap.height
        if width != nil || height != nil {
          // Before scaling the image, image must be in screenScale.
          let tempImage = scaledImage(currentImage, scale: screenScale)
          image = scaledImage(tempImage, width: width, height: height, screenScale: screenScale)
        } else {
          image = scaledImage(currentImage, scale: CGFloat(bitmapBytesMap.imagePixelRatio))
        }
      } else {
        // No scaling, load image from bytes without scale parameter.
        image = UIImage(data: bytes.data)
      }
    }
  } else if let pinConfig = bitmap as? FGMPlatformBitmapPinConfig {
    let options = GMSPinImageOptions()
    if let backgroundColor = pinConfig.backgroundColor {
      options.backgroundColor = backgroundColor.toUIColor()
    }
    if let borderColor = pinConfig.borderColor {
      options.borderColor = borderColor.toUIColor()
    }

    var glyph: GMSPinImageGlyph?
    if let glyphText = pinConfig.glyphText {
      let glyphTextColor: UIColor
      if let textColor = pinConfig.glyphTextColor {
        glyphTextColor = textColor.toUIColor()
      } else {
        glyphTextColor = .black
      }
      glyph = GMSPinImageGlyph(text: glyphText, textColor: glyphTextColor)
    } else if let glyphColorValue = pinConfig.glyphColor {
      glyph = GMSPinImageGlyph(glyphColor: glyphColorValue.toUIColor())
    } else if let glyphBitmap = pinConfig.glyphBitmap {
      if let glyphImage = makeIcon(
        from: glyphBitmap, assetProvider: assetProvider, screenScale: screenScale)
      {
        glyph = GMSPinImageGlyph(image: glyphImage)
      }
    }
    options.glyph = glyph
    image = GMSPinImage(options: options)
  }

  return image
}

/// Creates a scaled version of the provided UIImage based on a specified scale factor.
///
/// This method is deprecated within the context of `BitmapDescriptor.fromBytes` handling in the
/// flutter google_maps_flutter_platform_interface package which has been replaced by 'bytes'
/// message handling.
private func scaledImage(_ image: UIImage, scale: Double) -> UIImage {
  if abs(scale - 1.0) > 1e-3 {
    if let cgImage = image.cgImage {
      return UIImage(
        cgImage: cgImage,
        scale: image.scale * CGFloat(scale),
        orientation: image.imageOrientation
      )
    }
  }
  return image
}

/// Creates a scaled version of the provided UIImage based on a specified scale factor.
///
/// If the scale factor differs from the image's current scale by more than a small epsilon-delta
/// (to account for minor floating-point inaccuracies), a new UIImage object is created with the
/// specified scale. Otherwise, the original image is returned.
private func scaledImage(_ image: UIImage, scale: CGFloat) -> UIImage {
  if abs(scale - image.scale) > .ulpOfOne {
    if let cgImage = image.cgImage {
      return UIImage(
        cgImage: cgImage,
        scale: scale,
        orientation: image.imageOrientation
      )
    }
  }
  return image
}

/// Scales an input UIImage to a specified size.
///
/// If the aspect ratio of the input image closely matches the target size, indicated by a
/// small epsilon-delta, the image's scale property is updated instead of resizing the image. If
/// the aspect ratios differ beyond this threshold, the method redraws the image at the target
/// size.
private func scaledImage(_ image: UIImage, to size: CGSize) -> UIImage {
  let originalPixelWidth = image.size.width * image.scale
  let originalPixelHeight = image.size.height * image.scale

  // Return original image if either original image size or target size is so small that
  // image cannot be resized or displayed.
  if originalPixelWidth <= 0 || originalPixelHeight <= 0 || size.width <= 0 || size.height <= 0 {
    return image
  }

  // Check if the image's size, accounting for scale, matches the target size.
  if abs(originalPixelWidth - size.width) <= .ulpOfOne
    && abs(originalPixelHeight - size.height) <= .ulpOfOne
  {
    return image
  }

  // Check if the aspect ratios are approximately equal.
  let originalPixelSize = CGSize(width: originalPixelWidth, height: originalPixelHeight)
  if isScalableWithScaleFactor(from: originalPixelSize, to: size) {
    // Scaled image has close to same aspect ratio,
    // updating image scale instead of resizing image.
    let factor = originalPixelWidth / size.width
    return scaledImage(image, scale: image.scale * factor)
  } else {
    // Aspect ratios differ significantly, resize the image.
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1.0
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    let newImage = renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: size))
    }
    return scaledImage(newImage, scale: image.scale)
  }
}

/// Scales an input UIImage to a specified width and height, preserving aspect ratio if both
/// widht and height are not given.
private func scaledImage(
  _ image: UIImage,
  width: NSNumber?,
  height: NSNumber?,
  screenScale: CGFloat
) -> UIImage {
  if width == nil && height == nil {
    return image
  }

  let targetWidth = width == nil ? image.size.width : CGFloat(width!.doubleValue)
  let targetHeight = height == nil ? image.size.height : CGFloat(height!.doubleValue)

  var calculatedWidth = targetWidth
  var calculatedHeight = targetHeight

  if width != nil && height == nil {
    // Calculate height based on aspect ratio if only width is provided.
    let aspectRatio = image.size.height / image.size.width
    calculatedHeight = (targetWidth * aspectRatio).rounded()
  } else if width == nil && height != nil {
    // Calculate width based on aspect ratio if only height is provided.
    let aspectRatio = image.size.width / image.size.height
    calculatedWidth = (targetHeight * aspectRatio).rounded()
  }

  let targetSize = CGSize(
    width: (calculatedWidth * screenScale).rounded(),
    height: (calculatedHeight * screenScale).rounded()
  )
  return scaledImage(image, to: targetSize)
}

func isScalableWithScaleFactor(from originalSize: CGSize, to targetSize: CGSize) -> Bool {
  // Select the scaling factor based on the longer side to have good precision.
  let scaleFactor =
    (originalSize.width > originalSize.height)
    ? (targetSize.width / originalSize.width)
    : (targetSize.height / originalSize.height)

  // Calculate the scaled dimensions.
  let scaledWidth = originalSize.width * scaleFactor
  let scaledHeight = originalSize.height * scaleFactor

  // Check if the scaled dimensions are within a one-pixel
  // threshold of the target dimensions.
  let widthWithinThreshold = abs(scaledWidth - targetSize.width) <= 1.0
  let heightWithinThreshold = abs(scaledHeight - targetSize.height) <= 1.0

  // The image is considered scalable with scale factor
  // if both dimensions are within the threshold.
  return widthWithinThreshold && heightWithinThreshold
}
