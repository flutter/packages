// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import UIKit
import ImageIO

@testable import image_picker_ios

class ImagePickerMetaDataUtilTests: XCTestCase {

  func testGetImageMIMETypeFromImageData() {
    let testCases: [(data: Data, expected: ImagePickerMIMEType)] = [
      (ImagePickerTestImages.jpgTestData, .jpeg),
      (ImagePickerTestImages.pngTestData, .png),
      (ImagePickerTestImages.gifTestData, .gif),
      (Data([0x00, 0x01, 0x02]), .other)
    ]

    for testCase in testCases {
      XCTAssertEqual(
        ImagePickerMetaDataUtil.getImageMIMEType(from: testCase.data),
        testCase.expected,
        "Failed for data: \(testCase.data)")
    }
  }

  func testSuffixFromType() {
    // test jpeg
    XCTAssertEqual(
      ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg), ".jpg")

    // test png
    XCTAssertEqual(
      ImagePickerMetaDataUtil.imageTypeSuffix(from: .png), ".png")

    // test gif
    XCTAssertEqual(
      ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif), ".gif")

    // test other
    XCTAssertNil(ImagePickerMetaDataUtil.imageTypeSuffix(from: .other))
  }

  func testGetMetaData() {
    let metaData = ImagePickerMetaDataUtil.getMetaData(from: ImagePickerTestImages.jpgTestData)
    let exif = metaData?[kCGImagePropertyExifDictionary as String] as? [String: Any]
    XCTAssertEqual(exif?[kCGImagePropertyExifPixelXDimension as String] as? Int, 12)
  }

  func testGetMetaData_InvalidDataReturnsNil() {
    XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: Data("not an image".utf8)))
  }

  func testUpdateMetaData() {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let metaData: [String: Any] = [
      kCGImagePropertyExifDictionary as String: [
        kCGImagePropertyExifUserComment as String: "Test Comment"
      ]
    ]

    guard let newData = ImagePickerMetaDataUtil.image(from: dataJPG, with: metaData) else {
      XCTFail("Could not create image with metadata")
      return
    }

    let newMetaData = ImagePickerMetaDataUtil.getMetaData(from: newData)
    let newExif = newMetaData?[kCGImagePropertyExifDictionary as String] as? [String: Any]
    XCTAssertEqual(newExif?[kCGImagePropertyExifUserComment as String] as? String, "Test Comment")
  }

  func testUpdateMetaData_InvalidDataReturnsNil() {
    XCTAssertNil(ImagePickerMetaDataUtil.image(from: Data("not an image".utf8), with: [:]))
  }

  func testGetMetaData_CorruptedData_ReturnsNil() {
    let corruptedData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // PNG header but no content
    XCTAssertNil(ImagePickerMetaDataUtil.getMetaData(from: corruptedData))
  }

  func testConvertImageToData() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataJPG = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .jpeg,
      quality: 0.5)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataJPG!),
      .jpeg)

    let convertedDataPNG = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .png,
      quality: nil)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataPNG!),
      .png)

    // Test default fallback (other)
    let convertedDataOther = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .other,
      quality: nil)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataOther!),
      .jpeg)
  }

  func testConvertImageToData_PngWithQualityWarning() {
    let image = UIImage(data: ImagePickerTestImages.pngTestData)!
    // Should still return PNG data but log a warning (which we don't explicitly test for here but we hit the branch)
    let data = ImagePickerMetaDataUtil.convertImage(image, using: .png, quality: 0.5)
    XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: data!), .png)
  }

  func testConvertImageToData_GifWithQualityWarning() {
    let image = UIImage(data: ImagePickerTestImages.gifTestData)!
    let data = ImagePickerMetaDataUtil.convertImage(image, using: .gif, quality: 0.5)
    // .gif fallback is currently JPEG in convertImage switch default
    XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: data!), .jpeg)
  }

  func testConvertImageToData_DefaultFallback() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let data = ImagePickerMetaDataUtil.convertImage(image, using: .other, quality: 0.8)
    XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: data!), .jpeg)
  }

  func testImageWithMetadata_InvalidDataReturnsNil() {
    let invalidData = Data([0, 1, 2])
    let result = ImagePickerMetaDataUtil.image(from: invalidData, with: [:])
    XCTAssertNil(result)
  }

  func testGetImageMIMETypeFromImageData_EmptyData() {
    // Should not crash, returns .other
    XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: Data()), .other)
  }

  func testImageWithMetadata_CorruptedHeader() {
    let data = Data([0xFF, 0xD8, 0xFF]) // Incomplete JPEG
    XCTAssertNil(ImagePickerMetaDataUtil.image(from: data, with: [:]))
  }
}
