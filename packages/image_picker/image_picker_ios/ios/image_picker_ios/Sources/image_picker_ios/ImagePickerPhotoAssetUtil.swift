// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Photos
import PhotosUI
import UIKit
import UniformTypeIdentifiers

enum ImagePickerPhotoAssetUtil {
    static func getAsset(from info: [UIImagePickerController.InfoKey: Any]) -> PHAsset? {
        return info[.phAsset] as? PHAsset
    }

    static func saveVideo(from videoURL: URL) -> URL? {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: videoURL.path, isDirectory: &isDirectory),
              !isDirectory.boolValue,
              FileManager.default.isReadableFile(atPath: videoURL.path)
        else {
            return nil
        }
        let fileName = videoURL.lastPathComponent
        guard let destinationPath = temporaryFilePath(for: fileName) else {
            return nil
        }
        let destination = URL(fileURLWithPath: destinationPath)
        do {
            try FileManager.default.copyItem(at: videoURL, to: destination)
        } catch {
            return nil
        }
        return destination
    }

    static func saveImage(
        with originalImageData: Data?,
        image: UIImage,
        maxWidth: Double?,
        maxHeight: Double?,
        imageQuality: Double?
    ) -> String? {
        var suffix = ImagePickerMetaDataUtil.defaultSuffix
        var type = ImagePickerMetaDataUtil.defaultMIMEType
        var metaData: [String: Any]?

        if let originalImageData = originalImageData {
            type = ImagePickerMetaDataUtil.getImageMIMEType(from: originalImageData)
            suffix =
                ImagePickerMetaDataUtil.imageTypeSuffix(from: type) ?? ImagePickerMetaDataUtil.defaultSuffix
            metaData = ImagePickerMetaDataUtil.getMetaData(from: originalImageData)
        }

        if type == .gif, let originalImageData = originalImageData {
            let gifInfo = ImagePickerImageUtil.scaledGIFImage(
                originalImageData,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )

            return saveImage(with: metaData, gifInfo: gifInfo, suffix: suffix)
        } else {
            let scaledImage = ImagePickerImageUtil.scaledImage(
                image,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                isMetadataAvailable: metaData != nil
            )

            return saveImage(
                with: metaData,
                image: scaledImage,
                suffix: suffix,
                type: type,
                imageQuality: imageQuality
            )
        }
    }

    static func saveImage(
        with info: [UIImagePickerController.InfoKey: Any]?,
        image: UIImage,
        imageQuality: Double?
    ) -> String? {
        let metaData = info?[.mediaMetadata] as? [String: Any]
        return saveImage(
            with: metaData,
            image: image,
            suffix: ImagePickerMetaDataUtil.defaultSuffix,
            type: ImagePickerMetaDataUtil.defaultMIMEType,
            imageQuality: imageQuality
        )
    }

    private static func saveImage(
        with metaData: [String: Any]?,
        gifInfo: GIFInfo?,
        suffix: String
    ) -> String? {
        guard let path = temporaryFilePath(for: suffix) else {
            return nil
        }
        return saveImage(with: metaData, gifInfo: gifInfo, path: path)
    }

    private static func saveImage(
        with metaData: [String: Any]?,
        image: UIImage,
        suffix: String,
        type: ImagePickerMIMEType,
        imageQuality: Double?
    ) -> String? {
        guard var data = ImagePickerMetaDataUtil.convertImage(image, using: type, quality: imageQuality)
        else {
            return nil
        }
        if let metaData = metaData,
           let updatedData = ImagePickerMetaDataUtil.image(from: data, with: metaData)
        {
            data = updatedData
        }

        return createFile(data, suffix: suffix)
    }

    private static func saveImage(
        with metaData: [String: Any]?,
        gifInfo: GIFInfo?,
        path: String
    ) -> String? {
        guard let gifInfo = gifInfo else { return nil }

        let identifier: String
        if #available(iOS 14.0, *) {
            identifier = UTType.gif.identifier
        } else {
            identifier = "com.compuserve.gif"
        }

        let imageType = identifier as CFString
        guard
            let destination = CGImageDestinationCreateWithURL(
                URL(fileURLWithPath: path) as CFURL, imageType, gifInfo.images.count, nil
            )
        else {
            return nil
        }

        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: gifInfo.interval,
            ],
        ]

        var gifMetaProperties = metaData ?? [:]
        var gifProperties =
            gifMetaProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] ?? [:]
        gifProperties[kCGImagePropertyGIFLoopCount as String] = 0
        gifMetaProperties[kCGImagePropertyGIFDictionary as String] = gifProperties

        CGImageDestinationSetProperties(destination, gifMetaProperties as CFDictionary)

        for image in gifInfo.images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return path
    }

    private static func temporaryFilePath(for suffix: String) -> String? {
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let tmpFile = String(format: "image_picker_%@%@", guid, suffix)
        let tmpDirectory = NSTemporaryDirectory()
        return (tmpDirectory as NSString).appendingPathComponent(tmpFile)
    }

    private static func createFile(_ data: Data, suffix: String) -> String? {
        guard let tmpPath = temporaryFilePath(for: suffix) else {
            return nil
        }
        if FileManager.default.createFile(atPath: tmpPath, contents: data, attributes: nil) {
            return tmpPath
        }
        return nil
    }
}
