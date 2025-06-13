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

private class MockImageStreamHandler: FLTImageStreamHandler {
  var eventSinkStub: ((Any?) -> Void)?

  override var eventSink: FlutterEventSink? {
    get {
      if let stub = eventSinkStub {
        return { event in
          stub(event)
        }
      }
      return nil
    }
    set {
      eventSinkStub = newValue
    }
  }

}

final class StreamingTests: XCTestCase {
  private func createCamera() -> (
    DefaultCamera,
    AVCaptureOutput,
    CMSampleBuffer,
    AVCaptureConnection
  ) {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue

    let camera = CameraTestUtils.createTestCamera(configuration)
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let sampleBuffer = CameraTestUtils.createTestSampleBuffer()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    return (camera, testAudioOutput, sampleBuffer, testAudioConnection)
  }

  func testExceedMaxStreamingPendingFramesCount() {
    let (camera, testAudioOutput, sampleBuffer, testAudioConnection) = createCamera()
    let streamingExpectation = expectation(
      description: "Must not call handler over maxStreamingPendingFramesCount")
    let handlerMock = MockImageStreamHandler()
    handlerMock.eventSinkStub = { event in
      streamingExpectation.fulfill()
    }
    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(with: messenger, imageStreamHandler: handlerMock)

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(camera.isStreamingImages, true)

    streamingExpectation.expectedFulfillmentCount = 4
    for _ in 0..<10 {
      camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testReceivedImageStreamData() {
    let (camera, testAudioOutput, sampleBuffer, testAudioConnection) = createCamera()
    let streamingExpectation = expectation(
      description: "Must be able to call the handler again when receivedImageStreamData is called")
    let handlerMock = MockImageStreamHandler()
    handlerMock.eventSinkStub = { event in
      streamingExpectation.fulfill()
    }
    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(with: messenger, imageStreamHandler: handlerMock)

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(camera.isStreamingImages, true)

    streamingExpectation.expectedFulfillmentCount = 5
    for _ in 0..<10 {
      camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)
    }

    camera.receivedImageStreamData()
    camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testImageStreamEventFormat() {
    let (camera, testAudioOutput, sampleBuffer, testAudioConnection) = createCamera()

    let expectation = expectation(description: "Received a valid event")

    let handlerMock = MockImageStreamHandler()
    handlerMock.eventSinkStub = { event in
      let imageBuffer = event as! [String: Any]

      XCTAssertTrue(imageBuffer["width"] is NSNumber)
      XCTAssertTrue(imageBuffer["height"] is NSNumber)
      XCTAssertTrue(imageBuffer["format"] is NSNumber)
      XCTAssertTrue(imageBuffer["lensAperture"] is NSNumber)
      XCTAssertTrue(imageBuffer["sensorExposureTime"] is NSNumber)
      XCTAssertTrue(imageBuffer["sensorSensitivity"] is NSNumber)

      let planes = imageBuffer["planes"] as! [[String: Any]]
      let planeBuffer = planes[0]

      XCTAssertTrue(planeBuffer["bytesPerRow"] is NSNumber)
      XCTAssertTrue(planeBuffer["width"] is NSNumber)
      XCTAssertTrue(planeBuffer["height"] is NSNumber)
      XCTAssertTrue(planeBuffer["bytes"] is FlutterStandardTypedData)

      expectation.fulfill()
    }
    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(with: messenger, imageStreamHandler: handlerMock)

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(camera.isStreamingImages, true)

    camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)

    waitForExpectations(timeout: 30, handler: nil)
  }
}
