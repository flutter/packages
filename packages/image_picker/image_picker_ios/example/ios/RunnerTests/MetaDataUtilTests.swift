// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import UIKit
import ImageIO

@testable import image_picker_ios

class MetaDataUtilTests: XCTestCase {

  func testGetImageMIMETypeFromImageData() {
    // test jpeg
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.jpgTestData),
      .jpeg)

    // test png
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.pngTestData),
      .png)

    // test gif
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: ImagePickerTestImages.gifTestData),
      .gif)

    // test other
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: Data([0x00, 0x01])),
      .other)
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

  func testConvertImageToData() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!

    // JPEG
    let convertedDataJPG = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .jpeg,
      quality: 0.5)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataJPG!),
      .jpeg)

    // PNG
    let convertedDataPNG = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .png,
      quality: nil)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataPNG!),
      .png)

    // GIF (fallback to JPEG)
    let convertedDataGIF = ImagePickerMetaDataUtil.convertImage(
      imageJPG,
      using: .gif,
      quality: 0.5)
    XCTAssertEqual(
      ImagePickerMetaDataUtil.getImageMIMEType(from: convertedDataGIF!),
      .jpeg)

    // Other (fallback to JPEG)
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
    // Should still return PNG data but log a warning
    let data = ImagePickerMetaDataUtil.convertImage(image, using: .png, quality: 0.5)
    XCTAssertEqual(ImagePickerMetaDataUtil.getImageMIMEType(from: data!), .png)
  }
}
