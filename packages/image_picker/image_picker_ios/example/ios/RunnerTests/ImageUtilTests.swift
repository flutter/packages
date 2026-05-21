// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import UIKit

@testable import image_picker_ios

class ImageUtilTests: XCTestCase {

  // Corner colors of test image scaled to 3x2. Format is "R G B A".
  // Using a small epsilon for float comparison.
  private func colorsAreEqual(_ s1: String?, _ s2: String) -> Bool {
    guard let s1 = s1 else { return false }
    let components1 = s1.split(separator: " ").compactMap { Double($0) }
    let components2 = s2.split(separator: " ").compactMap { Double($0) }

    guard components1.count == 4 && components2.count == 4 else { return false }

    for i in 0..<4 {
      if abs(components1[i] - components2[i]) > 0.01 {
        return false
      }
    }
    return true
  }

  private let kColorRepresentation3x2BottomLeftYellow = "1 0.776471 0 1"

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
        x: CGFloat(-x), y: CGFloat(-y), width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
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

        // ✅ Case 1: Equal size (original scenario)
        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        // ✅ Validate size unchanged
        XCTAssertEqual(image.size, scaledImage.size)

        // ✅ Validate identity (important for coverage of "no scaling" branch)
        XCTAssertTrue(image === scaledImage)

        // ✅ Case 2: Same dimensions with metadata = false
        let scaledWithoutMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: false
        )

        XCTAssertEqual(image.size, scaledWithoutMetadata.size)

        // ✅ Case 3: Nil constraints (forces early return branch)
        let noConstraintImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertTrue(image === noConstraintImage)

        // ✅ Case 4: Width-only equal constraint
        let widthOnly = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertEqual(image.size.width, widthOnly.size.width)

        // ✅ Case 5: Height-only equal constraint
        let heightOnly = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(image.size.height, heightOnly.size.height)

        // ✅ Case 6: Repeated execution (important for coverage tracking)
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

        // ✅ NIL case (main expectation)
        let scaledImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        // ✅ Ensure SAME reference (important for coverage)
        XCTAssertTrue(scaledImage === image)

        // ✅ Ensure dimensions unchanged
        XCTAssertEqual(scaledImage.size.width, image.size.width)
        XCTAssertEqual(scaledImage.size.height, image.size.height)

        // ✅ Additional coverage: metadata = false (same branch but different path)
        let scaledImageNoMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: nil,
            isMetadataAvailable: false
        )

        XCTAssertTrue(scaledImageNoMetadata === image)

        // ✅ Ensure no scaling fallback still consistent
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

        // ✅ Main scaling path (metadata = true)
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

        // ✅ Additional coverage: metadata = false
        let scaledWithoutMetadata = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: scaledWidth,
            maxHeight: scaledHeight,
            isMetadataAvailable: false
        )

        XCTAssertNotNil(scaledWithoutMetadata)
        XCTAssertEqual(scaledWithoutMetadata.size.width, CGFloat(scaledWidth))
        XCTAssertEqual(scaledWithoutMetadata.size.height, CGFloat(scaledHeight))

        // ✅ Additional coverage: no scaling case (original size)
        let noScaleImage = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: Double(image.size.width),
            maxHeight: Double(image.size.height),
            isMetadataAvailable: true
        )

        XCTAssertEqual(noScaleImage.size.width, image.size.width)
        XCTAssertEqual(noScaleImage.size.height, image.size.height)

        // ✅ Additional coverage: width-only scaling
        let widthOnlyScaled = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: 4,
            maxHeight: nil,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(widthOnlyScaled.size.width, 4)

        // ✅ Additional coverage: height-only scaling
        let heightOnlyScaled = ImagePickerImageUtil.scaledImage(
            image,
            maxWidth: nil,
            maxHeight: 4,
            isMetadataAvailable: true
        )

        XCTAssertLessThanOrEqual(heightOnlyScaled.size.height, 4)
    }

    func testScaledGIFImage_ShouldBeScaled() {

        // ✅ Main success case
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

        // ✅ Additional coverage: width-only scaling
        let widthOnly = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: 4,
            maxHeight: nil
        )
        XCTAssertNotNil(widthOnly)
        for image in widthOnly!.images {
            XCTAssertLessThanOrEqual(image.size.width, 4)
        }

        // ✅ Additional coverage: height-only scaling
        let heightOnly = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: nil,
            maxHeight: 4
        )
        XCTAssertNotNil(heightOnly)
        for image in heightOnly!.images {
            XCTAssertLessThanOrEqual(image.size.height, 4)
        }

        // ✅ Additional coverage: no scaling (original size path)
        let noScale = ImagePickerImageUtil.scaledGIFImage(
            ImagePickerTestImages.gifTestData,
            maxWidth: nil,
            maxHeight: nil
        )
        XCTAssertNotNil(noScale)
        XCTAssertGreaterThan(noScale!.images.count, 0)

        // ✅ Additional coverage: invalid data branch
        let invalidData = Data("invalid gif data".utf8)
        let invalidResult = ImagePickerImageUtil.scaledGIFImage(
            invalidData,
            maxWidth: 3,
            maxHeight: 2
        )
        XCTAssertNil(invalidResult)
    }
}
