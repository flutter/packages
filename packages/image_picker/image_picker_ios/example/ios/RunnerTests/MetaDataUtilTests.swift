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
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.jpgTestData)
        == FLTImagePickerMIMETypeJPEG)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.pngTestData)
        == FLTImagePickerMIMETypePNG)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: ImagePickerTestImages.gifTestData)
        == FLTImagePickerMIMETypeGIF)
  }

  @Test func suffixFromType() {
    #expect(FLTImagePickerMetaDataUtil.imageTypeSuffix(from: FLTImagePickerMIMETypeJPEG) == ".jpg")
    #expect(FLTImagePickerMetaDataUtil.imageTypeSuffix(from: FLTImagePickerMIMETypePNG) == ".png")
    #expect(FLTImagePickerMetaDataUtil.imageTypeSuffix(from: FLTImagePickerMIMETypeGIF) == ".gif")
    #expect(FLTImagePickerMetaDataUtil.imageTypeSuffix(from: FLTImagePickerMIMETypeOther) == nil)
  }

  @Test func getMetaData() {
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(
      fromImageData: ImagePickerTestImages.jpgTestData)
    let exif = metaData[kCGImagePropertyExifDictionary as String] as? [String: Any]
    let dimension = exif?[kCGImagePropertyExifPixelXDimension as String] as? NSNumber
    #expect(dimension?.intValue == 12)
  }

  @Test func writeMetaData() throws {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let tmpPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".jpg")
    defer { try? FileManager.default.removeItem(atPath: tmpPath) }
    let newData = FLTImagePickerMetaDataUtil.image(fromImage: dataJPG, withMetaData: metaData)
    #expect(FileManager.default.createFile(atPath: tmpPath, contents: newData, attributes: nil))
    let savedTmpImageData = try Data(contentsOf: URL(fileURLWithPath: tmpPath))
    let tmpMetaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: savedTmpImageData)
    #expect(NSDictionary(dictionary: tmpMetaData).isEqual(to: metaData))
  }

  @Test func updateMetaDataBadData() {
    let imageData = Data()
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: imageData)
    let newData = FLTImagePickerMetaDataUtil.image(fromImage: imageData, withMetaData: metaData)
    #expect(newData == nil)
  }

  @Test func updateMetaDataReturnsNilWhenWritingFails() throws {
    let dataJPG = ImagePickerTestImages.jpgTestData
    // Truncated data is still recognized as JPEG, but has no decodable image, so writing it fails.
    let truncatedJPG = Data(dataJPG.prefix(dataJPG.count / 2))
    #expect(UIImage(data: truncatedJPG) == nil)
    let source = try #require(CGImageSourceCreateWithData(truncatedJPG as CFData, nil))
    #expect(CGImageSourceGetType(source) as String? == "public.jpeg")
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let newData = FLTImagePickerMetaDataUtil.image(fromImage: truncatedJPG, withMetaData: metaData)
    #expect(newData == nil, "Returned \(newData?.count ?? 0) bytes of data.")
  }

  @Test func convertImageToData() throws {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataJPG = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypeJPEG, quality: 0.5))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataJPG)
        == FLTImagePickerMIMETypeJPEG)

    let convertedDataPNG = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypePNG, quality: nil))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG)
        == FLTImagePickerMIMETypePNG)

    let convertedJPEGDefaultQuality = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypeJPEG, quality: nil))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedJPEGDefaultQuality)
        == FLTImagePickerMIMETypeJPEG)
  }

  @Test func getImageMIMETypeFromImageDataUnknownReturnsOther() {
    let data = Data([0x00])
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: data)
        == FLTImagePickerMIMETypeOther)
  }

  @Test func convertImageIgnoresQualityForPNG() throws {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataPNG = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypePNG, quality: 0.5))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG)
        == FLTImagePickerMIMETypePNG)
  }

  @Test func convertImageDefaultsNonJPEGNonPNGToJPEG() throws {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedGIF = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypeGIF, quality: 0.5))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedGIF)
        == FLTImagePickerMIMETypeJPEG)

    let convertedOther = try #require(
      FLTImagePickerMetaDataUtil.convert(
        imageJPG, using: FLTImagePickerMIMETypeOther, quality: nil))
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedOther)
        == FLTImagePickerMIMETypeJPEG)
  }
}
