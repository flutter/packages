// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers

@testable import image_picker_ios

@Suite
struct PickerSaveImageToPathOperationTests {
  private var testBundle: Bundle {
    Bundle(for: ImagePickerTestImages.self)
  }

  private func pickerItem(forResource name: String, ext: String) throws -> FakePickerItem {
    let imageURL = try #require(testBundle.url(forResource: name, withExtension: ext))
    let itemProvider = NSItemProvider(contentsOf: imageURL)!
    return FakePickerItem(
      itemProvider: itemProvider,
      assetIdentifier: itemProvider.registeredTypeIdentifiers.first)
  }

  /// Starts `operation` and suspends until its `completionBlock` runs.
  ///
  /// Swift Testing `confirmation` does not wait after its body returns, so
  /// async `NSOperation` work must be awaited with a continuation.
  private func runUntilFinished(_ operation: FLTPHPickerSaveImageToPathOperation) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      let previous = operation.completionBlock
      operation.completionBlock = {
        previous?()
        continuation.resume()
      }
      operation.start()
    }
    #expect(operation.isFinished)
  }

  private func verifySavingImage(
    _ result: PickerItem, fullMetadata: Bool, extension expectedExtension: String
  ) async throws {
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: fullMetadata,
        savedPathBlock: { savedPath, error in
          #expect(error == nil)
          #expect(FileManager.default.fileExists(atPath: savedPath ?? ""))
          #expect(URL(string: savedPath ?? "")?.pathExtension == expectedExtension)
        }))
    await runUntilFinished(operation)
  }

  @Test func saveWebPImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "webpImage", ext: "webp"), fullMetadata: true, extension: "jpg")
  }

  @Test func savePNGImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "pngImage", ext: "png"), fullMetadata: true, extension: "png")
  }

  @Test func saveJPGImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "jpgImage", ext: "jpg"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveGIFImage() async throws {
    let imageURL = try #require(testBundle.url(forResource: "gifImage", withExtension: "gif"))
    let itemProvider = NSItemProvider(contentsOf: imageURL)!
    let result = FakePickerItem(
      itemProvider: itemProvider,
      assetIdentifier: itemProvider.registeredTypeIdentifiers.first)
    let dataGIF = try Data(contentsOf: imageURL)
    let imageSource = CGImageSourceCreateWithData(dataGIF as CFData, nil)!
    let numberOfFrames = CGImageSourceGetCount(imageSource)

    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { savedPath, error in
          #expect(FileManager.default.fileExists(atPath: savedPath ?? ""))
          #expect(URL(string: savedPath ?? "")?.pathExtension == "gif")
          let newDataGIF = try? Data(contentsOf: URL(fileURLWithPath: savedPath ?? ""))
          let newImageSource = CGImageSourceCreateWithData(
            (newDataGIF ?? Data()) as CFData, nil)!
          #expect(CGImageSourceGetCount(newImageSource) == numberOfFrames)
        }))
    await runUntilFinished(operation)
  }

  @Test func saveBMPImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "bmpImage", ext: "bmp"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveHEICImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "heicImage", ext: "heic"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveWithOrientation() async throws {
    let result = try pickerItem(forResource: "jpgImageWithRightOrientation", ext: "jpg")
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 10,
        maxWidth: 10,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { savedPath, error in
          #expect(FileManager.default.fileExists(atPath: savedPath ?? ""))
          #expect(URL(string: savedPath ?? "")?.pathExtension == "jpg")
          let image = UIImage(contentsOfFile: savedPath ?? "")
          #expect(image?.imageOrientation == .right)
          #expect(image?.size.width == 7)
          #expect(image?.size.height == 10)
        }))
    await runUntilFinished(operation)
  }

  @Test func saveICNSImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "icnsImage", ext: "icns"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveICOImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "icoImage", ext: "ico"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveProRAWImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "proRawImage", ext: "dng"), fullMetadata: true, extension: "jpg")
  }

  @Test func saveTIFFImage() async throws {
    try await verifySavingImage(
      try pickerItem(forResource: "tiffImage", ext: "tiff"), fullMetadata: true, extension: "jpg")
  }

  @Test func nonexistentImage() async throws {
    let itemProvider =
      NSItemProvider(
        contentsOf: testBundle.url(forResource: "bogus", withExtension: "png"))
      ?? NSItemProvider()
    let result = FakePickerItem(itemProvider: itemProvider, assetIdentifier: nil)
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: true,
        savedPathBlock: { _, error in
          #expect(error?.code == "invalid_source")
        }))
    await runUntilFinished(operation)
  }

  @Test func failingImageLoad() async throws {
    let loadDataError = NSError(domain: "PHPickerDomain", code: 1234)
    let itemProvider = FailingDataItemProvider(error: loadDataError)
    let result = FakePickerItem(itemProvider: itemProvider, assetIdentifier: nil)
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: true,
        savedPathBlock: { _, error in
          #expect(error?.code == "invalid_image")
          #expect(error?.message == loadDataError.localizedDescription)
          #expect(error?.details as? String == "PHPickerDomain")
        }))
    await runUntilFinished(operation)
  }

  @Test func savePNGImageWithoutFullMetadata() async throws {
    // The operation does not fetch PHAsset when fullMetadata is false (or at all).
    try await verifySavingImage(
      try pickerItem(forResource: "pngImage", ext: "png"), fullMetadata: false, extension: "png")
  }

  @Test func initWithNilResultReturnsNil() {
    let operation = FLTPHPickerSaveImageToPathOperation(
      result: nil,
      maxHeight: 100,
      maxWidth: 100,
      desiredImageQuality: 100,
      fullMetadata: true,
      savedPathBlock: { _, _ in })
    #expect(operation == nil)
  }

  @Test func startWhenCancelledFinishesWithoutSaving() async throws {
    let result = try pickerItem(forResource: "pngImage", ext: "png")
    var savedPathCalled = false
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { _, _ in
          savedPathCalled = true
        }))
    operation.cancel()
    operation.start()
    #expect(operation.isFinished)
    #expect(!savedPathCalled)
    #expect(operation.isConcurrent)
  }

  @Test func saveVideoCopiesFile() async throws {
    let sourcePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(
      UUID().uuidString + ".mov")
    #expect(
      FileManager.default.createFile(
        atPath: sourcePath, contents: Data("video".utf8), attributes: nil))
    let videoURL = URL(fileURLWithPath: sourcePath)
    let result = FakePickerItem(
      itemProvider: MovieItemProvider(movieURL: videoURL), assetIdentifier: nil)
    var copiedPath: String?
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { savedPath, error in
          #expect(error == nil)
          #expect(FileManager.default.fileExists(atPath: savedPath ?? ""))
          copiedPath = savedPath
        }))
    await runUntilFinished(operation)
    try? FileManager.default.removeItem(atPath: sourcePath)
    if let copiedPath {
      try? FileManager.default.removeItem(atPath: copiedPath)
    }
  }

  @Test func saveVideoFailsWhenLoadReturnsError() async throws {
    let loadError = NSError(domain: "PHPickerDomain", code: 1234)
    let result = FakePickerItem(
      itemProvider: MovieItemProvider(loadError: loadError), assetIdentifier: nil)
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { _, error in
          #expect(error?.code == "invalid_image")
          #expect(error?.message == loadError.localizedDescription)
          #expect(error?.details as? String == "PHPickerDomain")
        }))
    await runUntilFinished(operation)
  }

  @Test func saveVideoFailsWhenCopyFails() async throws {
    let missing = URL(fileURLWithPath: "/this/path/does/not/exist.mov")
    let result = FakePickerItem(
      itemProvider: MovieItemProvider(movieURL: missing), assetIdentifier: nil)
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: 100,
        maxWidth: 100,
        desiredImageQuality: 100,
        fullMetadata: false,
        savedPathBlock: { _, error in
          #expect(error?.code == "flutter_image_picker_copy_video_error")
        }))
    await runUntilFinished(operation)
  }
}
