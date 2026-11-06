// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Photos
import UIKit
import UniformTypeIdentifiers

/// Helpers for saving picked images and videos to temporary files.
enum ImagePickerPhotoAssetUtil {
  static func getAsset(fromImagePickerInfo info: [String: Any]) -> PHAsset? {
    return info[UIImagePickerController.InfoKey.phAsset.rawValue] as? PHAsset
  }

  /// Saves video to a temporary URL. Returns nil on failure.
  static func saveVideo(from videoURL: URL) -> URL? {
    if !FileManager.default.isReadableFile(atPath: videoURL.path) {
      return nil
    }
    let fileName = videoURL.lastPathComponent
    let destination = URL(fileURLWithPath: temporaryFilePath(fileName))
    do {
      try FileManager.default.copyItem(at: videoURL, to: destination)
    } catch {
      return nil
    }
    return destination
  }

  /// Saves image with correct metadata and extension copied from the original asset.
  /// maxWidth and maxHeight are used only for GIF images.
  /// Returns nil if the image cannot be encoded or saved.
  static func saveImageWithOriginalImageData(
    _ originalImageData: Data?,
    image: UIImage?,
    maxWidth: Double?,
    maxHeight: Double?,
    imageQuality: Double?
  ) -> String? {
    var suffix = kImagePickerDefaultSuffix
    var type = kImagePickerMIMETypeDefault
    var metaData: [String: Any]?
    if let originalImageData {
      type = ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: originalImageData)
      suffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: type) ?? kImagePickerDefaultSuffix
      metaData = ImagePickerMetaDataUtil.getMetaData(fromImageData: originalImageData)
    }
    if type == .gif, let originalImageData {
      let gifInfo = ImagePickerImageUtil.scaledGIFImage(
        originalImageData, maxWidth: maxWidth, maxHeight: maxHeight)
      return saveImage(withMetaData: metaData, gifInfo: gifInfo, suffix: suffix)
    } else {
      return saveImage(
        withMetaData: metaData, image: image, suffix: suffix, type: type,
        imageQuality: imageQuality)
    }
  }

  /// Save image with correct metadata and extension copied from image picker result info.
  /// Returns nil if the image cannot be encoded or saved.
  static func saveImage(
    withPickerInfo info: [String: Any]?, image: UIImage, imageQuality: Double?
  ) -> String? {
    let metaData =
      info?[UIImagePickerController.InfoKey.mediaMetadata.rawValue] as? [String: Any]
    return saveImage(
      withMetaData: metaData, image: image, suffix: kImagePickerDefaultSuffix,
      type: kImagePickerMIMETypeDefault, imageQuality: imageQuality)
  }

  private static func saveImage(
    withMetaData metaData: [String: Any]?, gifInfo: GIFInfo, suffix: String
  ) -> String? {
    let path = temporaryFilePath(suffix)
    return saveImage(withMetaData: metaData, gifInfo: gifInfo, path: path)
  }

  private static func saveImage(
    withMetaData metaData: [String: Any]?,
    image: UIImage?,
    suffix: String,
    type: ImagePickerMIMEType,
    imageQuality: Double?
  ) -> String? {
    // Without encoded data there is nothing to save; an empty file is not a usable image.
    guard
      var data = ImagePickerMetaDataUtil.convert(image, usingType: type, quality: imageQuality),
      !data.isEmpty
    else {
      return nil
    }
    if let metaData {
      if let updatedData = ImagePickerMetaDataUtil.image(fromImage: data, withMetaData: metaData) {
        data = updatedData
      }
    }
    return createFile(data, atPath: temporaryFilePath(suffix))
  }

  static func saveImage(
    withMetaData metaData: [String: Any]?, gifInfo: GIFInfo, path: String
  ) -> String? {
    guard
      let destination = CGImageDestinationCreateWithURL(
        URL(fileURLWithPath: path) as CFURL, UTType.gif.identifier as CFString,
        gifInfo.images.count, nil)
    else {
      return nil
    }

    let frameProperties: [CFString: Any] = [
      kCGImagePropertyGIFDictionary: [
        kCGImagePropertyGIFDelayTime: gifInfo.interval
      ]
    ]

    let gifMetaProperties = NSMutableDictionary()
    if let metaData {
      gifMetaProperties.addEntries(from: metaData)
    }
    // ImageIO dictionaries are immutable, so the nested GIF dictionary has to be
    // copied before the loop count can be written back.
    if let existingGifProperties = gifMetaProperties[kCGImagePropertyGIFDictionary]
      as? NSDictionary,
      let gifProperties = existingGifProperties.mutableCopy() as? NSMutableDictionary
    {
      gifProperties[kCGImagePropertyGIFLoopCount] = 0
      gifMetaProperties[kCGImagePropertyGIFDictionary] = gifProperties
    }

    CGImageDestinationSetProperties(destination, gifMetaProperties)

    for image in gifInfo.images {
      if let cgImage = image.cgImage {
        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
      }
    }

    guard CGImageDestinationFinalize(destination) else {
      // Don't leave a partially written file behind.
      try? FileManager.default.removeItem(atPath: path)
      return nil
    }
    return path
  }

  private static func temporaryFilePath(_ suffix: String) -> String {
    let fileExtension = "image_picker_%@" + suffix
    let guid = ProcessInfo.processInfo.globallyUniqueString
    let tmpFile = String(format: fileExtension, guid)
    return (NSTemporaryDirectory() as NSString).appendingPathComponent(tmpFile)
  }

  static func createFile(_ data: Data, atPath path: String) -> String? {
    guard FileManager.default.createFile(atPath: path, contents: data, attributes: nil) else {
      return nil
    }
    return path
  }
}
