// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit
import UniformTypeIdentifiers

enum ImagePickerMIMEType: UInt {
    case png
    case jpeg
    case gif
    case other
}

enum ImagePickerMetaDataUtil {
    static let defaultSuffix = ".jpg"
    static let defaultMIMEType: ImagePickerMIMEType = .jpeg

    static func getImageMIMEType(from imageData: Data) -> ImagePickerMIMEType {
        if imageData.isEmpty {
            return .other
        }
        var firstByte: UInt8 = 0
        imageData.copyBytes(to: &firstByte, count: 1)
        switch firstByte {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        default:
            return .other
        }
    }

    static func imageTypeSuffix(from type: ImagePickerMIMEType) -> String? {
        switch type {
        case .jpeg:
            return ".jpg"
        case .png:
            return ".png"
        case .gif:
            return ".gif"
        case .other:
            return nil
        }
    }

    static func getMetaData(from imageData: Data) -> [String: Any]? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
    }

    static func image(from imageData: Data, with metadata: [String: Any]) -> Data? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        let targetData = NSMutableData()
        guard let sourceType = CGImageSourceGetType(source),
              let destination = CGImageDestinationCreateWithData(targetData, sourceType, 1, nil)
        else {
            return nil
        }
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return targetData as Data
    }

    static func convertImage(
        _ image: UIImage,
        using type: ImagePickerMIMEType,
        quality: Double?
    ) -> Data? {
        if quality != nil, type != .jpeg {
            print(
                "image_picker: compressing is not supported for type \(type). Returning the image with original quality"
            )
        }

        switch type {
        case .jpeg:
            let qualityFloat = CGFloat(quality ?? 1.0)
            return image.jpegData(compressionQuality: qualityFloat)
        case .png:
            return image.pngData()
        default:
            let qualityFloat = CGFloat(quality ?? 1.0)
            return image.jpegData(compressionQuality: qualityFloat)
        }
    }
}
