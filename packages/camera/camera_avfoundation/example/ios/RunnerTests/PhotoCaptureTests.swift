// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Includes test cases related to photo capture operations for FLTCam class.
final class PhotoCaptureTests: XCTestCase {
  private func createCam(with captureSessionQueue: DispatchQueue) -> DefaultCamera {
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue
    return CameraTestUtils.createTestCamera(configuration)
  }

  func testCaptureToFile_mustReportErrorToResultIfSavePhotoDelegateCompletionsWithError() {
    let errorExpectation = expectation(
      description: "Must send error to result if save photo delegate completes with error.")
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)
    let cam = createCam(with: captureSessionQueue)
    let error = NSError(domain: "test", code: 0, userInfo: nil)

    let mockOutput = MockCapturePhotoOutput()
    mockOutput.capturePhotoWithSettingsStub = { settings, photoDelegate in
      let delegate =
        cam.inProgressSavePhotoDelegates.object(forKey: settings.uniqueID)
        as? FLTSavePhotoDelegate
      // Completion runs on IO queue.
      let ioQueue = DispatchQueue(label: "io_queue")
      ioQueue.async {
        delegate?.completionHandler(nil, error)
      }
    }
    cam.capturePhotoOutput = mockOutput

    // `FLTCam::captureToFile` runs on capture session queue.
    captureSessionQueue.async {
      cam.captureToFile { result, error in
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        errorExpectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testCaptureToFile_mustReportPathToResultIfSavePhotoDelegateCompletionsWithPath() {
    let pathExpectation = expectation(
      description: "Must send file path to result if save photo delegate completes with file path.")
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)
    let cam = createCam(with: captureSessionQueue)
    let filePath = "test"

    let mockOutput = MockCapturePhotoOutput()
    mockOutput.capturePhotoWithSettingsStub = { settings, photoDelegate in
      let delegate =
        cam.inProgressSavePhotoDelegates.object(forKey: settings.uniqueID)
        as? FLTSavePhotoDelegate
      // Completion runs on IO queue.
      let ioQueue = DispatchQueue(label: "io_queue")
      ioQueue.async {
        delegate?.completionHandler(filePath, nil)
      }
    }
    cam.capturePhotoOutput = mockOutput

    // `FLTCam::captureToFile` runs on capture session queue.
    captureSessionQueue.async {
      cam.captureToFile { result, error in
        XCTAssertEqual(result, filePath)
        pathExpectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testCaptureToFile_mustReportFileExtensionWithHeifWhenHEVCIsAvailableAndFileFormatIsHEIF() {
    let expectation = self.expectation(
      description: "Test must set extension to heif if availablePhotoCodecTypes contains HEVC.")

    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)
    let cam = createCam(with: captureSessionQueue)
    cam.setImageFileFormat(FCPPlatformImageFileFormat.heif)

    let mockOutput = MockCapturePhotoOutput()
    mockOutput.availablePhotoCodecTypes = [AVVideoCodecType.hevc]
    mockOutput.capturePhotoWithSettingsStub = { settings, photoDelegate in
      let delegate =
        cam.inProgressSavePhotoDelegates.object(forKey: settings.uniqueID)
        as? FLTSavePhotoDelegate
      // Completion runs on IO queue.
      let ioQueue = DispatchQueue(label: "io_queue")
      ioQueue.async {
        delegate?.completionHandler(delegate?.filePath, nil)
      }
    }
    cam.capturePhotoOutput = mockOutput

    // `FLTCam::captureToFile` runs on capture session queue.
    captureSessionQueue.async {
      cam.captureToFile { filePath, error in
        XCTAssertEqual((filePath! as NSString).pathExtension, "heif")
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testCaptureToFile_mustReportFileExtensionWithJpgWhenHEVCNotAvailableAndFileFormatIsHEIF() {
    let expectation = self.expectation(
      description:
        "Test must set extension to jpg if availablePhotoCodecTypes does not contain HEVC.")

    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)
    let cam = createCam(with: captureSessionQueue)
    cam.setImageFileFormat(FCPPlatformImageFileFormat.heif)

    let mockOutput = MockCapturePhotoOutput()
    mockOutput.capturePhotoWithSettingsStub = { settings, photoDelegate in
      let delegate =
        cam.inProgressSavePhotoDelegates.object(forKey: settings.uniqueID)
        as? FLTSavePhotoDelegate
      // Completion runs on IO queue.
      let ioQueue = DispatchQueue(label: "io_queue")
      ioQueue.async {
        delegate?.completionHandler(delegate?.filePath, nil)
      }
    }
    cam.capturePhotoOutput = mockOutput

    // `FLTCam::captureToFile` runs on capture session queue.
    captureSessionQueue.async {
      cam.captureToFile { filePath, error in
        XCTAssertEqual((filePath! as NSString).pathExtension, "jpg")
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testCaptureToFile_handlesTorchMode() {
    let pathExpectation = expectation(
      description: "Must send file path to result if save photo delegate completes with file path.")
    let setTorchExpectation = expectation(
      description: "Should set torch mode to AVCaptureTorchModeOn.")

    let captureDeviceMock = MockCaptureDevice()
    captureDeviceMock.hasTorch = true
    captureDeviceMock.isTorchAvailable = true
    captureDeviceMock.getTorchModeStub = { .auto }
    captureDeviceMock.setTorchModeStub = { mode in
      if mode == .on {
        setTorchExpectation.fulfill()
      }
    }

    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")
    FLTDispatchQueueSetSpecific(captureSessionQueue, FLTCaptureSessionQueueSpecific)
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue
    configuration.captureDeviceFactory = { _ in captureDeviceMock }
    let cam = CameraTestUtils.createTestCamera(configuration)

    let filePath = "test"
    let mockOutput = MockCapturePhotoOutput()
    mockOutput.capturePhotoWithSettingsStub = { settings, photoDelegate in
      let delegate =
        cam.inProgressSavePhotoDelegates.object(forKey: settings.uniqueID)
        as? FLTSavePhotoDelegate
      // Completion runs on IO queue.
      let ioQueue = DispatchQueue(label: "io_queue")
      ioQueue.async {
        delegate?.completionHandler(filePath, nil)
      }
    }
    cam.capturePhotoOutput = mockOutput

    // `FLTCam::captureToFile` runs on capture session queue.
    captureSessionQueue.async {
      cam.setFlashMode(.torch) { _ in }
      cam.captureToFile { result, error in
        XCTAssertEqual(result, filePath)
        pathExpectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
