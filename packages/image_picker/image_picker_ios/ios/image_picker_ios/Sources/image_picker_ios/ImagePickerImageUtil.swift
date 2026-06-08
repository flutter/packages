// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

struct GIFInfo {
    let images: [UIImage]
    let interval: TimeInterval
}

enum ImagePickerImageUtil {
    static func scaledImage(
        _ image: UIImage,
        maxWidth: Double?,
        maxHeight: Double?,
        isMetadataAvailable _: Bool
    ) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let shouldDownscaleWidth = maxWidth.map { $0 < originalWidth } ?? false
        let shouldDownscaleHeight = maxHeight.map { $0 < originalHeight } ?? false
        let shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight

        if !shouldDownscale {
            return image
        }

        let aspectRatio = originalWidth / originalHeight

        var width = maxWidth.map { round($0) } ?? originalWidth
        var height = maxHeight.map { round($0) } ?? originalHeight

        let widthForMaxHeight = height * aspectRatio
        let heightForMaxWidth = width / aspectRatio

        if heightForMaxWidth > height {
            width = round(widthForMaxHeight)
        } else {
            height = round(heightForMaxWidth)
        }

        return drawScaledImage(image, width: width, height: height) ?? image
    }

    static func scaledGIFImage(
        _ data: Data,
        maxWidth: Double?,
        maxHeight: Double?
    ) -> GIFInfo? {
        let gifIdentifier: String
        if #available(iOS 14.0, *) {
            gifIdentifier = UTType.gif.identifier
        } else {
            gifIdentifier = kUTTypeGIF as String
        }

        let options: [String: Any] = [
            kCGImageSourceShouldCache as String: true,
            kCGImageSourceTypeIdentifierHint as String: gifIdentifier,
        ]

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary)
        else {
            return nil
        }

        let numberOfFrames = CGImageSourceGetCount(imageSource)
        if numberOfFrames == 0 {
            return nil
        }

        var images: [UIImage] = []

        var interval: TimeInterval = 0.0
        for index in 0 ..< numberOfFrames {
            guard
                let imageRef = CGImageSourceCreateImageAtIndex(
                    imageSource, index, options as CFDictionary
                )
            else {
                continue
            }

            let properties =
                CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as? [String: Any]
            let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]

            var delay = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
            if delay == nil {
                delay = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double
            }

            if interval == 0.0 {
                interval = delay ?? 0.1
            }

            let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: .up)
            let scaled = scaledImage(
                image, maxWidth: maxWidth, maxHeight: maxHeight, isMetadataAvailable: true
            )

            images.append(scaled)
        }

        return GIFInfo(images: images, interval: interval)
    }

    private static func drawScaledImage(_ image: UIImage, width: Double, height: Double)
        -> UIImage?
    {
        if width <= 0 || height <= 0 {
            return nil
        }
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size, format: image.imageRendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
