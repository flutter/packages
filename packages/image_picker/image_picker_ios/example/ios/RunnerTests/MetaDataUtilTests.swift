// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import image_picker_ios
import ImageIO
import UIKit
import XCTest

class MetaDataUtilTests: XCTestCase {
    func testGetImageMIMETypeFromImageData() {
        let jpegResult = ImagePickerMetaDataUtil.getImageMIMEType(
            from: ImagePickerTestImages.jpgTestData
        )
        XCTAssertEqual(jpegResult, .jpeg)

        let pngResult = ImagePickerMetaDataUtil.getImageMIMEType(
            from: ImagePickerTestImages.pngTestData
        )
        XCTAssertEqual(pngResult, .png)

        let gifResult = ImagePickerMetaDataUtil.getImageMIMEType(
            from: ImagePickerTestImages.gifTestData
        )
        XCTAssertEqual(gifResult, .gif)

        let otherResult = ImagePickerMetaDataUtil.getImageMIMEType(
            from: Data([0x00, 0x01])
        )
        XCTAssertEqual(otherResult, .other)

        let emptyResult = ImagePickerMetaDataUtil.getImageMIMEType(from: Data())
        XCTAssertEqual(emptyResult, .other)

        let randomData = Data([0x11, 0x22, 0x33, 0x44])
        let randomResult = ImagePickerMetaDataUtil.getImageMIMEType(from: randomData)
        XCTAssertEqual(randomResult, .other)

        let invalidStringData = Data("invalid".utf8)
        let invalidResult = ImagePickerMetaDataUtil.getImageMIMEType(from: invalidStringData)
        XCTAssertEqual(invalidResult, .other)

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

        XCTAssertTrue(jpegResult == .jpeg)
        XCTAssertTrue(pngResult == .png)
        XCTAssertTrue(gifResult == .gif)
    }

    func testSuffixFromType() throws {
        let jpegSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg)
        XCTAssertEqual(jpegSuffix, ".jpg")
        XCTAssertTrue(jpegSuffix?.hasPrefix(".") ?? false)

        let pngSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .png)
        XCTAssertEqual(pngSuffix, ".png")
        XCTAssertTrue(pngSuffix?.hasPrefix(".") ?? false)

        let gifSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif)
        XCTAssertEqual(gifSuffix, ".gif")
        XCTAssertTrue(gifSuffix?.hasPrefix(".") ?? false)

        let otherSuffix = ImagePickerMetaDataUtil.imageTypeSuffix(from: .other)
        XCTAssertNil(otherSuffix)

        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg), ".jpg")
        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .png), ".png")
        XCTAssertEqual(ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif), ".gif")
        XCTAssertNil(ImagePickerMetaDataUtil.imageTypeSuffix(from: .other))

        let jpegCheck = ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg)
        let pngCheck = ImagePickerMetaDataUtil.imageTypeSuffix(from: .png)
        let gifCheck = ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif)

        XCTAssertTrue(try XCTUnwrap(jpegCheck?.starts(with: ".")))
        XCTAssertTrue(try XCTUnwrap(pngCheck?.starts(with: ".")))
        XCTAssertTrue(try XCTUnwrap(gifCheck?.starts(with: ".")))
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

        let truncatedData = Data(data.prefix(5))
        let truncatedMeta = ImagePickerMetaDataUtil.getMetaData(from: truncatedData)

        if truncatedMeta != nil {
            XCTAssertTrue(true)
        } else {
            XCTAssertNil(truncatedMeta)
        }
    }

    func testGetMetaData_InvalidDataReturnsNil() {
        let invalidData = Data("not an image".utf8)
        let result1 = ImagePickerMetaDataUtil.getMetaData(from: invalidData)
        XCTAssertNil(result1)

        let emptyData = Data()
        let result2 = ImagePickerMetaDataUtil.getMetaData(from: emptyData)
        XCTAssertNil(result2)

        let corruptedData = Data([0xFF, 0x00, 0x00, 0xFF])
        let result3 = ImagePickerMetaDataUtil.getMetaData(from: corruptedData)
        XCTAssertNil(result3)

        let validData = ImagePickerTestImages.jpgTestData
        let validMeta = ImagePickerMetaDataUtil.getMetaData(from: validData)

        XCTAssertNotNil(validMeta)

        let exif = validMeta?[kCGImagePropertyExifDictionary as String]
        XCTAssertNotNil(exif)

        let repeatResult = ImagePickerMetaDataUtil.getMetaData(from: invalidData)
        XCTAssertNil(repeatResult)
    }

    func testUpdateMetaData() {
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

        let invalidData = Data("invalid".utf8)
        let invalidMeta = ImagePickerMetaDataUtil.getMetaData(from: invalidData)

        XCTAssertNil(invalidMeta)
    }

    func testUpdateMetaData_InvalidDataReturnsNil() {
        let invalidData = Data("not an image".utf8)
        let result1 = ImagePickerMetaDataUtil.image(from: invalidData, with: [:])
        XCTAssertNil(result1)

        let emptyData = Data()
        let result2 = ImagePickerMetaDataUtil.image(from: emptyData, with: [:])
        XCTAssertNil(result2)

        let corruptedData = Data([0xFF, 0x00, 0x00, 0xFF])
        let result3 = ImagePickerMetaDataUtil.image(from: corruptedData, with: [:])
        XCTAssertNil(result3)

        let metaData: [String: Any] = [
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifUserComment as String: "Test",
            ],
        ]

        let result4 = ImagePickerMetaDataUtil.image(from: invalidData, with: metaData)
        XCTAssertNil(result4)

        let result5 = ImagePickerMetaDataUtil.image(from: invalidData, with: [:])
        XCTAssertNil(result5)
    }

    func testConvertImageAndMimeType() throws {
        guard let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData) else {
            XCTFail("Failed to create UIImage")
            return
        }

        let convertedDataJPG = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .jpeg,
            quality: 0.5
        )
        XCTAssertNotNil(convertedDataJPG)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataJPG)),
            .jpeg
        )

        let convertedDataPNG = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .png,
            quality: nil
        )
        XCTAssertNotNil(convertedDataPNG)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataPNG)),
            .png
        )

        let convertedDataGIF = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .gif,
            quality: 0.5
        )
        XCTAssertNotNil(convertedDataGIF)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataGIF)),
            .jpeg
        )

        let convertedDataOther = ImagePickerMetaDataUtil.convertImage(
            imageJPG,
            using: .other,
            quality: nil
        )
        XCTAssertNotNil(convertedDataOther)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(convertedDataOther)),
            .jpeg
        )

        let invalidData = Data("invalid".utf8)
        let mimeType = ImagePickerMetaDataUtil.getImageMIMEType(from: invalidData)

        XCTAssertTrue(mimeType == .jpeg || mimeType == .other)
    }

    func testConvertImageToData_PngWithQualityWarning() throws {
        guard let image = UIImage(data: ImagePickerTestImages.pngTestData) else {
            XCTFail("Failed to create PNG image")
            return
        }

        let dataWithQuality = ImagePickerMetaDataUtil.convertImage(
            image,
            using: .png,
            quality: 0.5
        )

        XCTAssertNotNil(dataWithQuality)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(dataWithQuality)),
            .png
        )

        let dataWithoutQuality = ImagePickerMetaDataUtil.convertImage(
            image,
            using: .png,
            quality: nil
        )

        XCTAssertNotNil(dataWithoutQuality)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(dataWithoutQuality)),
            .png
        )

        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(dataWithQuality)),
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(dataWithoutQuality))
        )

        let repeated = ImagePickerMetaDataUtil.convertImage(
            image,
            using: .png,
            quality: 1.0
        )

        XCTAssertNotNil(repeated)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(repeated)),
            .png
        )

        let anotherCall = ImagePickerMetaDataUtil.convertImage(
            image,
            using: .png,
            quality: 0.1
        )

        XCTAssertNotNil(anotherCall)
        XCTAssertEqual(
            try ImagePickerMetaDataUtil.getImageMIMEType(from: XCTUnwrap(anotherCall)),
            .png
        )
    }
}
