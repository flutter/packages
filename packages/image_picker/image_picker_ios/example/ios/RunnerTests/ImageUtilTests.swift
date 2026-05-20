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
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: Double(image.size.width),
      maxHeight: Double(image.size.height),
      isMetadataAvailable: true)

    XCTAssertEqual(image, scaledImage)
  }

  func testScaledImage_NilSizeReturnsSameImage() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: nil,
      maxHeight: nil,
      isMetadataAvailable: true)

    XCTAssertEqual(image, scaledImage)
  }

  func testScaledImage_ShouldBeScaled() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!

    let scaledWidth: Double = 3
    let scaledHeight: Double = 2
    let scaledImage = ImagePickerImageUtil.scaledImage(
      image,
      maxWidth: scaledWidth,
      maxHeight: scaledHeight,
      isMetadataAvailable: true)

    XCTAssertEqual(scaledImage.size.width, CGFloat(scaledWidth))
    XCTAssertEqual(scaledImage.size.height, CGFloat(scaledHeight))

    let color = colorStringAtPixel(scaledImage, x: 0, y: 0)
    XCTAssertTrue(
      colorsAreEqual(color, kColorRepresentation3x2BottomLeftYellow),
      "Color \(color ?? "nil") does not match \(kColorRepresentation3x2BottomLeftYellow)")
  }

  func testScaledGIFImage_ShouldBeScaled() {
    let info = ImagePickerImageUtil.scaledGIFImage(
      ImagePickerTestImages.gifTestData,
      maxWidth: 3,
      maxHeight: 2)!

    XCTAssertEqual(info.images.count, 3)
    XCTAssertEqual(info.interval, 1)

    for newImage in info.images {
      XCTAssertEqual(newImage.size.width, 3)
      XCTAssertEqual(newImage.size.height, 2)
    }
  }
}
