// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class SavePhotoDelegateTests: XCTestCase {
  func testHandlePhotoCaptureResult_mustCompleteWithErrorIfFailedToCapture() {
    let completionExpectation = expectation(
      description: "Must complete with error if failed to capture photo.")
    let captureError = NSError(domain: "test", code: 0, userInfo: nil)
    let ioQueue = DispatchQueue(label: "test")
    let delegate = FLTSavePhotoDelegate(path: "test", ioQueue: ioQueue) { path, error in
      XCTAssertEqual(captureError, error as NSError?)
      XCTAssertNil(path)
      completionExpectation.fulfill()
    }

    delegate.handlePhotoCaptureResult(error: captureError) { nil }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testHandlePhotoCaptureResult_mustCompleteWithErrorIfFailedToWrite() {
    let completionExpectation = expectation(
      description: "Must complete with error if failed to write file.")
    let ioQueue = DispatchQueue(label: "test")
    let ioError = NSError(
      domain: "IOError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Localized IO Error"])
    let delegate = FLTSavePhotoDelegate(path: "test", ioQueue: ioQueue) { path, error in
      XCTAssertEqual(ioError, error as NSError?)
      XCTAssertNil(path)
      completionExpectation.fulfill()
    }

    let mockWritableData = MockWritableData()
    mockWritableData.writeToFileStub = { path, options, error in
      // TODO(FirentisTFW) Throw an error instead when migrating FLTWritableData to Swift
      error?.pointee = ioError
      return false
    }

    delegate.handlePhotoCaptureResult(error: nil) { mockWritableData }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testHandlePhotoCaptureResult_mustCompleteWithFilePathIfSuccessToWrite() {
    let completionExpectation = expectation(
      description: "Must complete with file path if succeeds to write file.")
    let ioQueue = DispatchQueue(label: "test")
    let filePath = "test"
    let delegate = FLTSavePhotoDelegate(path: filePath, ioQueue: ioQueue) { path, error in
      XCTAssertNil(error)
      XCTAssertEqual(filePath, path)
      completionExpectation.fulfill()
    }

    let mockWritableData = MockWritableData()
    mockWritableData.writeToFileStub = { path, options, error in
      return true
    }

    delegate.handlePhotoCaptureResult(error: nil) { mockWritableData }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testHandlePhotoCaptureResult_bothProvideDataAndSaveFileMustRunOnIOQueue() {
    let dataProviderQueueExpectation = expectation(
      description: "Data provider must run on io queue.")
    let writeFileQueueExpectation = expectation(description: "File writing must run on io queue.")
    let completionExpectation = expectation(
      description: "Must complete with file path if success to write file.")
    let ioQueue = DispatchQueue(label: "test")
    let ioQueueSpecific = DispatchSpecificKey<Void>()
    ioQueue.setSpecific(key: ioQueueSpecific, value: ())

    let mockWritableData = MockWritableData()
    mockWritableData.writeToFileStub = { path, options, error in
      if DispatchQueue.getSpecific(key: ioQueueSpecific) != nil {
        writeFileQueueExpectation.fulfill()
      }
      return true
    }

    let filePath = "test"
    let delegate = FLTSavePhotoDelegate(path: filePath, ioQueue: ioQueue) { path, error in
      completionExpectation.fulfill()
    }

    delegate.handlePhotoCaptureResult(error: nil) {
      if DispatchQueue.getSpecific(key: ioQueueSpecific) != nil {
        dataProviderQueueExpectation.fulfill()
      }
      return mockWritableData
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
