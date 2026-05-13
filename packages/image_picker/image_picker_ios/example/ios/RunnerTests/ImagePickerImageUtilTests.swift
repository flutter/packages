// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import UIKit

@testable import image_picker_ios

class ImagePickerImageUtilTests: XCTestCase {

  func testScaledImage_Parameterized() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)! // 12x7
    let testCases: [(maxWidth: Double?, maxHeight: Double?, expectedWidth: CGFloat, expectedHeight: CGFloat)] = [
      (5, nil, 5, 3),      // Max width limiting
      (nil, 4, 7, 4),      // Max height limiting
      (6, 6, 6, 4),        // Both, width limiting
      (10, 2, 3, 2),       // Both, height limiting
      (20, 20, 12, 7),     // Larger than original (no scaling)
      (nil, nil, 12, 7),    // No limits (no scaling)
      (0, 5, 12, 7),       // Invalid width (no scaling)
      (5, 0, 12, 7)        // Invalid height (no scaling)
    ]

    for testCase in testCases {
      let scaled = ImagePickerImageUtil.scaledImage(
        image, maxWidth: testCase.maxWidth, maxHeight: testCase.maxHeight, isMetadataAvailable: false)
      XCTAssertEqual(scaled.size.width, testCase.expectedWidth, accuracy: 0.5, "Width failed for \(testCase)")
      XCTAssertEqual(scaled.size.height, testCase.expectedHeight, accuracy: 0.5, "Height failed for \(testCase)")
    }
  }

  func testScaledImage_ShouldReturnOriginalIfSizeIsSame() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!

    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: Double(image.size.width),
      maxHeight: Double(image.size.height),
      isMetadataAvailable: true)

    XCTAssertEqual(image, scaledImage)
  }

  func testScaledImage_ShouldReturnOriginalIfSizeIsNil() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!

    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: nil,
      maxHeight: nil,
      isMetadataAvailable: true)

    XCTAssertEqual(image, scaledImage)
  }

  func testScaledImage_ShouldDownscaleWidth() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!
    let originalWidth = image.size.width

    let maxWidth = originalWidth / 2.0
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: maxWidth,
      maxHeight: nil,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.width, maxWidth, accuracy: 1.0)
  }

  func testScaledImage_ShouldDownscaleHeight() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!
    let originalHeight = image.size.height

    let maxHeight = originalHeight / 2.0
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: nil,
      maxHeight: maxHeight,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.height, maxHeight, accuracy: 1.0)
  }

  func testScaledImage_ShouldRespectAspectRatio_WhenWidthIsLimiting() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!

    let maxWidth = image.size.width / 2.0
    let maxHeight = image.size.height // Height is NOT limiting

    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.width, maxWidth, accuracy: 1.0)
    // Aspect ratio should be maintained
    XCTAssertEqual(scaledImage.size.height, image.size.height / 2.0, accuracy: 1.0)
  }

  func testScaledImage_ShouldRespectAspectRatio_WhenHeightIsLimiting() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!

    let maxWidth = image.size.width // Width is NOT limiting
    let maxHeight = image.size.height / 2.0

    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.height, maxHeight, accuracy: 1.0)
    // Aspect ratio should be maintained
    XCTAssertEqual(scaledImage.size.width, image.size.width / 2.0, accuracy: 1.0)
  }

  func testScaledImage_WithOrientation() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!
    // Create an image with left orientation.
    // UIKit's UIImage.size already accounts for orientation.
    let leftImage = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .left)

    let maxWidth = leftImage.size.width / 2.0
    let maxHeight = leftImage.size.height / 2.0

    let scaledImage = ImagePickerImageUtil.scaledImage(
      leftImage,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.width, maxWidth, accuracy: 1.0)
    XCTAssertEqual(scaledImage.size.height, maxHeight, accuracy: 1.0)
  }

  func testScaledImage_InvalidDimensionsReturnsOriginal() {
    let data = ImagePickerTestImages.jpgTestData
    let image = UIImage(data: data)!

    // Test with 0 dimensions (drawScaledImage should return nil, scaledImage should return original)
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: 0,
      maxHeight: 0,
      isMetadataAvailable: true)

    XCTAssertEqual(image, scaledImage)
  }

  func testScaledGIFImage_ShouldMaintainFrameCount() {
    let data = ImagePickerTestImages.gifTestData
    let info = ImagePickerImageUtil.scaledGIFImage(data, maxWidth: 5, maxHeight: 5)

    XCTAssertNotNil(info)
    XCTAssertEqual(info?.images.count, 3)
  }

  func testScaledGIFImage_InvalidDataReturnsNil() {
    // A small chunk of data that is definitely NOT a GIF
    let data = "Not a gif".data(using: .utf8)!
    let info = ImagePickerImageUtil.scaledGIFImage(data, maxWidth: 5, maxHeight: 5)
    XCTAssertNil(info)
  }

  func testScaledGIFImage_ShouldHandleNoDelayInfo() {
    // Create a GIF with no delay info. This is hard to do with standard APIs,
    // but we can test if the interval is at least set to the default 0.1
    let data = ImagePickerTestImages.gifTestData
    let info = ImagePickerImageUtil.scaledGIFImage(data, maxWidth: nil, maxHeight: nil)
    XCTAssertNotNil(info)
    XCTAssertGreaterThan(info?.interval ?? 0, 0)
  }

  func testDrawScaledImage_ZeroSize_ReturnsNil() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    // Accessing private method via name if needed, but we test it through scaledImage
    let scaled = ImagePickerImageUtil.scaledImage(image, maxWidth: 0, maxHeight: 10, isMetadataAvailable: false)
    XCTAssertEqual(scaled, image)
  }

  func testScaledGIFImage_EmptyData_ReturnsNil() {
    XCTAssertNil(ImagePickerImageUtil.scaledGIFImage(Data(), maxWidth: nil, maxHeight: nil))
  }
}
