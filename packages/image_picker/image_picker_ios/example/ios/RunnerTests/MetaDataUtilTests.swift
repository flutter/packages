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

  @Test func writeMetaData() {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let tmpPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      "image_picker_test.jpg")
    let newData = FLTImagePickerMetaDataUtil.image(fromImage: dataJPG, withMetaData: metaData)
    #expect(FileManager.default.createFile(atPath: tmpPath, contents: newData, attributes: nil))
    let savedTmpImageData = try? Data(contentsOf: URL(fileURLWithPath: tmpPath))
    let tmpMetaData = FLTImagePickerMetaDataUtil.getMetaData(
      fromImageData: savedTmpImageData ?? Data())
    #expect(NSDictionary(dictionary: tmpMetaData).isEqual(to: metaData))
  }

  @Test func updateMetaDataBadData() {
    let imageData = Data()
    let metaData = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: imageData)
    let newData = FLTImagePickerMetaDataUtil.image(fromImage: imageData, withMetaData: metaData)
    #expect(newData == nil)
  }

  @Test func convertImageToData() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataJPG = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypeJPEG, quality: 0.5)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataJPG)
        == FLTImagePickerMIMETypeJPEG)

    let convertedDataPNG = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypePNG, quality: nil)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG)
        == FLTImagePickerMIMETypePNG)

    let convertedJPEGDefaultQuality = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypeJPEG, quality: nil)
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

  @Test func convertImageIgnoresQualityForPNG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedDataPNG = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypePNG, quality: 0.5)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedDataPNG)
        == FLTImagePickerMIMETypePNG)
  }

  @Test func convertImageDefaultsNonJPEGNonPNGToJPEG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let convertedGIF = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypeGIF, quality: 0.5)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedGIF)
        == FLTImagePickerMIMETypeJPEG)

    let convertedOther = FLTImagePickerMetaDataUtil.convert(
      imageJPG, using: FLTImagePickerMIMETypeOther, quality: nil)
    #expect(
      FLTImagePickerMetaDataUtil.getImageMIMEType(fromImageData: convertedOther)
        == FLTImagePickerMIMETypeJPEG)
  }
}
