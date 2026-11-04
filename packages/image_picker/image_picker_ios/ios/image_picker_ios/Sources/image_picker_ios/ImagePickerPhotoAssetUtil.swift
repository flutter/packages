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
  static func saveImageWithOriginalImageData(
    _ originalImageData: Data?,
    image: UIImage?,
    maxWidth: NSNumber?,
    maxHeight: NSNumber?,
    imageQuality: NSNumber?
  ) -> String {
    var suffix = kImagePickerDefaultSuffix
    var type = kImagePickerMIMETypeDefault
    var metaData: [String: Any]?
    if let originalImageData {
      type = ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: originalImageData)
      metaData = ImagePickerMetaDataUtil.getMetaData(fromImageData: originalImageData)
      // Formats that can't be written back are saved as JPEG, which has no alpha channel, so one
      // with transparency is saved as PNG instead.
      if type == .other, metaData?[kCGImagePropertyHasAlpha as String] as? Bool == true {
        type = .png
      }
      suffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: type) ?? kImagePickerDefaultSuffix
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
  static func saveImage(
    withPickerInfo info: [String: Any]?, image: UIImage, imageQuality: NSNumber?
  ) -> String {
    let metaData =
      info?[UIImagePickerController.InfoKey.mediaMetadata.rawValue] as? [String: Any]
    return saveImage(
      withMetaData: metaData, image: image, suffix: kImagePickerDefaultSuffix,
      type: kImagePickerMIMETypeDefault, imageQuality: imageQuality)
  }

  private static func saveImage(
    withMetaData metaData: [String: Any]?, gifInfo: GIFInfo, suffix: String
  ) -> String {
    let path = temporaryFilePath(suffix)
    return saveImage(withMetaData: metaData, gifInfo: gifInfo, path: path)
  }

  private static func saveImage(
    withMetaData metaData: [String: Any]?,
    image: UIImage?,
    suffix: String,
    type: ImagePickerMIMEType,
    imageQuality: NSNumber?
  ) -> String {
    var data =
      ImagePickerMetaDataUtil.convert(image, usingType: type, quality: imageQuality) ?? Data()
    if let metaData {
      if let updatedData = ImagePickerMetaDataUtil.image(fromImage: data, withMetaData: metaData) {
        data = updatedData
      }
    }
    return createFile(data, suffix: suffix)
  }

  private static func saveImage(
    withMetaData metaData: [String: Any]?, gifInfo: GIFInfo, path: String
  ) -> String {
    let destination = CGImageDestinationCreateWithURL(
      URL(fileURLWithPath: path) as CFURL, UTType.gif.identifier as CFString, gifInfo.images.count,
      nil)!

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

    CGImageDestinationFinalize(destination)
    return path
  }

  private static func temporaryFilePath(_ suffix: String) -> String {
    let fileExtension = "image_picker_%@" + suffix
    let guid = ProcessInfo.processInfo.globallyUniqueString
    let tmpFile = String(format: fileExtension, guid)
    return (NSTemporaryDirectory() as NSString).appendingPathComponent(tmpFile)
  }

  private static func createFile(_ data: Data, suffix: String) -> String {
    let tmpPath = temporaryFilePath(suffix)
    FileManager.default.createFile(atPath: tmpPath, contents: data, attributes: nil)
    // The Objective-C implementation returned tmpPath even when createFile failed.
    return tmpPath
  }
}
