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
    defer { try? FileManager.default.removeItem(atPath: sourcePath) }
    #expect(
      FileManager.default.createFile(
        atPath: sourcePath, contents: Data("video".utf8), attributes: nil))
    let destination = FLTImagePickerPhotoAssetUtil.saveVideo(
      from: URL(fileURLWithPath: sourcePath))
    let copied = try #require(destination)
    defer { try? FileManager.default.removeItem(at: copied) }
    #expect(FileManager.default.fileExists(atPath: copied.path))
  }

  @Test func saveImageWithOriginalImageDataNilUsesDefaultJPEG() throws {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPath = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withOriginalImageData: nil, image: imageJPG, maxWidth: nil, maxHeight: nil,
        imageQuality: nil))
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "jpg")
    try? FileManager.default.removeItem(atPath: savedPath)
  }

  @Test func saveImageWithOriginalImageDataShouldSaveWithTheCorrectExtensionAndMetaData() throws {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let imageJPG = UIImage(data: dataJPG)!
    let savedPathJPG = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withOriginalImageData: dataJPG, image: imageJPG, maxWidth: nil, maxHeight: nil,
        imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
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
    let savedPathPNG = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withOriginalImageData: dataPNG, image: imagePNG, maxWidth: nil, maxHeight: nil,
        imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathPNG) }
    #expect(URL(string: savedPathPNG)?.pathExtension == "png")

    let originalMetaDataPNG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: dataPNG)
    let newDataPNG = try? Data(contentsOf: URL(fileURLWithPath: savedPathPNG))
    let newMetaDataPNG = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: newDataPNG ?? Data())
    #expect(
      (originalMetaDataPNG["ProfileName"] as? String)
        == (newMetaDataPNG["ProfileName"] as? String)
    )
  }

  @Test func saveImageWithPickerInfoShouldSaveWithDefaultExtension() throws {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPathJPG = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withPickerInfo: nil, image: imageJPG, imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
    #expect(
      (savedPathJPG as NSString).substring(from: savedPathJPG.count - 4)
        == kFLTImagePickerDefaultSuffix
    )
  }

  @Test func saveImageWithPickerInfoShouldSaveWithTheCorrectExtensionAndMetaData() throws {
    let dummyInfo: [String: Any] = [
      UIImagePickerController.InfoKey.mediaMetadata.rawValue: [
        kCGImagePropertyExifDictionary as String: [
          kCGImagePropertyExifUserComment as String: "aNote"
        ]
      ]
    ]
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPathJPG = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withPickerInfo: dummyInfo, image: imageJPG, imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
    let data = try? Data(contentsOf: URL(fileURLWithPath: savedPathJPG))
    let meta = FLTImagePickerMetaDataUtil.getMetaData(fromImageData: data ?? Data())
    let comment =
      (meta[kCGImagePropertyExifDictionary as String] as? [String: Any])?[
        kCGImagePropertyExifUserComment as String] as? String
    #expect(comment == "aNote")
  }

  @Test func saveImageWithPickerInfoReturnsNilWhenImageCannotBeEncoded() {
    // An image with no underlying bitmap cannot be encoded as JPEG, so there is no data to save.
    let savedPath = FLTImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: nil, image: UIImage(), imageQuality: nil)
    let savedData = savedPath.flatMap { FileManager.default.contents(atPath: $0) }
    #expect(savedPath == nil, "Returned a path to a \(savedData?.count ?? 0)-byte file.")
    if let savedPath { try? FileManager.default.removeItem(atPath: savedPath) }
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsGifAnimation() throws {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withOriginalImageData: dataGIF, image: imageGIF, maxWidth: nil, maxHeight: nil,
        imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathGIF) }
    #expect(URL(string: savedPathGIF)?.pathExtension == "gif")

    let newDataGIF = try Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImageSource = try #require(CGImageSourceCreateWithData(newDataGIF as CFData, nil))
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsScaledGifAnimation() throws {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = try #require(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withOriginalImageData: dataGIF, image: imageGIF, maxWidth: 3, maxHeight: 2,
        imageQuality: nil))
    defer { try? FileManager.default.removeItem(atPath: savedPathGIF) }
    let newDataGIF = try Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImage = try #require(UIImage(data: newDataGIF))
    #expect(newImage.size.width == 3)
    #expect(newImage.size.height == 2)

    let newImageSource = try #require(CGImageSourceCreateWithData(newDataGIF as CFData, nil))
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
  }

  @Test func saveImageWithOriginalImageDataReturnsNilWhenGIFCannotBeSaved() {
    // Only the GIF header and logical screen descriptor, so there are no frames to write.
    let truncatedGIF = Data(ImagePickerTestImages.gifTestData.prefix(13))
    #expect(UIImage(data: truncatedGIF) == nil)

    let savedPath = FLTImagePickerPhotoAssetUtil.saveImage(
      withOriginalImageData: truncatedGIF, image: nil, maxWidth: nil, maxHeight: nil,
      imageQuality: nil)
    let fileExists = savedPath.map { FileManager.default.fileExists(atPath: $0) } ?? false
    #expect(
      savedPath == nil,
      "Returned a path to a file that \(fileExists ? "exists" : "does not exist").")
    if let savedPath { try? FileManager.default.removeItem(atPath: savedPath) }
  }

  @Test func saveGIFReturnsNilWhenDestinationCannotBeCreated() throws {
    let frame = try #require(UIImage(data: ImagePickerTestImages.gifTestData))
    let gifInfo = GIFInfo(images: [frame], interval: 0.1)
    #expect(
      FLTImagePickerPhotoAssetUtil.saveImage(
        withMetaData: nil, gifInfo: gifInfo, path: "/this/path/does/not/exist.gif") == nil)
  }
}
