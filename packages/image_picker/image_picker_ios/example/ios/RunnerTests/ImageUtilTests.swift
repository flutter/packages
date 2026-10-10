// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreImage
import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers

@testable import image_picker_ios

private let kColorRepresentation3x2BottomLeftYellow = "1 0.776471 0 1"
private let kColorRepresentation3x2TopLeftRed = "1 0.0666667 0 1"
private let kColorRepresentation3x2BottomRightCyan = "0 0.772549 1 1"
private let kColorRepresentation3x2TopRightBlue = "0 0.0705882 0.996078 1"

private func colorString(atPixel image: UIImage, pixelX: Int, pixelY: Int) -> String {
  let cgImage = image.cgImage!
  var argb: UInt32 = 0
  let context = CGContext(
    data: &argb,
    width: 1,
    height: 1,
    bitsPerComponent: cgImage.bitsPerComponent,
    bytesPerRow: MemoryLayout.size(ofValue: argb),
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: cgImage.bitmapInfo.rawValue)!
  context.draw(
    cgImage,
    in: CGRect(
      x: -CGFloat(pixelX), y: -CGFloat(pixelY), width: CGFloat(cgImage.width),
      height: CGFloat(cgImage.height)))
  let blue = Int(argb & 0xff)
  let green = Int(argb >> 8 & 0xff)
  let red = Int(argb >> 16 & 0xff)
  let alpha = Int(argb >> 24 & 0xff)
  return CIColor(
    red: CGFloat(red) / 255.0,
    green: CGFloat(green) / 255.0,
    blue: CGFloat(blue) / 255.0,
    alpha: CGFloat(alpha) / 255.0
  ).stringRepresentation
}

@Suite
struct ImageUtilTests {
  @Test func scaledImageEqualSizeReturnsSameImage() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: NSNumber(value: image.size.width),
      maxHeight: NSNumber(value: image.size.height), isMetadataAvailable: true)
    #expect(image === scaledImage)
  }

  @Test func scaledImageNilSizeReturnsSameImage() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: nil, maxHeight: nil, isMetadataAvailable: true)
    #expect(image === scaledImage)
  }

  @Test func scaledImageShouldBeScaled() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledWidth: CGFloat = 3
    let scaledHeight: CGFloat = 2
    let scaledImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: NSNumber(value: scaledWidth), maxHeight: NSNumber(value: scaledHeight),
      isMetadataAvailable: true)!
    #expect(scaledImage.size.width == scaledWidth)
    #expect(scaledImage.size.height == scaledHeight)
    #expect(
      colorString(atPixel: scaledImage, pixelX: 0, pixelY: 0)
        == kColorRepresentation3x2BottomLeftYellow)
    #expect(
      colorString(atPixel: scaledImage, pixelX: 0, pixelY: Int(scaledHeight) - 1)
        == kColorRepresentation3x2TopLeftRed)
    #expect(
      colorString(atPixel: scaledImage, pixelX: Int(scaledWidth) - 1, pixelY: 0)
        == kColorRepresentation3x2BottomRightCyan)
    #expect(
      colorString(
        atPixel: scaledImage, pixelX: Int(scaledWidth) - 1, pixelY: Int(scaledHeight) - 1)
        == kColorRepresentation3x2TopRightBlue)
  }

  @Test func scaledImageShouldBeScaledWithNoMetadata() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let scaledWidth: CGFloat = 3
    let scaledHeight: CGFloat = 2
    let scaledImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: NSNumber(value: scaledWidth), maxHeight: NSNumber(value: scaledHeight),
      isMetadataAvailable: false)!
    #expect(scaledImage.size.width == scaledWidth)
    #expect(scaledImage.size.height == scaledHeight)
    #expect(
      colorString(atPixel: scaledImage, pixelX: 0, pixelY: 0)
        == kColorRepresentation3x2BottomLeftYellow)
    #expect(
      colorString(atPixel: scaledImage, pixelX: 0, pixelY: Int(scaledHeight) - 1)
        == kColorRepresentation3x2TopLeftRed)
    #expect(
      colorString(atPixel: scaledImage, pixelX: Int(scaledWidth) - 1, pixelY: 0)
        == kColorRepresentation3x2BottomRightCyan)
    #expect(
      colorString(
        atPixel: scaledImage, pixelX: Int(scaledWidth) - 1, pixelY: Int(scaledHeight) - 1)
        == kColorRepresentation3x2TopRightBlue)
  }

  @Test func scaledImageShouldBeCorrectRotation() throws {
    let imageURL = try #require(
      Bundle(for: ImagePickerTestImages.self).url(
        forResource: "jpgImageWithRightOrientation", withExtension: "jpg"))
    let imageData = try Data(contentsOf: imageURL)
    let image = try #require(UIImage(data: imageData))
    #expect(image.size.width == 130)
    #expect(image.size.height == 174)
    #expect(image.imageOrientation == .right)

    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 10, maxHeight: 10, isMetadataAvailable: true)!
    #expect(newImage.size.width == 10)
    #expect(newImage.size.height == 7)
    #expect(newImage.imageOrientation == .up)
  }

  @Test func scaledGIFImageShouldBeScaled() {
    let info = FLTImagePickerImageUtil.scaledGIFImage(
      ImagePickerTestImages.gifTestData, maxWidth: 3, maxHeight: 2)
    #expect(info.images.count == 3)
    #expect(info.interval == 1)
    for newImage in info.images {
      #expect(newImage.size.width == 3)
      #expect(newImage.size.height == 2)
    }
  }

  @Test func scaledImageTallImageShouldBeScaledBelowMaxHeight() {
    let image = UIImage(data: ImagePickerTestImages.jpgTallTestData)!
    #expect(image.size.width == 4)
    #expect(image.size.height == 7)
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 5, maxHeight: 5, isMetadataAvailable: true)!
    #expect(newImage.size.width == 3)
    #expect(newImage.size.height == 5)
  }

  @Test func scaledImageTallImageShouldBeScaledBelowMaxWidth() {
    let image = UIImage(data: ImagePickerTestImages.jpgTallTestData)!
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 3, maxHeight: 10, isMetadataAvailable: true)!
    #expect(newImage.size.width == 3)
    #expect(newImage.size.height == 5)
  }

  @Test func scaledImageTallImageShouldNotBeScaledAboveOriginalWidthOrHeight() {
    let image = UIImage(data: ImagePickerTestImages.jpgTallTestData)!
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 10, maxHeight: 10, isMetadataAvailable: true)!
    #expect(newImage.size.width == 4)
    #expect(newImage.size.height == 7)
  }

  @Test func scaledImageWideImageShouldBeScaledBelowMaxHeight() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    #expect(image.size.width == 12)
    #expect(image.size.height == 7)
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 20, maxHeight: 6, isMetadataAvailable: true)!
    #expect(newImage.size.width == 10)
    #expect(newImage.size.height == 6)
  }

  @Test func scaledImageWideImageShouldBeScaledBelowMaxWidth() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 10, maxHeight: 10, isMetadataAvailable: true)!
    #expect(newImage.size.width == 10)
    #expect(newImage.size.height == 6)
  }

  @Test func scaledImageWideImageShouldNotBeScaledAboveOriginalWidthOrHeight() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 100, maxHeight: 100, isMetadataAvailable: true)!
    #expect(newImage.size.width == 12)
    #expect(newImage.size.height == 7)
  }

  @Test func scaledImageImageIsNil() {
    let newImage = FLTImagePickerImageUtil.scaledImage(
      nil, maxWidth: 1440, maxHeight: 1440, isMetadataAvailable: true)
    #expect(newImage == nil)
  }

  @Test func scaledImageImageMaxWidthZeroAndMaxHeightIsZero() {
    let image = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let newImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 0, maxHeight: 0, isMetadataAvailable: true)
    #expect(newImage == nil)
  }

  @Test func scaledGIFImageUsesClampedDelayWhenUnclampedDelayMissing() {
    let frame = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let gifData = NSMutableData()
    let destination = CGImageDestinationCreateWithData(
      gifData, UTType.gif.identifier as CFString, 2, nil)!
    let frameProperties: [CFString: Any] = [
      kCGImagePropertyGIFDictionary: [
        kCGImagePropertyGIFDelayTime: 0.25
      ]
    ]
    CGImageDestinationAddImage(destination, frame.cgImage!, frameProperties as CFDictionary)
    CGImageDestinationAddImage(destination, frame.cgImage!, frameProperties as CFDictionary)
    #expect(CGImageDestinationFinalize(destination))

    let info = FLTImagePickerImageUtil.scaledGIFImage(
      gifData as Data, maxWidth: 3, maxHeight: 2)
    #expect(info.images.count == 2)
    #expect(abs(info.interval - 0.25) < 0.001)
  }

  /// Regression for a 10-bit wide-gamut source requesting an unsupported bitmap
  /// context and producing an empty JPEG. See flutter/flutter#185623.
  @Test func scaledImage10BitWideGamutImageCanBeEncodedAsJPEG() throws {
    guard #available(iOS 17.0, *) else {
      return
    }
    let displayP3 = try #require(CGColorSpace(name: CGColorSpace.displayP3))
    let color = try #require(
      CIColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 1.0, colorSpace: displayP3))
    let ciImage = CIImage(color: color).cropped(to: CGRect(x: 0, y: 0, width: 2880, height: 2160))
    let ciContext = CIContext(options: nil)
    let cgImage = ciContext.createCGImage(
      ciImage, from: ciImage.extent, format: .RGB10, colorSpace: displayP3)
    #expect(cgImage != nil)
    guard let cgImage else {
      return
    }
    #expect(cgImage.bitsPerComponent == 10)

    let image = UIImage(cgImage: cgImage)
    let scaledImage = FLTImagePickerImageUtil.scaledImage(
      image, maxWidth: 1920, maxHeight: 1920, isMetadataAvailable: true)!
    #expect(scaledImage.size.width == 1920)
    #expect(scaledImage.size.height == 1440)

    let encodedData = FLTImagePickerMetaDataUtil.convert(
      scaledImage, using: FLTImagePickerMIMETypeJPEG, quality: 0.8)
    #expect(!encodedData.isEmpty)
    #expect(UIImage(data: encodedData) != nil)
  }
}
