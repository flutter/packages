// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Testing
import UIKit

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

  /// Runs a save operation and returns the `savedPathBlock` arguments.
  ///
  /// Swift Testing `confirmation` does not wait after its body returns, so the
  /// operation is awaited with a continuation. `#expect` inside `savedPathBlock`
  /// is not recorded on this test: the operation queue has no Swift Testing
  /// task-local context, so a failure there does not fail `xcodebuild test`.
  /// The block still stores the arguments because it runs before the operation
  /// finishes.
  private func runSaveOperation(
    result: PickerItem,
    maxHeight: NSNumber = 100,
    maxWidth: NSNumber = 100,
    desiredImageQuality: NSNumber = 100,
    fullMetadata: Bool
  ) async throws -> (savedPath: String?, error: FlutterError?) {
    nonisolated(unsafe) var savedPath: String?
    nonisolated(unsafe) var savedError: FlutterError?
    let operation = try #require(
      FLTPHPickerSaveImageToPathOperation(
        result: result,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        desiredImageQuality: desiredImageQuality,
        fullMetadata: fullMetadata,
        savedPathBlock: { path, error in
          savedPath = path
          savedError = error
        }))
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      let previous = operation.completionBlock
      operation.completionBlock = {
        previous?()
        continuation.resume()
      }
      operation.start()
    }
    #expect(operation.isFinished)
    return (savedPath, savedError)
  }

  private func verifySavingImage(
    _ result: PickerItem, fullMetadata: Bool, extension expectedExtension: String
  ) async throws {
    let (savedPath, savedError) = try await runSaveOperation(
      result: result, fullMetadata: fullMetadata)
    #expect(savedError == nil)
    let path = try #require(savedPath)
    defer { try? FileManager.default.removeItem(atPath: path) }
    #expect(FileManager.default.fileExists(atPath: path))
    #expect(URL(fileURLWithPath: path).pathExtension == expectedExtension)
  }

  @Test(arguments: [
    ("webpImage", "webp", true, "jpg"),
    ("pngImage", "png", true, "png"),
    ("jpgImage", "jpg", true, "jpg"),
    ("bmpImage", "bmp", true, "jpg"),
    ("heicImage", "heic", true, "jpg"),
    ("icnsImage", "icns", true, "jpg"),
    ("icoImage", "ico", true, "jpg"),
    ("proRawImage", "dng", true, "jpg"),
    ("tiffImage", "tiff", true, "jpg"),
    // fullMetadata false skips the PHAsset lookup.
    ("pngImage", "png", false, "png"),
  ])
  func saveImage(resource: String, ext: String, fullMetadata: Bool, expectedExtension: String)
    async throws
  {
    try await verifySavingImage(
      try pickerItem(forResource: resource, ext: ext), fullMetadata: fullMetadata,
      extension: expectedExtension)
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

    let (savedPath, savedError) = try await runSaveOperation(
      result: result, fullMetadata: false)
    #expect(savedError == nil)
    let path = try #require(savedPath)
    defer { try? FileManager.default.removeItem(atPath: path) }
    #expect(FileManager.default.fileExists(atPath: path))
    #expect(URL(fileURLWithPath: path).pathExtension == "gif")
    let newDataGIF = try Data(contentsOf: URL(fileURLWithPath: path))
    let newImageSource = try #require(CGImageSourceCreateWithData(newDataGIF as CFData, nil))
    #expect(CGImageSourceGetCount(newImageSource) == numberOfFrames)
  }

  @Test func saveWithOrientation() async throws {
    let result = try pickerItem(forResource: "jpgImageWithRightOrientation", ext: "jpg")
    let (savedPath, savedError) = try await runSaveOperation(
      result: result, maxHeight: 10, maxWidth: 10, fullMetadata: false)
    #expect(savedError == nil)
    let path = try #require(savedPath)
    defer { try? FileManager.default.removeItem(atPath: path) }
    #expect(FileManager.default.fileExists(atPath: path))
    #expect(URL(fileURLWithPath: path).pathExtension == "jpg")
    let image = try #require(UIImage(contentsOfFile: path))
    #expect(image.imageOrientation == .right)
    #expect(image.size.width == 7)
    #expect(image.size.height == 10)
  }

  @Test func nonexistentImage() async throws {
    let itemProvider =
      NSItemProvider(
        contentsOf: testBundle.url(forResource: "bogus", withExtension: "png"))
      ?? NSItemProvider()
    let result = FakePickerItem(itemProvider: itemProvider, assetIdentifier: nil)
    let (_, savedError) = try await runSaveOperation(result: result, fullMetadata: true)
    #expect(savedError?.code == "invalid_source")
  }

  @Test func failingImageLoad() async throws {
    let loadDataError = NSError(domain: "PHPickerDomain", code: 1234)
    let itemProvider = FailingDataItemProvider(error: loadDataError)
    let result = FakePickerItem(itemProvider: itemProvider, assetIdentifier: nil)
    let (_, savedError) = try await runSaveOperation(result: result, fullMetadata: true)
    #expect(savedError?.code == "invalid_image")
    #expect(savedError?.message == loadDataError.localizedDescription)
    #expect(savedError?.details as? String == "PHPickerDomain")
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
    let (copiedPath, savedError) = try await runSaveOperation(
      result: result, fullMetadata: false)
    #expect(savedError == nil)
    let path = try #require(copiedPath)
    #expect(FileManager.default.fileExists(atPath: path))
    try? FileManager.default.removeItem(atPath: sourcePath)
    try? FileManager.default.removeItem(atPath: path)
  }

  @Test func saveVideoFailsWhenLoadReturnsError() async throws {
    let loadError = NSError(domain: "PHPickerDomain", code: 1234)
    let result = FakePickerItem(
      itemProvider: MovieItemProvider(loadError: loadError), assetIdentifier: nil)
    let (_, savedError) = try await runSaveOperation(result: result, fullMetadata: false)
    #expect(savedError?.code == "invalid_image")
    #expect(savedError?.message == loadError.localizedDescription)
    #expect(savedError?.details as? String == "PHPickerDomain")
  }

  @Test func saveVideoFailsWhenCopyFails() async throws {
    let missing = URL(fileURLWithPath: "/this/path/does/not/exist.mov")
    let result = FakePickerItem(
      itemProvider: MovieItemProvider(movieURL: missing), assetIdentifier: nil)
    let (_, savedError) = try await runSaveOperation(result: result, fullMetadata: false)
    #expect(savedError?.code == "flutter_image_picker_copy_video_error")
  }
}
