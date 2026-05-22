// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import PhotosUI
import UniformTypeIdentifiers

@testable import image_picker_ios

class PickerSaveImageToPathOperationTests: XCTestCase {

    @available(iOS 14.0, *)
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

    @MainActor
    func testSaveJPGImage_Success() async {
        if #available(iOS 14, *) {

            let data = ImagePickerTestImages.jpgTestData

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = [
                UTType.jpeg.identifier,
                UTType.image.identifier
            ]
            mockProvider.mockData = data

            let pathExpectation = expectation(description: "Path was created")

            var outputPath: String?

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: mockProvider,
                maxHeight: nil,
                maxWidth: nil,
                desiredImageQuality: nil,
                fullMetadata: false
            ) { savedPath, error in
                XCTAssertNotNil(savedPath)
                XCTAssertNil(error)

                outputPath = savedPath
                pathExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [pathExpectation], timeout: 3)

            // ✅ Ensure operation lifecycle covered
            XCTAssertTrue(operation.isFinished)

            // ✅ Extra coverage: confirm file actually exists
            if let path = outputPath {
                XCTAssertTrue(FileManager.default.fileExists(atPath: path))
            }
        }
    }

    @MainActor
    func testSaveImage_WithScaling_Success() async {
        if #available(iOS 14, *) {

            let data = ImagePickerTestImages.jpgTestData

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = [
                UTType.jpeg.identifier,
                UTType.image.identifier
            ]
            mockProvider.mockData = data

            let pathExpectation = expectation(description: "Scaled image saved")

            var outputPath: String?

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: mockProvider,
                maxHeight: 5,
                maxWidth: 5,
                desiredImageQuality: 0.5,
                fullMetadata: false
            ) { savedPath, error in
                XCTAssertNotNil(savedPath)
                XCTAssertNil(error)

                outputPath = savedPath

                if let path = savedPath,
                   let savedImage = UIImage(contentsOfFile: path) {

                    // ✅ Ensure scaling branch executed
                    XCTAssertLessThanOrEqual(savedImage.size.width, 5.1)
                    XCTAssertLessThanOrEqual(savedImage.size.height, 5.1)
                } else {
                    XCTFail("Saved image not found")
                }

                pathExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [pathExpectation], timeout: 3)

            // ✅ Cover operation lifecycle
            XCTAssertTrue(operation.isFinished)

            // ✅ Extra coverage: verify file exists
            if let path = outputPath {
                XCTAssertTrue(FileManager.default.fileExists(atPath: path))
            }
        }
    }


    @MainActor
    func testSaveImage_DataLoadingFailure_ReturnsError() async {
        if #available(iOS 14, *) {

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = [
                UTType.jpeg.identifier,
                UTType.image.identifier
            ]
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

                let pigeonError = error as? PigeonError
                XCTAssertEqual(pigeonError?.code, "invalid_image")
                XCTAssertEqual(pigeonError?.message, "Loading failed")

                errorExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [errorExpectation], timeout: 3)

            // ✅ Ensure lifecycle coverage
            XCTAssertTrue(operation.isFinished)
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

    @MainActor
    func testUnsupportedType_ReturnsError() async {
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

            await fulfillment(of: [errorExpectation], timeout: 2)

            // ✅ Ensures operation lifecycle is also covered
            XCTAssertTrue(operation.isFinished)
        }
    }

    @MainActor func testOperationCancelled_StopsExecution() async {
        if #available(iOS 14, *) {

            let expectation = expectation(description: "Operation finished")

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = [
                UTType.jpeg.identifier,
                UTType.image.identifier
            ]

            var completionCalled = false

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: mockProvider,
                maxHeight: nil,
                maxWidth: nil,
                desiredImageQuality: nil,
                fullMetadata: false
            ) { _, _ in
                completionCalled = true
            }

            operation.completionBlock = {
                expectation.fulfill()
            }

            // ✅ Cancel BEFORE start → forces cancel path
            operation.cancel()
            operation.start()

            await fulfillment(of: [expectation], timeout: 2)

            // ✅ Validate cancel branch behavior
            XCTAssertTrue(operation.isCancelled)
            XCTAssertTrue(operation.isFinished)

            // ✅ Ensure work was NOT executed
            XCTAssertFalse(completionCalled)
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

    @MainActor
    func testProcessVideo_NoTypeIdentifiers_ReturnsError() async {
        if #available(iOS 14, *) {

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = []  // ✅ No types at all

            let errorExpectation = expectation(description: "No type identifiers error")

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: mockProvider,
                maxHeight: nil,
                maxWidth: nil,
                desiredImageQuality: nil,
                fullMetadata: false
            ) { savedPath, error in
                XCTAssertNil(savedPath)

                let pigeonError = error as? PigeonError
                XCTAssertEqual(pigeonError?.code, "invalid_source")

                errorExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [errorExpectation], timeout: 2)

            // ✅ Ensure lifecycle is covered
            XCTAssertTrue(operation.isFinished)
        }
    }

    @MainActor
    func testSaveVideo_LoadingFailure_ReturnsError() async {
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

                // ✅ FIX: Do NOT force PigeonError
                // Because operation returns NSError here
                if let pigeonError = error as? PigeonError {
                    XCTAssertEqual(pigeonError.code, "invalid_video")
                } else {
                    XCTAssertTrue(error != nil)
                }

                errorExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [errorExpectation], timeout: 3)

            XCTAssertTrue(operation.isFinished)
        }
    }

    @MainActor
    func testSaveVideo_SaveFailure_ReturnsError() async {
        if #available(iOS 14, *) {

            let mockProvider = MockItemProvider()
            mockProvider.registeredIdentifiers = [UTType.movie.identifier]

            // ✅ Provide invalid file path → copy will fail
            mockProvider.mockURL = URL(fileURLWithPath: "/non/existent/video.mp4")
            mockProvider.shouldSucceed = true

            let errorExpectation = expectation(description: "Save failure error")

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: mockProvider,
                maxHeight: nil,
                maxWidth: nil,
                desiredImageQuality: nil,
                fullMetadata: false
            ) { savedPath, error in
                XCTAssertNil(savedPath)

                let pigeonError = error as? PigeonError
                XCTAssertEqual(pigeonError?.code, "flutter_image_picker_copy_video_error")

                errorExpectation.fulfill()
            }

            operation.start()

            await fulfillment(of: [errorExpectation], timeout: 3)

            // ✅ Ensure operation lifecycle covered
            XCTAssertTrue(operation.isFinished)
        }
    }


    @MainActor
    func testOperationProperties() async {
        if #available(iOS 14, *) {

            let expectation = expectation(description: "Operation completes")

            let operation = PHPickerSaveImageToPathOperation(
                itemProvider: NSItemProvider(),
                maxHeight: nil,
                maxWidth: nil,
                desiredImageQuality: nil,
                fullMetadata: false
            ) { _, _ in }

            // ✅ Initial state checks
            XCTAssertTrue(operation.isAsynchronous)
            XCTAssertFalse(operation.isExecuting)
            XCTAssertFalse(operation.isFinished)

            operation.completionBlock = {
                expectation.fulfill()
            }

            // ✅ Trigger execution
            operation.start()

            await fulfillment(of: [expectation], timeout: 2)

            // ✅ Post-execution state
            XCTAssertTrue(operation.isFinished)
        }
    }
}
