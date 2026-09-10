// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Photos
import Testing
import UIKit

@testable import image_picker_ios

@Suite
struct PhotoAssetUtilTests {
  @Test func getAssetFromImagePickerInfoShouldReturnNilIfNotAvailable() {
    #expect(FLTImagePickerPhotoAssetUtil.getAssetFromImagePickerInfo([:]) == nil)
  }

  @Test func getAssetFromImagePickerInfoShouldReturnAssetIfPresent() {
    let mockAsset = PHAsset()
    let info = [UIImagePickerController.InfoKey.phAsset.rawValue: mockAsset]
    #expect(FLTImagePickerPhotoAssetUtil.getAssetFromImagePickerInfo(info) === mockAsset)
  }

  @Test func saveVideoFromURLReturnsNilWhenSourceIsUnreadable() {
    let missing = URL(fileURLWithPath: "/this/path/does/not/exist.mov")
    #expect(FLTImagePickerPhotoAssetUtil.saveVideo(from: missing) == nil)
  }

  @Test func saveVideoFromURLCopiesReadableFile() throws {
    let sourcePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".mov")
    #expect(
      FileManager.default.createFile(
        atPath: sourcePath, contents: Data("video".utf8), attributes: nil))
    let destination = FLTImagePickerPhotoAssetUtil.saveVideo(
      from: URL(fileURLWithPath: sourcePath))
    let copied = try #require(destination)
    #expect(FileManager.default.fileExists(atPath: copied.path))
    try? FileManager.default.removeItem(at: copied)
    try? FileManager.default.removeItem(atPath: sourcePath)
  }

  @Test func saveImageWithOriginalImageDataNilUsesDefaultJPEG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPath = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: nil, image: imageJPG, maxWidth: nil, maxHeight: nil,
      imageQuality: nil)
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "jpg")
    try? FileManager.default.removeItem(atPath: savedPath)
  }

  @Test func saveImageWithOriginalImageDataShouldSaveWithTheCorrectExtensionAndMetaData() {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let imageJPG = UIImage(data: dataJPG)!
    let savedPathJPG = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: dataJPG, image: imageJPG, maxWidth: nil, maxHeight: nil,
      imageQuality: nil)
    #expect(URL(string: savedPathJPG)?.pathExtension == "jpg")

    let originalMetaDataJPG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let newDataJPG = try? Data(contentsOf: URL(fileURLWithPath: savedPathJPG))
    let newMetaDataJPG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: newDataJPG ?? Data())
    #expect(
      (originalMetaDataJPG["ProfileName"] as? String)
        == (newMetaDataJPG["ProfileName"] as? String)
    )

    let dataPNG = ImagePickerTestImages.pngTestData
    let imagePNG = UIImage(data: dataPNG)!
    let savedPathPNG = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: dataPNG, image: imagePNG, maxWidth: nil, maxHeight: nil,
      imageQuality: nil)
    #expect(URL(string: savedPathPNG)?.pathExtension == "png")

    let originalMetaDataPNG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataPNG)
    let newDataPNG = try? Data(contentsOf: URL(fileURLWithPath: savedPathPNG))
    let newMetaDataPNG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: newDataPNG ?? Data())
    #expect(
      (originalMetaDataPNG["ProfileName"] as? String)
        == (newMetaDataPNG["ProfileName"] as? String)
    )
  }

  @Test func saveImageWithPickerInfoShouldSaveWithDefaultExtension() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPathJPG = FLTImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: nil, image: imageJPG, imageQuality: nil)
    #expect(
      (savedPathJPG as NSString).substring(from: savedPathJPG.count - 4)
        == kFLTImagePickerDefaultSuffix
    )
  }

  @Test func saveImageWithPickerInfoShouldSaveWithTheCorrectExtensionAndMetaData() {
    let dummyInfo: [String: Any] = [
      UIImagePickerController.InfoKey.mediaMetadata.rawValue: [
        kCGImagePropertyExifDictionary as String: [
          kCGImagePropertyExifUserComment as String: "aNote"
        ]
      ]
    ]
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPathJPG = FLTImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: dummyInfo, image: imageJPG, imageQuality: nil)
    let data = try? Data(contentsOf: URL(fileURLWithPath: savedPathJPG))
    let meta = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: data ?? Data())
    let comment =
      (meta[kCGImagePropertyExifDictionary as String] as? [String: Any])?[
        kCGImagePropertyExifUserComment as String] as? String
    #expect(comment == "aNote")
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsGifAnimation() {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: dataGIF, image: imageGIF, maxWidth: nil, maxHeight: nil,
      imageQuality: nil)
    #expect(URL(string: savedPathGIF)?.pathExtension == "gif")

    let newDataGIF = try? Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImageSource = CGImageSourceCreateWithData((newDataGIF ?? Data()) as CFData, nil)!
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsScaledGifAnimation() {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: dataGIF, image: imageGIF, maxWidth: 3, maxHeight: 2, imageQuality: nil)
    let newDataGIF = try? Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImage = UIImage(data: newDataGIF ?? Data())
    #expect(newImage?.size.width == 3)
    #expect(newImage?.size.height == 2)

    let newImageSource = CGImageSourceCreateWithData((newDataGIF ?? Data()) as CFData, nil)!
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
  }
}
