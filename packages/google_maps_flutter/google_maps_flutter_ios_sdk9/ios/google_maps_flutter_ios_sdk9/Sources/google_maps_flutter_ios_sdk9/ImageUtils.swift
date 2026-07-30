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
    let hue = bitmapDefaultMarker.hue.doubleValue
    image = GMSMarker.markerImage(with: UIColor(hue: CGFloat(hue) / 360.0,
                                               saturation: 1.0,
                                               brightness: 0.7,
                                               alpha: 1.0))
  } else if let bitmapAsset = bitmap as? FGMPlatformBitmapAsset {
    // Deprecated: This message handling for 'fromAsset' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if let pkg = bitmapAsset.pkg {
      if let key = assetProvider.lookupKey(forAsset: bitmapAsset.name, fromPackage: pkg) {
        image = assetProvider.image(named: key)
      }
    } else {
      if let key = assetProvider.lookupKey(forAsset: bitmapAsset.name) {
        image = assetProvider.image(named: key)
      }
    }
  } else if let bitmapAssetImage = bitmap as? FGMPlatformBitmapAssetImage {
    // Deprecated: This message handling for 'fromAssetImage' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if let key = assetProvider.lookupKey(forAsset: bitmapAssetImage.name) {
      if let assetImage = assetProvider.image(named: key) {
        image = scaledImage(assetImage, scale: bitmapAssetImage.scale.doubleValue)
      }
    }
  } else if let bitmapBytes = bitmap as? FGMPlatformBitmapBytes {
    // Deprecated: This message handling for 'fromBytes' has been replaced by 'bytes'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    image = UIImage(data: bitmapBytes.byteData.data, scale: screenScale)
  } else if let bitmapAssetMap = bitmap as? FGMPlatformBitmapAssetMap {
    if let key = assetProvider.lookupKey(forAsset: bitmapAssetMap.assetName) {
      image = assetProvider.image(named: key)
    }
    if let currentImage = image, bitmapAssetMap.bitmapScaling == .auto {
      let width = bitmapAssetMap.width
      let height = bitmapAssetMap.height
      if width != nil || height != nil {
        let tempImage = scaledImage(currentImage, scale: screenScale)
        image = scaledImage(tempImage, width: width, height: height, screenScale: screenScale)
      } else {
        image = scaledImage(currentImage, scale: CGFloat(bitmapAssetMap.imagePixelRatio.doubleValue))
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
          let tempImage = scaledImage(currentImage, scale: screenScale)
          image = scaledImage(tempImage, width: width, height: height, screenScale: screenScale)
        } else {
          image = scaledImage(currentImage, scale: CGFloat(bitmapBytesMap.imagePixelRatio.doubleValue))
        }
      }
    }
  } else if let pinConfig = bitmap as? FGMPlatformBitmapPinConfig {
    let options = GMSPinImageOptions()
    if let backgroundColor = pinConfig.backgroundColor {
      options.backgroundColor = color(from: backgroundColor)
    }
    if let borderColor = pinConfig.borderColor {
      options.borderColor = color(from: borderColor)
    }

    var glyph: GMSPinImageGlyph?
    if let glyphText = pinConfig.glyphText {
      let glyphTextColor: UIColor
      if let textColor = pinConfig.glyphTextColor {
        glyphTextColor = color(from: textColor)
      } else {
        glyphTextColor = .black
      }
      glyph = GMSPinImageGlyph(text: glyphText, textColor: glyphTextColor)
    } else if let glyphColorValue = pinConfig.glyphColor {
      glyph = GMSPinImageGlyph(glyphColor: color(from: glyphColorValue))
    } else if let glyphBitmap = pinConfig.glyphBitmap {
      if let glyphImage = icon(from: glyphBitmap, assetProvider: assetProvider, screenScale: screenScale) {
        glyph = GMSPinImageGlyph(image: glyphImage)
      }
    }
    options.glyph = glyph
    image = GMSPinImage.pinImage(with: options)
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

private func scaledImage(_ image: UIImage, size: CGSize) -> UIImage {
  let originalPixelWidth = image.size.width * image.scale
  let originalPixelHeight = image.size.height * image.scale

  if originalPixelWidth <= 0 || originalPixelHeight <= 0 || size.width <= 0 || size.height <= 0 {
    return image
  }

  if abs(originalPixelWidth - size.width) <= .ulpOfOne &&
     abs(originalPixelHeight - size.height) <= .ulpOfOne {
    return image
  }

  let originalPixelSize = CGSize(width: originalPixelWidth, height: originalPixelHeight)
  if isScalableWithScaleFactor(from: originalPixelSize, targetSize: size) {
    let factor = originalPixelWidth / size.width
    return scaledImage(image, scale: image.scale * factor)
  } else {
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
    let aspectRatio = image.size.height / image.size.width
    calculatedHeight = (targetWidth * aspectRatio).rounded()
  } else if width == nil && height != nil {
    let aspectRatio = image.size.width / image.size.height
    calculatedWidth = (targetHeight * aspectRatio).rounded()
  }

  let targetSize = CGSize(
    width: (calculatedWidth * screenScale).rounded(),
    height: (calculatedHeight * screenScale).rounded()
  )
  return scaledImage(image, size: targetSize)
}

func isScalableWithScaleFactor(from originalSize: CGSize, targetSize: CGSize) -> Bool {
  let scaleFactor = (originalSize.width > originalSize.height)
    ? (targetSize.width / originalSize.width)
    : (targetSize.height / originalSize.height)

  let scaledWidth = originalSize.width * scaleFactor
  let scaledHeight = originalSize.height * scaleFactor

  let widthWithinThreshold = abs(scaledWidth - targetSize.width) <= 1.0
  let heightWithinThreshold = abs(scaledHeight - targetSize.height) <= 1.0

  return widthWithinThreshold && heightWithinThreshold
}
