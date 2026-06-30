// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import image_picker_ios
import UIKit
import XCTest

class ImagePickerImageUtilTests: XCTestCase {
    func testScaledImage_Parameterized() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData)) // 12x7
        let testCases: [(maxWidth: Double?, maxHeight: Double?, expectedWidth: CGFloat, expectedHeight: CGFloat)] = [
            (5, nil, 5, 3),
            (nil, 4, 7, 4),
            (6, 6, 6, 4),
            (10, 2, 3, 2),
            (20, 20, 12, 7),
            (nil, nil, 12, 7),
            (0, 5, 12, 7),
            (5, 0, 12, 7),
        ]

        for testCase in testCases {
            let scaled = ImagePickerImageUtil.scaledImage(
                image, maxWidth: testCase.maxWidth, maxHeight: testCase.maxHeight, isMetadataAvailable: false
            )
            XCTAssertEqual(scaled.size.width, testCase.expectedWidth, accuracy: 0.5, "Width failed for \(testCase)")
            XCTAssertEqual(scaled.size.height, testCase.expectedHeight, accuracy: 0.5, "Height failed for \(testCase)")
        }
    }

    func testScaledImage_ShouldReturnOriginalIfSizeIsSame() throws {
        let data = ImagePickerTestImages.jpgTestData
        let image = try XCTUnwrap(UIImage(data: data))

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(image, scaledImage)
    }

    func testScaledImage_ShouldReturnOriginalIfSizeIsNil() throws {
        let data = ImagePickerTestImages.jpgTestData
        let image = try XCTUnwrap(UIImage(data: data))

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertEqual(image, scaledImage)
    }

    func testScaledImage_ShouldDownscaleWidth() throws {
        let data = ImagePickerTestImages.jpgTestData
        let image = try XCTUnwrap(UIImage(data: data))
        let originalWidth = image.size.width

        let maxWidth = originalWidth / 2.0
        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertEqual(scaledImage.size.width, maxWidth, accuracy: 1.0)
    }

    func testScaledImage_ShouldDownscaleHeight() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let originalHeight = image.size.height
        let maxHeight = originalHeight / 2.0

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(scaledImage.size.height, maxHeight + 1.0)

        XCTAssertLessThanOrEqual(scaledImage.size.width, image.size.width)

        let expectedRatio = image.size.width / image.size.height
        let actualRatio = scaledImage.size.width / scaledImage.size.height

        XCTAssertEqual(expectedRatio, actualRatio, accuracy: 0.15)

        let scaledNoMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: maxHeight,
            isMetadataAvailable: false
        )

        XCTAssertLessThanOrEqual(scaledNoMetadata.size.height, maxHeight + 1.0)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(repeated.size.height, maxHeight + 1.0)
    }

    func testScaledImage_ShouldRespectAspectRatio_WhenWidthIsLimiting() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let maxWidth = image.size.width / 2.0
        let maxHeight = image.size.height

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(scaledImage.size.width, maxWidth + 1.0)

        XCTAssertLessThanOrEqual(scaledImage.size.height, image.size.height)

        let expectedRatio = image.size.width / image.size.height
        let actualRatio = scaledImage.size.width / scaledImage.size.height

        XCTAssertEqual(expectedRatio, actualRatio, accuracy: 0.25)

        XCTAssertGreaterThan(scaledImage.size.width, 0)
        XCTAssertGreaterThan(scaledImage.size.height, 0)

        let scaledNoMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: false
        )

        XCTAssertLessThanOrEqual(scaledNoMetadata.size.width, maxWidth + 1.0)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(repeated.size.width, maxWidth + 1.0)
    }

    func testScaledImage_ShouldRespectAspectRatio_WhenHeightIsLimiting() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let maxWidth = image.size.width
        let maxHeight = image.size.height / 2.0

        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(scaledImage.size.height, maxHeight + 1.0)

        let expectedRatio = image.size.width / image.size.height
        let actualRatio = scaledImage.size.width / scaledImage.size.height

        XCTAssertEqual(expectedRatio, actualRatio, accuracy: 0.1)

        XCTAssertLessThanOrEqual(scaledImage.size.width, image.size.width)

        let scaledNoMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: false
        )

        XCTAssertLessThanOrEqual(scaledNoMetadata.size.height, maxHeight + 1.0)

        let widthOnly = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertGreaterThan(widthOnly.size.width, 0)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(repeated.size.height, maxHeight + 1.0)
    }

    func testScaledImage_WithOrientation() {
        guard let baseImage = UIImage(data: ImagePickerTestImages.jpgTestData),
              let cgImage = baseImage.cgImage
        else {
            XCTFail("Failed to create UIImage")
            return
        }

        let leftImage = UIImage(cgImage: cgImage, scale: 1, orientation: .left)

        let maxWidth = leftImage.size.width / 2.0
        let maxHeight = leftImage.size.height / 2.0

        let scaledImage = ImagePickerImageUtil.scaledImage(
            leftImage,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(scaledImage.size.width, maxWidth + 1.0)
        XCTAssertLessThanOrEqual(scaledImage.size.height, maxHeight + 1.0)

        let originalRatio = leftImage.size.width / leftImage.size.height
        let scaledRatio = scaledImage.size.width / scaledImage.size.height

        XCTAssertEqual(originalRatio, scaledRatio, accuracy: 0.15)

        XCTAssertGreaterThan(scaledImage.size.width, 0)
        XCTAssertGreaterThan(scaledImage.size.height, 0)

        let repeated = ImagePickerImageUtil.scaledImage(
            leftImage,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(repeated.size.width, maxWidth + 1.0)
    }

    func testScaledImage_InvalidDimensionsReturnsOriginal() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let zeroBoth = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 0,
            isMetadataAvailable: true
        )

        XCTAssertEqual(zeroBoth.size, image.size)
        XCTAssertTrue(zeroBoth === image)

        let zeroWidth = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(zeroWidth.size, image.size)
        XCTAssertTrue(zeroWidth === image)

        let zeroHeight = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 10,
            maxHeight: 0,
            isMetadataAvailable: true
        )

        XCTAssertEqual(zeroHeight.size, image.size)
        XCTAssertTrue(zeroHeight === image)

        let nilAndZero = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: 0,
            isMetadataAvailable: false
        )

        XCTAssertEqual(nilAndZero.size, image.size)

        let zeroWithMetadataFalse = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 0,
            isMetadataAvailable: false
        )

        XCTAssertEqual(zeroWithMetadataFalse.size, image.size)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 0,
            isMetadataAvailable: true
        )

        XCTAssertTrue(repeated === image)
    }

    func testScaledGIFImage_ShouldMaintainFrameCount() {
        let data = ImagePickerTestImages.gifTestData

        let info = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: 5,
            maxHeight: 5
        )

        XCTAssertNotNil(info)
        XCTAssertEqual(info?.images.count, 3)
        XCTAssertGreaterThan(info?.interval ?? 0, 0)

        if let images = info?.images {
            for image in images {
                XCTAssertLessThanOrEqual(image.size.width, 5)
                XCTAssertLessThanOrEqual(image.size.height, 5)
            }
        }

        let noScaleInfo = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: nil,
            maxHeight: nil
        )

        XCTAssertNotNil(noScaleInfo)
        XCTAssertEqual(noScaleInfo?.images.count, 3)
        XCTAssertGreaterThan(noScaleInfo?.interval ?? 0, 0)

        let widthOnly = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: 4,
            maxHeight: nil
        )

        XCTAssertNotNil(widthOnly)
        XCTAssertEqual(widthOnly?.images.count, 3)

        let heightOnly = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: nil,
            maxHeight: 4
        )

        XCTAssertNotNil(heightOnly)
        XCTAssertEqual(heightOnly?.images.count, 3)

        let invalidData = Data("invalid gif data".utf8)
        let invalidResult = ImagePickerImageUtil.scaledGIFImage(
            invalidData,
            maxWidth: 5,
            maxHeight: 5
        )

        XCTAssertNil(invalidResult)

        let repeated = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: 5,
            maxHeight: 5
        )

        XCTAssertNotNil(repeated)
        XCTAssertEqual(repeated?.images.count, 3)
    }

    func testScaledGIFImage_InvalidDataReturnsNil() {
        let stringData = "Not a gif".data(using: .utf8) ?? Data()
        let result1 = ImagePickerImageUtil.scaledGIFImage(
            stringData,
            maxWidth: 5,
            maxHeight: 5
        )
        XCTAssertNil(result1)

        let emptyData = Data()
        let result2 = ImagePickerImageUtil.scaledGIFImage(
            emptyData,
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNil(result2)

        let randomData = Data([0x01, 0x02, 0x03, 0x04])
        let result3 = ImagePickerImageUtil.scaledGIFImage(
            randomData,
            maxWidth: 3,
            maxHeight: 3
        )
        XCTAssertNil(result3)

        let fakeGIFHeader = Data([0x47, 0x49, 0x46, 0x00])
        let result4 = ImagePickerImageUtil.scaledGIFImage(
            fakeGIFHeader,
            maxWidth: 10,
            maxHeight: 10
        )
        XCTAssertNil(result4)

        let result5 = ImagePickerImageUtil.scaledGIFImage(
            stringData,
            maxWidth: nil,
            maxHeight: 10
        )
        XCTAssertNil(result5)

        let result6 = ImagePickerImageUtil.scaledGIFImage(
            stringData,
            maxWidth: 5,
            maxHeight: 5
        )
        XCTAssertNil(result6)
    }

    func testScaledGIFImage_ShouldHandleNoDelayInfo() {
        let data = ImagePickerTestImages.gifTestData

        let info = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: nil,
            maxHeight: nil
        )

        XCTAssertNotNil(info)
        XCTAssertGreaterThan(info?.interval ?? 0, 0)

        let scaledInfo = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: 3,
            maxHeight: 2
        )

        XCTAssertNotNil(scaledInfo)
        XCTAssertGreaterThan(scaledInfo?.interval ?? 0, 0)

        if let images = scaledInfo?.images {
            for image in images {
                XCTAssertLessThanOrEqual(image.size.width, 3)
                XCTAssertLessThanOrEqual(image.size.height, 2)
            }
        }

        let widthOnly = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: 4,
            maxHeight: nil
        )

        XCTAssertNotNil(widthOnly)
        XCTAssertGreaterThan(widthOnly?.interval ?? 0, 0)

        let heightOnly = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: nil,
            maxHeight: 4
        )

        XCTAssertNotNil(heightOnly)
        XCTAssertGreaterThan(heightOnly?.interval ?? 0, 0)

        let invalidData = Data("invalid gif data".utf8)
        let invalidResult = ImagePickerImageUtil.scaledGIFImage(
            invalidData,
            maxWidth: 3,
            maxHeight: 2
        )

        XCTAssertNil(invalidResult)

        let repeated = ImagePickerImageUtil.scaledGIFImage(
            data,
            maxWidth: nil,
            maxHeight: nil
        )

        XCTAssertNotNil(repeated)
        XCTAssertGreaterThan(repeated?.interval ?? 0, 0)
    }

    func testDrawScaledImage_ZeroSize_ReturnsOriginalImage() {
        guard let image = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let zeroWidth = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 10,
            isMetadataAvailable: false
        )

        XCTAssertEqual(zeroWidth.size, image.size)
        XCTAssertTrue(zeroWidth === image)

        let zeroHeight = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 10,
            maxHeight: 0,
            isMetadataAvailable: false
        )

        XCTAssertEqual(zeroHeight.size, image.size)
        XCTAssertTrue(zeroHeight === image)

        let zeroBoth = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 0,
            isMetadataAvailable: false
        )

        XCTAssertEqual(zeroBoth.size, image.size)
        XCTAssertTrue(zeroBoth === image)

        let zeroWithMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 10,
            isMetadataAvailable: true
        )

        XCTAssertEqual(zeroWithMetadata.size, image.size)

        let nilAndZero = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: 0,
            isMetadataAvailable: true
        )

        XCTAssertEqual(nilAndZero.size, image.size)

        let repeated = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 0,
            maxHeight: 10,
            isMetadataAvailable: false
        )

        XCTAssertTrue(repeated === image)
    }

    func testScaledGIFImage_EmptyData_ReturnsNil() {
        let result1 = ImagePickerImageUtil.scaledGIFImage(
            Data(),
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNil(result1)

        let result2 = ImagePickerImageUtil.scaledGIFImage(
            Data(),
            maxWidth: 3,
            maxHeight: 2
        )
        XCTAssertNil(result2)

        let randomData = Data([0x01, 0x02, 0x03])
        let result3 = ImagePickerImageUtil.scaledGIFImage(
            randomData,
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNil(result3)

        let invalidStringData = Data("invalid gif".utf8)
        let result4 = ImagePickerImageUtil.scaledGIFImage(
            invalidStringData,
            maxWidth: 5,
            maxHeight: 5
        )
        XCTAssertNil(result4)

        let result5 = ImagePickerImageUtil.scaledGIFImage(
            Data(),
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNil(result5)
    }
}
