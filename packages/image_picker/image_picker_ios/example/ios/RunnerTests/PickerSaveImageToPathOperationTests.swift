// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import PhotosUI
import UniformTypeIdentifiers

@testable import image_picker_ios

class PickerSaveImageToPathOperationTests: XCTestCase {

  class MockItemProvider: NSItemProvider {
    var mockData: Data?
    var mockURL: URL?
    var shouldSucceed = true
    var registeredIdentifiers: [String] = [UTType.image.identifier]

    override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
      return registeredIdentifiers.contains(typeIdentifier)
    }

    override func loadDataRepresentation(
      forTypeIdentifier typeIdentifier: String,
      completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress {
      if shouldSucceed {
        completionHandler(mockData, nil)
      } else {
        completionHandler(nil, NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Loading failed"]))
      }
      return Progress()
    }

    override func loadFileRepresentation(
      forTypeIdentifier typeIdentifier: String,
      completionHandler: @escaping (URL?, Error?) -> Void
    ) -> Progress {
      if shouldSucceed {
        completionHandler(mockURL, nil)
      } else {
        completionHandler(nil, NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Loading failed"]))
      }
      return Progress()
    }

    override var registeredTypeIdentifiers: [String] {
      return registeredIdentifiers
    }
  }

  @MainActor func testSaveJPGImage_Success() {
    if #available(iOS 14, *) {
      let data = ImagePickerTestImages.jpgTestData
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = [UTType.jpeg.identifier, UTType.image.identifier]
      mockProvider.mockData = data

      let pathExpectation = expectation(description: "Path was created")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNotNil(savedPath)
        XCTAssertNil(error)
        pathExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testSaveImage_WithScaling_Success() {
    if #available(iOS 14, *) {
      let data = ImagePickerTestImages.jpgTestData
      let mockProvider = MockItemProvider()
      mockProvider.mockData = data

      let pathExpectation = expectation(description: "Scaled image saved")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: 5,
        maxWidth: 5,
        desiredImageQuality: 0.5,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNotNil(savedPath)
        let savedImage = UIImage(contentsOfFile: savedPath!)
        XCTAssertNotNil(savedImage)
        XCTAssertLessThanOrEqual(savedImage!.size.width, 5.1)
        pathExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testSaveImage_DataLoadingFailure_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.shouldSucceed = false

      let errorExpectation = expectation(description: "Error received")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "invalid_image")
        XCTAssertEqual((error as? PigeonError)?.message, "Loading failed")
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testSaveVideo_Success() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = [UTType.movie.identifier]
      let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_op.mp4")
      try? "test".data(using: .utf8)?.write(to: tempURL)
      mockProvider.mockURL = tempURL

      let pathExpectation = expectation(description: "Video path created")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNotNil(savedPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedPath!))
        pathExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
      try? FileManager.default.removeItem(at: tempURL)
    }
  }

  @MainActor func testSaveVideo_NoURL_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = [UTType.movie.identifier]
      mockProvider.mockURL = nil

      let errorExpectation = expectation(description: "Error received for nil URL")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "invalid_image")
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testUnsupportedType_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = ["public.plain-text"]

      let errorExpectation = expectation(description: "Error received for unsupported type")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "invalid_source")
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testOperationCancelled_StopsExecution() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { _, _ in
        XCTFail("Should not be called if cancelled")
      }

      operation.cancel()
      operation.start()
      XCTAssertTrue(operation.isFinished)
    }
  }

  @MainActor func testSaveImage_InvalidDataDecoding_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.mockData = Data("invalid image data".utf8)

      let errorExpectation = expectation(description: "Decoding failure")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "invalid_image")
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testProcessVideo_NoTypeIdentifiers_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = []

      let errorExpectation = expectation(description: "No type identifiers error")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "invalid_source")
        errorExpectation.fulfill()
      }

      // Manually call processVideo if we can, or just start it with no conforming types.
      // start() will hit "invalid_source" if no image or movie conforming type.
      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testSaveVideo_LoadingFailure_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = [UTType.movie.identifier]
      mockProvider.shouldSucceed = false

      let errorExpectation = expectation(description: "Video loading failure")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertNotNil(error)
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testSaveVideo_SaveFailure_ReturnsError() {
    if #available(iOS 14, *) {
      let mockProvider = MockItemProvider()
      mockProvider.registeredIdentifiers = [UTType.movie.identifier]
      mockProvider.mockURL = URL(fileURLWithPath: "/non/existent/video.mp4")

      let errorExpectation = expectation(description: "Save failure error")

      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: mockProvider,
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { savedPath, error in
        XCTAssertNil(savedPath)
        XCTAssertEqual((error as? PigeonError)?.code, "flutter_image_picker_copy_video_error")
        errorExpectation.fulfill()
      }

      operation.start()
      waitForExpectations(timeout: 5)
    }
  }

  @MainActor func testOperationProperties() {
    if #available(iOS 14, *) {
      let operation = PHPickerSaveImageToPathOperation(
        itemProvider: NSItemProvider(),
        maxHeight: nil,
        maxWidth: nil,
        desiredImageQuality: nil,
        fullMetadata: false
      ) { _, _ in }
      XCTAssertTrue(operation.isAsynchronous)
      XCTAssertFalse(operation.isExecuting)
      XCTAssertFalse(operation.isFinished)
    }
  }
}
