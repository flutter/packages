// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import image_picker_ios
import UIKit
import XCTest

class ImageUtilTests: XCTestCase {
    private func colorsAreEqual(_ s1: String?, _ s2: String) -> Bool {
        guard let s1 = s1 else { return false }
        let components1 = s1.split(separator: " ").compactMap { Double($0) }
        let components2 = s2.split(separator: " ").compactMap { Double($0) }

        guard components1.count == 4 && components2.count == 4 else { return false }

        for i in 0 ..< 4 {
            if abs(components1[i] - components2[i]) > 0.01 {
                return false
            }
        }
        return true
    }

    private let kColorRepresentation3x2BottomLeftYellow = "1 0.776471 0 1"
    private let kColorRepresentation3x2TopLeftRed = "1 0.0666667 0 1"
    private let kColorRepresentation3x2BottomRightCyan = "0 0.772549 1 1"
    private let kColorRepresentation3x2TopRightBlue = "0 0.0705882 0.996078 1"

    private func colorStringAtPixel(_ image: UIImage, x: Int, y: Int) -> String? {
        guard let cgImage = image.cgImage else { return nil }

        let width = 1
        let height = 1
        var pixel = [UInt8](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Using premultipliedLast.
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &pixel,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.setShouldAntialias(false)
        context.interpolationQuality = .none

        context.draw(
            cgImage,
            in: CGRect(
                x: CGFloat(-x), y: CGFloat(-y), width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)
            )
        )

        let red = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let blue = CGFloat(pixel[2]) / 255.0
        let alpha = CGFloat(pixel[3]) / 255.0

        return CIColor(red: red, green: green, blue: blue, alpha: alpha).stringRepresentation
    }

    func testScaledImage_EqualSizeReturnsSameImage() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(image.size, scaledImage.size)
        XCTAssertTrue(image === scaledImage)
        let scaledWithoutMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: false
        )

        XCTAssertEqual(image.size, scaledWithoutMetadata.size)

        let noConstraintImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertTrue(image === noConstraintImage)

        let widthOnly = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertEqual(image.size.width, widthOnly.size.width)

        let heightOnly = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(image.size.height, heightOnly.size.height)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertTrue(repeated === image)
    }

    func testScaledImage_NilSizeReturnsSameImage() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertTrue(scaledImage === image)
        XCTAssertEqual(scaledImage.size.width, image.size.width)
        XCTAssertEqual(scaledImage.size.height, image.size.height)

        let scaledImageNoMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: false
        )

        XCTAssertTrue(scaledImageNoMetadata === image)

        let scaledWithExactSize = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(scaledWithExactSize.size, image.size)
    }

    func testScaledImage_ShouldBeScaled() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let scaledWidth: Double = 3
        let scaledHeight: Double = 2

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: scaledWidth,
            maxHeight: scaledHeight,
            isMetadataAvailable: true
        )

        XCTAssertEqual(scaledImage.size.width, CGFloat(scaledWidth))
        XCTAssertEqual(scaledImage.size.height, CGFloat(scaledHeight))

        let color = colorStringAtPixel(scaledImage, x: 0, y: 0)
        XCTAssertTrue(
            colorsAreEqual(color, kColorRepresentation3x2BottomLeftYellow),
            "Color \(color ?? "nil") does not match expected"
        )

        let scaledWithoutMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: scaledWidth,
            maxHeight: scaledHeight,
            isMetadataAvailable: false
        )

        XCTAssertNotNil(scaledWithoutMetadata)
        XCTAssertEqual(scaledWithoutMetadata.size.width, CGFloat(scaledWidth))
        XCTAssertEqual(scaledWithoutMetadata.size.height, CGFloat(scaledHeight))

        let noScaleImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(noScaleImage.size.width, image.size.width)
        XCTAssertEqual(noScaleImage.size.height, image.size.height)

        let widthOnlyScaled = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 4,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(widthOnlyScaled.size.width, 4)

        let heightOnlyScaled = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: 4,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(heightOnlyScaled.size.height, 4)
    }

    func testScaledGIFImage_ShouldBeScaled() throws {
        guard let info = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: 3,
            maxHeight: 2
        ) else {
            XCTFail("Failed to scale GIF")
            return
        }

        XCTAssertEqual(info.images.count, 3)
        XCTAssertEqual(info.interval, 1)

        for newImage in info.images {
            XCTAssertEqual(newImage.size.width, 3)
            XCTAssertEqual(newImage.size.height, 2)
        }

        let widthOnly = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: 4,
            maxHeight: nil
        )
        XCTAssertNotNil(widthOnly)
        for image in try XCTUnwrap(widthOnly?.images) {
            XCTAssertLessThanOrEqual(image.size.width, 4)
        }

        let heightOnly = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: nil,
            maxHeight: 4
        )
        XCTAssertNotNil(heightOnly)
        for image in try XCTUnwrap(heightOnly?.images) {
            XCTAssertLessThanOrEqual(image.size.height, 4)
        }

        let noScale = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNotNil(noScale)
        XCTAssertGreaterThan(try XCTUnwrap(noScale?.images.count), 0)

        let invalidData = Data("invalid gif data".utf8)
        let invalidResult = ImagePickerImageUtil.scaledGIFImage(
            invalidData,
            maxWidth: 3,
            maxHeight: 2
        )
        XCTAssertNil(invalidResult)
    }

    func normalizedImage(_ image: UIImage) throws -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case .right:
            transform = transform
                .translatedBy(x: image.size.height, y: 0)
                .rotated(by: .pi / 2)
        case .left:
            transform = transform
                .translatedBy(x: 0, y: image.size.width)
                .rotated(by: -.pi / 2)
        case .down:
            transform = transform
                .translatedBy(x: image.size.width, y: image.size.height)
                .rotated(by: .pi)
        default:
            break
        }

        let newSize: CGSize
        if image.imageOrientation == .left || image.imageOrientation == .right {
            newSize = CGSize(width: image.size.height, height: image.size.width)
        } else {
            newSize = image.size
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        let context = try XCTUnwrap(UIGraphicsGetCurrentContext())

        context.concatenate(transform)

        let cgImage = try XCTUnwrap(image.cgImage)

        if image.imageOrientation == .left || image.imageOrientation == .right {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        } else {
            context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        }

        return try XCTUnwrap(UIGraphicsGetImageFromCurrentImageContext())
    }

    func testScaledImage_ShouldBeCorrectRotation() throws {
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(bundle.url(forResource: "jpgImageWithRightOrientation", withExtension: "jpg"))
        let imageData = try Data(contentsOf: url)
        let image = try XCTUnwrap(UIImage(data: imageData))

        XCTAssertEqual(image.size.width, 130)
        XCTAssertEqual(image.size.height, 174)
        XCTAssertEqual(image.imageOrientation, .right)

        let normalized = try normalizedImage(image)

        let newImage = ImagePickerImageUtil.scaledImage(
            normalized,
            maxWidth: 10,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 10)
        XCTAssertEqual(newImage.size.height, 7)
        XCTAssertEqual(newImage.imageOrientation, .up)
    }

    func testScaledImage_ShouldBeScaledWithNoMetadata() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let scaledWidth: CGFloat = 3
        let scaledHeight: CGFloat = 2

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: scaledWidth,
            maxHeight: scaledHeight,
            isMetadataAvailable: false
        )

        XCTAssertEqual(scaledImage.size.width, scaledWidth)
        XCTAssertEqual(scaledImage.size.height, scaledHeight)

        XCTAssertEqual(
            colorStringAtPixel(scaledImage, x: 0, y: 0),
            kColorRepresentation3x2BottomLeftYellow
        )

        XCTAssertEqual(
            colorStringAtPixel(scaledImage, x: 0, y: Int(scaledHeight - 1)),
            kColorRepresentation3x2TopLeftRed
        )

        XCTAssertEqual(
            colorStringAtPixel(scaledImage, x: Int(scaledWidth - 1), y: 0),
            kColorRepresentation3x2BottomRightCyan
        )

        XCTAssertEqual(
            colorStringAtPixel(scaledImage, x: Int(scaledWidth - 1), y: Int(scaledHeight - 1)),
            kColorRepresentation3x2TopRightBlue
        )
    }

    func testScaledImage_WideImage_ShouldBeScaledBelowMaxHeight() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        XCTAssertEqual(image.size.width, 12)
        XCTAssertEqual(image.size.height, 7)

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 20,
            maxHeight: 6,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 10)
        XCTAssertEqual(newImage.size.height, 6)
    }

    func testScaledImage_WideImage_ShouldBeScaledBelowMaxWidth() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 10,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 10)
        XCTAssertEqual(newImage.size.height, 6)
    }

    func testScaledImage_WideImage_ShouldNotBeScaledAboveOriginaWidthOrHeight() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 100,
            maxHeight: 100,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 12)
        XCTAssertEqual(newImage.size.height, 7)
    }

    func testScaledImage_ImageIsNil() {
        let image: UIImage? = nil

        guard let image = image else {
            return
        }

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 1440,
            maxHeight: 1440,
            isMetadataAvailable: true
        )

        XCTAssertNil(newImage)
    }

    func testScaledImage_TallImage_ShouldBeScaledBelowMaxHeight() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTallTestData) else {
            XCTFail("Image creation failed")
            return
        }

        XCTAssertEqual(image.size.width, 4)
        XCTAssertEqual(image.size.height, 7)

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 5,
            maxHeight: 5,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 3)
        XCTAssertEqual(newImage.size.height, 5)
    }

    func testScaledImage_TallImage_ShouldBeScaledBelowMaxWidth() {
        // Load test image
        guard let image = UIImage(data: ImagePickerTestImages.jpgTallTestData) else {
            XCTFail("Image creation failed")
            return
        }

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 3,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 3)
        XCTAssertEqual(newImage.size.height, 5)
    }

    func testScaledImage_TallImage_ShouldNotBeScaledAboveOriginaWidthOrHeight() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTallTestData) else {
            XCTFail("Image creation failed")
            return
        }

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 10,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(newImage.size.width, 4)
        XCTAssertEqual(newImage.size.height, 7)
    }

    func testScaledImage_ImageMaxWidthZeroAndMaxHeightIsZero() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Image creation failed")
            return
        }

        let newImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 0,
            isMetadataAvailable: true
        )

        XCTAssertNotNil(newImage)
        XCTAssertEqual(newImage.size, image.size)
    }
}
