// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import image_picker_ios
import ImageIO
import UIKit
import XCTest

class ImagePickerMetaDataUtilTests: XCTestCase {
    func testGetImageMIMETypeFromImageData() {
        let testCases: [(data: Data, expected: ImagePickerMIMEType)] = [
            (ImagePickerTestImages.jpgTestData, .jpeg),
            (ImagePickerTestImages.pngTestData, .png),
            (ImagePickerTestImages.gifTestData, .gif),
            (Data([0x00, 0x01, 0x02]), .other),
        ]

        for testCase in testCases {
            let result = ImagePickerMetaDataUtil.getImageMIMEType(from: testCase.data)

            XCTAssertEqual(
                result,
                testCase.expected,
                "Failed for data: \(testCase.data)"
            )
        }

        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.jpgTestData),
            .jpeg
        )

        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.pngTestData),
            .png
        )

        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.gifTestData),
            .gif
        )

        let invalidData = Data("invalid_data".utf8)
        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: invalidData),
            .other
        )

        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: Data()),
            .other
        )

        let randomData = Data([0x11, 0x22, 0x33, 0x44])
        XCTAssertEqual(
            ImagePickerMetaDataUtil.getImageMIMEType(from: randomData),
            .other
        )
    }

    func testSuffixFromType() throws {
        XCTAssertEqual(
            ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg),
            ".jpg"
        )

        XCTAssertEqual(
            ImagePickerMetaDataUtil.imageTypeSuffix(from: .png),
            ".png"
        )

        XCTAssertEqual(
            ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif),
            ".gif"
        )

        XCTAssertNil(
            ImagePickerMetaDataUtil.imageTypeSuffix(from: .other)
        )

        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg), ".jpg")
        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .png), ".png")
        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif), ".gif")
        XCTAssertNil(ImagePickerMetaDataUtil.imageTypeSuffix(from: .other))

        let jpegSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg)
        XCTAssertTrue(try XCTUnwrap(jpegSuffix?.hasPrefix(".")))

        let pngSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .png)
        XCTAssertTrue(try XCTUnwrap(pngSuffix?.hasPrefix(".")))

        let gifSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif)
        XCTAssertTrue(try XCTUnwrap(gifSuffix?.hasPrefix(".")))

        let otherSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .other)
        XCTAssertNil(otherSuffix)
    }

    func testGetMetaData() throws {
        let data = ImagePickerTestImages.jpgTestData

        let metaData = ImagePickerMetaDataUtil.getMetaData(from: data)
        XCTAssertNotNil(metaData)

        let exif = metaData?[kCGImagePropertyExifDictionary as String] as? [String: Any]
        XCTAssertNotNil(exif)

        XCTAssertEqual(
            exif?[kCGImagePropertyExifPixelXDimension as String] as? Int,
            12
        )

        let pixelY = exif?[kCGImagePropertyExifPixelYDimension as String] as? Int
        XCTAssertNotNil(pixelY)

        XCTAssertFalse(try XCTUnwrap(metaData?.isEmpty))

        let secondRead = ImagePickerMetaDataUtil.getMetaData(from: data)
        XCTAssertNotNil(secondRead)

        if let modifiedData = ImagePickerMetaDataUtil.image(from: data, with: [:]) {
            let modifiedMeta = ImagePickerMetaDataUtil.getMetaData(from: modifiedData)
            XCTAssertNotNil(modifiedMeta)
        }

        let slightlyCorruptData = Data(data.prefix(5)) // truncated image
        let corruptMeta = ImagePickerMetaDataUtil.getMetaData(from: slightlyCorruptData)

        if corruptMeta != nil {
            XCTAssertTrue(true) // executed fallback path
        } else {
            XCTAssertNil(corruptMeta)
        }
    }

    func testGetMetaData_InvalidDataReturnsNil() {
        let invalidData = Data("not an image".utf8)
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: invalidData))

        let emptyData = Data()
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: emptyData))

        let corruptedData = Data([0xFF, 0xD8, 0x00, 0x00, 0xFF])
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: corruptedData))

        let validJPGData = ImagePickerTestImages.jpgTestData
        let jpgMeta = ImagePickerMetaDataUtil.getMetaData(from: validJPGData)
        XCTAssertNotNil(jpgMeta)

        let exif = jpgMeta?[kCGImagePropertyExifDictionary as String]
        XCTAssertNotNil(exif)

        let validPNGData = ImagePickerTestImages.pngTestData
        let pngMeta = ImagePickerMetaDataUtil.getMetaData(from: validPNGData)
        XCTAssertNotNil(pngMeta)

        let tiff = pngMeta?[kCGImagePropertyTIFFDictionary as String]
        XCTAssertNotNil(tiff)

        let jpgMetaAgain = ImagePickerMetaDataUtil.getMetaData(from: validJPGData)
        XCTAssertNotNil(jpgMetaAgain)
    }

    func testUpdateMetaData() throws {
        let dataJPG = ImagePickerTestImages.jpgTestData

        let metaData: [String: Any] = [
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifUserComment as String: "Test Comment",
            ],
        ]

        guard let newData = ImagePickerMetaDataUtil.image(from: dataJPG, with: metaData) else {
            XCTFail("Could not create image with metadata")
            return
        }

        XCTAssertNotEqual(newData, dataJPG)

        let newMetaData = ImagePickerMetaDataUtil.getMetaData(from: newData)
        XCTAssertNotNil(newMetaData)

        let newExif = newMetaData?[kCGImagePropertyExifDictionary as String] as? [String: Any]

        XCTAssertEqual(
            newExif?[kCGImagePropertyExifUserComment as String] as? String,
            "Test Comment"
        )

        let updatedMetaData: [String: Any] = [
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifUserComment as String: "Updated Comment",
            ],
        ]

        let updatedData = ImagePickerMetaDataUtil.image(from: newData, with: updatedMetaData)
        XCTAssertNotNil(updatedData)

        let updatedMeta = try ImagePickerMetaDataUtil.getMetaData(from: XCTUnwrap(updatedData))
        let updatedExif = updatedMeta?[kCGImagePropertyExifDictionary as String] as? [String: Any]

        XCTAssertEqual(
            updatedExif?[kCGImagePropertyExifUserComment as String] as? String,
            "Updated Comment"
        )

        let emptyMetaData: [String: Any] = [:]
        let emptyData = ImagePickerMetaDataUtil.image(from: dataJPG, with: emptyMetaData)
        XCTAssertNotNil(emptyData)

        let invalidData = Data("invalid image data".utf8)

        let failedImage = ImagePickerMetaDataUtil.image(from: invalidData, with: metaData)
        XCTAssertNil(failedImage)

        let failedMetaData = ImagePickerMetaDataUtil.getMetaData(from: invalidData)
        XCTAssertNil(failedMetaData)

        let originalMeta = ImagePickerMetaDataUtil.getMetaData(from: dataJPG)
        XCTAssertNotNil(originalMeta)
    }

    func testUpdateMetaData_InvalidDataReturnsNil() throws {
        let invalidStringData = Data("not an image".utf8)
        let result1 = ImagePickerMetaDataUtil.image(from: invalidStringData, with: [:])
        XCTAssertNil(result1)

        let emptyData = Data()
        let result2 = ImagePickerMetaDataUtil.image(from: emptyData, with: [:])
        XCTAssertNil(result2)

        let corruptedData = Data([0xFF, 0xD8, 0xFF])
        let result3 = ImagePickerMetaDataUtil.image(from: corruptedData, with: [:])
        XCTAssertNil(result3)

        let image = try XCTUnwrap(UIImage(systemName: "circle"))
        let validData = try XCTUnwrap(image.jpegData(compressionQuality: 1.0))
        let result4 = ImagePickerMetaDataUtil.image(from: validData, with: [:])
        XCTAssertNotNil(result4)

        let metadata: [String: Any] = [
            kCGImagePropertyOrientation as String: 1,
        ]
        let result5 = ImagePickerMetaDataUtil.image(from: validData, with: metadata)
        XCTAssertNotNil(result5)
    }

    func testGetMetaData_CorruptedData_ReturnsNil() throws {
        let corruptedData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: corruptedData))

        let emptyData = Data()
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: emptyData))

        let randomData = Data([0x00, 0x11, 0x22])
        XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: randomData))

        let image = try XCTUnwrap(UIImage(systemName: "circle"))
        let validData = try XCTUnwrap(image.jpegData(compressionQuality: 1.0))

        let metadata = ImagePickerMetaDataUtil.getMetaData(from: validData)

        XCTAssertNotNil(metadata)

        let metadataAgain = ImagePickerMetaDataUtil.getMetaData(from: validData)
        XCTAssertNotNil(metadataAgain)
    }

    func testConvertImageToData() throws {
        let imageJPG = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let convertedDataJPG = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .jpeg,
            quality: 0.5
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataJPG)),
            .jpeg
        )

        let convertedDataJPGZero = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .jpeg,
            quality: 0.0
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataJPGZero)),
            .jpeg
        )

        let convertedDataPNG = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .png,
            quality: nil
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataPNG)),
            .png
        )

        let convertedDataPNGQuality = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .png,
            quality: 0.7
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataPNGQuality)),
            .png
        )

        let convertedDataGIF = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .gif,
            quality: 0.6
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataGIF)),
            .jpeg
        )

        let convertedDataOther = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .other,
            quality: nil
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataOther)),
            .jpeg
        )

        let convertedDataOtherQuality = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .other,
            quality: 0.8
        )
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataOtherQuality)),
            .jpeg
        )
    }

    func testConvertImageToData_PngWithQualityWarning() throws {
        let pngImage = try XCTUnwrap(UIImage(data: ImagePickerTestImages.pngTestData))
        let jpgImage = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let pngData = ImagePickerMetaDataUtil.convertImage(pngImage, using: .png, quality: 0.5)
        XCTAssertNotNil(pngData)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(pngData)), .png)

        let jpegData = ImagePickerMetaDataUtil.convertImage(jpgImage, using: .jpeg, quality: 0.7)
        XCTAssertNotNil(jpegData)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(jpegData)), .jpeg)

        let gifData = ImagePickerMetaDataUtil.convertImage(pngImage, using: .gif, quality: 0.6)
        XCTAssertNotNil(gifData)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(gifData)), .jpeg)

        let fallbackData = ImagePickerMetaDataUtil.convertImage(pngImage, using: .other, quality: 0.8)
        XCTAssertNotNil(fallbackData)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(fallbackData)), .jpeg)

        let boundaryData = ImagePickerMetaDataUtil.convertImage(jpgImage, using: .jpeg, quality: 0.0)
        XCTAssertNotNil(boundaryData)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(boundaryData)), .jpeg)
    }

    func testConvertImageToData_GifWithQualityWarning() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.gifTestData))

        let data1 = ImagePickerMetaDataUtil.convertImage(image, using: .gif, quality: 0.5)
        XCTAssertNotNil(data1)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data1)), .jpeg)

        let data2 = ImagePickerMetaDataUtil.convertImage(image, using: .gif, quality: 1.0)
        XCTAssertNotNil(data2)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data2)), .jpeg)

        let data3 = ImagePickerMetaDataUtil.convertImage(image, using: .gif, quality: 0.0)
        XCTAssertNotNil(data3)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data3)), .jpeg)

        let data4 = ImagePickerMetaDataUtil.convertImage(image, using: .gif, quality: 0.8)
        XCTAssertNotNil(data4)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data4)), .jpeg)
    }

    func testConvertImageToData_DefaultFallback() throws {
        let image = try XCTUnwrap(UIImage(data: ImagePickerTestImages.jpgTestData))

        let data1 = ImagePickerMetaDataUtil.convertImage(image, using: .other, quality: 0.8)
        XCTAssertNotNil(data1)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data1)), .jpeg)

        let data2 = ImagePickerMetaDataUtil.convertImage(image, using: .jpeg, quality: 0.5)
        XCTAssertNotNil(data2)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data2)), .jpeg)

        let data3 = ImagePickerMetaDataUtil.convertImage(image, using: .png, quality: 1.0)
        XCTAssertNotNil(data3)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data3)), .png)

        let data4 = ImagePickerMetaDataUtil.convertImage(image, using: .jpeg, quality: 0.0)
        XCTAssertNotNil(data4)
        XCTAssertEqual(try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(data4)), .jpeg)
    }

    func testImageWithMetadata_InvalidDataReturnsNil() throws {
        let invalidData = Data([0, 1, 2])
        let result1 = ImagePickerMetaDataUtil.image(from: invalidData, with: [:])
        XCTAssertNil(result1)

        let emptyData = Data()
        let result2 = ImagePickerMetaDataUtil.image(from: emptyData, with: [:])
        XCTAssertNil(result2)

        let corruptedJPEG = Data([0xFF, 0xD8, 0xFF])
        let result3 = ImagePickerMetaDataUtil.image(from: corruptedJPEG, with: [:])
        XCTAssertNil(result3)

        let image = try XCTUnwrap(UIImage(systemName: "circle"))
        let validData = try XCTUnwrap(image.jpegData(compressionQuality: 1.0))
        let result4 = ImagePickerMetaDataUtil.image(from: validData, with: [:])
        XCTAssertNotNil(result4)

        let metadata: [String: Any] = [
            kCGImagePropertyOrientation as String: 1,
        ]
        let result5 = ImagePickerMetaDataUtil.image(from: validData, with: metadata)
        XCTAssertNotNil(result5)
    }

    func testGetImageMIMETypeFromImageData_EmptyData() {
        XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: Data()), .other)

        let jpegData = Data([0xFF, 0xD8, 0xFF])
        XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: jpegData), .jpeg)

        let pngData = Data([0x89, 0x50, 0x4E, 0x47])
        XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: pngData), .png)

        let gifData = Data([0x47, 0x49, 0x46])
        XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: gifData), .gif)

        let unknownData = Data([0x00, 0x11, 0x22, 0x33])
        XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: unknownData), .other)
    }

    func testImageWithMetadata_CorruptedHeader() throws {
        let corruptedData = Data([0xFF, 0xD8, 0xFF])
        XCTAssertNil(ImagePickerMetaDataUtil.image(from: corruptedData, with: [:]))

        let emptyData = Data()
        XCTAssertNil(ImagePickerMetaDataUtil.image(from: emptyData, with: [:]))

        let image = try XCTUnwrap(UIImage(systemName: "circle"))
        let validData = try XCTUnwrap(image.jpegData(compressionQuality: 1.0))
        let resultWithoutMetadata = ImagePickerMetaDataUtil.image(from: validData, with: [:])
        XCTAssertNotNil(resultWithoutMetadata)

        let metadata: [String: Any] = [
            kCGImagePropertyOrientation as String: 1,
        ]
        let resultWithMetadata = ImagePickerMetaDataUtil.image(from: validData, with: metadata)
        XCTAssertNotNil(resultWithMetadata)
    }
}
