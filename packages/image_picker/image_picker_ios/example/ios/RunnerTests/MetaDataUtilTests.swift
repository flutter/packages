// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Testing
import UIKit

@testable import image_picker_ios

@Suite
struct MetaDataUtilTests {
  @Test func getImageMIMETypeFromImageData() {
    #expect(
      ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.jpgTestData)
        == .jpeg)
    #expect(
      ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.pngTestData)
        == .png)
    #expect(
      ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.gifTestData)
        == .gif)
  }

  @Test func suffixFromType() {
    #expect(ImagePickerMetaDataUtil.imageTypeSuffix(from: .jpeg) == ".jpg")
    #expect(ImagePickerMetaDataUtil.imageTypeSuffix(from: .png) == ".png")
    #expect(ImagePickerMetaDataUtil.imageTypeSuffix(from: .gif) == ".gif")
    #expect(ImagePickerMetaDataUtil.imageTypeSuffix(from: .other) == nil)
  }

  @Test func getMetaData() {
    let metaData = ImagePickerMetaDataUtil.getMetaData(
      fromImageData: ImagePickerTestImages.jpgTestData)
    let exif = metaData?[kCGImagePropertyExifDictionary as String] as? [String: Any]
    let dimension = exif?[kCGImagePropertyExifPixelXDimension as String] as? NSNumber
    #expect(dimension?.intValue == 12)
  }

  @Test func writeMetaData() throws {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let metaData = ImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let tmpPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".jpg")
    defer { try? FileManager.default.removeItem(atPath: tmpPath) }
    let newData = ImagePickerMetaDataUtil.image(fromImage: dataJPG, withMetaData: metaData)
    #expect(FileManager.default.createFile(atPath: tmpPath, contents: newData, attributes: nil))
    let savedTmpImageData = try Data(contentsOf: URL(fileURLWithPath: tmpPath))
    let tmpMetaData = ImagePickerMetaDataUtil.getMetaData(fromImageData: savedTmpImageData)
    #expect(NSDictionary(dictionary: tmpMetaData ?? [:]).isEqual(to: metaData ?? [:]))
  }

  @Test func updateMetaDataBadData() {
    let imageData = Data()
    let metaData = ImagePickerMetaDataUtil.getMetaData(fromImageData: imageData)
    let newData = ImagePickerMetaDataUtil.image(fromImage: imageData, withMetaData: metaData)
    #expect(newData == nil)
  }

  @Test func convertImageToData() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataJPG = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .jpeg, quality: 0.5)!
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataJPG) == .jpeg)

    let convertedDataPNG = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .png, quality: nil)!
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG) == .png)

    let convertedJPEGDefaultQuality = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .jpeg, quality: nil)!
    #expect(
      ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedJPEGDefaultQuality) == .jpeg)
  }

  @Test func getImageMIMETypeFromImageDataUnknownReturnsOther() {
    let data = Data([0x00])
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: data) == .other)
  }

  @Test func convertImageIgnoresQualityForPNG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataPNG = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .png, quality: 0.5)!
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG) == .png)
  }

  @Test func convertImageDefaultsNonJPEGNonPNGToJPEG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedGIF = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .gif, quality: 0.5)!
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedGIF) == .jpeg)

    let convertedOther = ImagePickerMetaDataUtil.convert(
      imageJPG, usingType: .other, quality: nil)!
    #expect(ImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedOther) == .jpeg)
  }
}
