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
    #expect(ImagePickerPhotoAssetUtil.getAsset(fromImagePickerInfo: [:]) == nil)
  }

  @Test func getAssetFromImagePickerInfoShouldReturnAssetIfPresent() {
    let mockAsset = PHAsset()
    let info = [UIImagePickerController.InfoKey.phAsset.rawValue: mockAsset]
    #expect(ImagePickerPhotoAssetUtil.getAsset(fromImagePickerInfo: info) === mockAsset)
  }

  @Test func saveVideoFromURLReturnsNilWhenSourceIsUnreadable() {
    let missing = URL(fileURLWithPath: "/this/path/does/not/exist.mov")
    #expect(ImagePickerPhotoAssetUtil.saveVideo(from: missing) == nil)
  }

  @Test func saveVideoFromURLCopiesReadableFile() throws {
    let sourcePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".mov")
    defer { try? FileManager.default.removeItem(atPath: sourcePath) }
    #expect(
      FileManager.default.createFile(
        atPath: sourcePath, contents: Data("video".utf8), attributes: nil))
    let destination = ImagePickerPhotoAssetUtil.saveVideo(
      from: URL(fileURLWithPath: sourcePath))
    let copied = try #require(destination)
    defer { try? FileManager.default.removeItem(at: copied) }
    #expect(FileManager.default.fileExists(atPath: copied.path))
  }

  @Test func saveImageWithOriginalImageDataNilUsesDefaultJPEG() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPath = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      nil, image: imageJPG, maxWidth: nil, maxHeight: nil, imageQuality: nil)
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "jpg")
    try? FileManager.default.removeItem(atPath: savedPath)
  }

  /// The alpha of the pixel at `x`, `y` of the image, 0 to 255.
  private func alpha(of image: UIImage, x: Int, y: Int) throws -> UInt8 {
    let cgImage = try #require(image.cgImage)
    var pixel: [UInt8] = [0, 0, 0, 0]
    let context = try #require(
      CGContext(
        data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
    context.interpolationQuality = .none
    context.draw(
      cgImage,
      in: CGRect(x: -x, y: y + 1 - cgImage.height, width: cgImage.width, height: cgImage.height))
    return pixel[3]
  }

  @Test func saveImageWithOriginalImageDataShouldKeepATransparentWebPAsPNG() throws {
    let data = ImagePickerTestImages.transparentWebPTestData
    let savedPath = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      data, image: UIImage(data: data), maxWidth: nil, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPath) }
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "png")

    let saved = try #require(UIImage(contentsOfFile: savedPath))
    #expect(try alpha(of: saved, x: 2, y: 8) == 0)
    #expect(try alpha(of: saved, x: 13, y: 8) == 255)
  }

  @Test func saveImageWithOriginalImageDataShouldKeepAScaledTransparentWebPAsPNG() throws {
    let data = ImagePickerTestImages.transparentWebPTestData
    let scaled = ImagePickerImageUtil.scaledImage(
      UIImage(data: data), maxWidth: 8, maxHeight: nil, isMetadataAvailable: true)
    let savedPath = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      data, image: scaled, maxWidth: 8, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPath) }
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "png")

    let saved = try #require(UIImage(contentsOfFile: savedPath))
    #expect(saved.size.width == 8)
    #expect(try alpha(of: saved, x: 1, y: 4) == 0)
    #expect(try alpha(of: saved, x: 6, y: 4) == 255)
  }

  @Test func saveImageWithOriginalImageDataShouldStillSaveAnOpaqueWebPAsJPEG() {
    let data = ImagePickerTestImages.opaqueWebPTestData
    let savedPath = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      data, image: UIImage(data: data), maxWidth: nil, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPath) }
    #expect(URL(fileURLWithPath: savedPath).pathExtension == "jpg")
  }

  @Test func saveImageWithOriginalImageDataShouldSaveWithTheCorrectExtensionAndMetaData() throws {
    let dataJPG = ImagePickerTestImages.jpgTestData
    let imageJPG = UIImage(data: dataJPG)!
    let savedPathJPG = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      dataJPG, image: imageJPG, maxWidth: nil, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
    #expect(URL(string: savedPathJPG)?.pathExtension == "jpg")

    let originalMetaDataJPG = ImagePickerMetaDataUtil.getMetaData(fromImageData: dataJPG)
    let newDataJPG = try? Data(contentsOf: URL(fileURLWithPath: savedPathJPG))
    let newMetaDataJPG = ImagePickerMetaDataUtil.getMetaData(fromImageData: newDataJPG ?? Data())
    let originalProfileJPG = try #require(originalMetaDataJPG?["ProfileName"] as? String)
    #expect(originalProfileJPG == newMetaDataJPG?["ProfileName"] as? String)

    let dataPNG = ImagePickerTestImages.pngTestData
    let imagePNG = UIImage(data: dataPNG)!
    let savedPathPNG = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      dataPNG, image: imagePNG, maxWidth: nil, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathPNG) }
    #expect(URL(string: savedPathPNG)?.pathExtension == "png")

    let originalMetaDataPNG = ImagePickerMetaDataUtil.getMetaData(fromImageData: dataPNG)
    let newDataPNG = try? Data(contentsOf: URL(fileURLWithPath: savedPathPNG))
    let newMetaDataPNG = ImagePickerMetaDataUtil.getMetaData(fromImageData: newDataPNG ?? Data())
    let originalProfilePNG = try #require(originalMetaDataPNG?["ProfileName"] as? String)
    #expect(originalProfilePNG == newMetaDataPNG?["ProfileName"] as? String)
  }

  @Test func saveImageWithPickerInfoShouldSaveWithDefaultExtension() {
    let imageJPG = UIImage(data: ImagePickerTestImages.jpgTestData)!
    let savedPathJPG = ImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: nil, image: imageJPG, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
    #expect(
      (savedPathJPG as NSString).substring(from: savedPathJPG.count - 4)
        == kImagePickerDefaultSuffix
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
    let savedPathJPG = ImagePickerPhotoAssetUtil.saveImage(
      withPickerInfo: dummyInfo, image: imageJPG, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathJPG) }
    let data = try? Data(contentsOf: URL(fileURLWithPath: savedPathJPG))
    let meta = ImagePickerMetaDataUtil.getMetaData(fromImageData: data ?? Data())
    let comment =
      (meta?[kCGImagePropertyExifDictionary as String] as? [String: Any])?[
        kCGImagePropertyExifUserComment as String] as? String
    #expect(comment == "aNote")
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsGifAnimation() throws {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      dataGIF, image: imageGIF, maxWidth: nil, maxHeight: nil, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathGIF) }
    #expect(URL(string: savedPathGIF)?.pathExtension == "gif")

    let newDataGIF = try Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImageSource = try #require(CGImageSourceCreateWithData(newDataGIF as CFData, nil))
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
    let properties = CGImageSourceCopyProperties(newImageSource, nil) as? [CFString: Any]
    let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
    #expect((gifProperties?[kCGImagePropertyGIFLoopCount] as? NSNumber)?.intValue == 0)
  }

  @Test func saveImageWithOriginalImageDataShouldSaveAsScaledGifAnimation() throws {
    let dataGIF = ImagePickerTestImages.gifTestData
    let imageGIF = UIImage(data: dataGIF)!
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let savedPathGIF = ImagePickerPhotoAssetUtil.saveImageWithOriginalImageData(
      dataGIF, image: imageGIF, maxWidth: 3, maxHeight: 2, imageQuality: nil)
    defer { try? FileManager.default.removeItem(atPath: savedPathGIF) }
    let newDataGIF = try Data(contentsOf: URL(fileURLWithPath: savedPathGIF))
    let newImage = try #require(UIImage(data: newDataGIF))
    #expect(newImage.size.width == 3)
    #expect(newImage.size.height == 2)

    let newImageSource = try #require(CGImageSourceCreateWithData(newDataGIF as CFData, nil))
    let newNumberOfFrames = CGImageSourceGetCount(newImageSource)
    #expect(numberOfFrames == newNumberOfFrames)
    let properties = CGImageSourceCopyProperties(newImageSource, nil) as? [CFString: Any]
    let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
    #expect((gifProperties?[kCGImagePropertyGIFLoopCount] as? NSNumber)?.intValue == 0)
  }
}
