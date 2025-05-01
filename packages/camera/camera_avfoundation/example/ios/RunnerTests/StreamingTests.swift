// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  @testable import camera_avfoundation_objc
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
  private func createCamera() -> (FLTCam, CMSampleBuffer) {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue

    let camera = FLTCam(configuration: configuration, error: nil)
    let sampleBuffer = CameraTestUtils.createTestSampleBuffer()

    return (camera, sampleBuffer)
  }

  func testExceedMaxStreamingPendingFramesCount() {
    let (camera, sampleBuffer) = createCamera()
    let handlerMock = MockImageStreamHandler()

    let finishStartStreamExpectation = expectation(
      description: "Finish startStream")

    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(
      with: messenger, imageStreamHandler: handlerMock,
      completion: {
        _ in
        finishStartStreamExpectation.fulfill()
      })

    waitForExpectations(timeout: 30, handler: nil)

    // Setup mocked event sink after the stream starts
    let streamingExpectation = expectation(
      description: "Must not call handler over maxStreamingPendingFramesCount")

    handlerMock.eventSinkStub = { event in
      streamingExpectation.fulfill()
    }

    let expectation = XCTKVOExpectation(
      keyPath: "isStreamingImages", object: camera, expectedValue: true)
    let result = XCTWaiter.wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, .completed)

    streamingExpectation.expectedFulfillmentCount = 4
    for _ in 0..<10 {
      camera.captureOutput(nil, didOutputSampleBuffer: sampleBuffer, from: nil)
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testReceivedImageStreamData() {
    let (camera, sampleBuffer) = createCamera()
    let handlerMock = MockImageStreamHandler()

    let finishStartStreamExpectation = expectation(
      description: "Finish startStream")

    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(
      with: messenger, imageStreamHandler: handlerMock,
      completion: {
        _ in
        finishStartStreamExpectation.fulfill()
      })

    waitForExpectations(timeout: 30, handler: nil)

    // Setup mocked event sink after the stream starts
    let streamingExpectation = expectation(
      description: "Must be able to call the handler again when receivedImageStreamData is called")
    handlerMock.eventSinkStub = { event in
      streamingExpectation.fulfill()
    }

    let expectation = XCTKVOExpectation(
      keyPath: "isStreamingImages", object: camera, expectedValue: true)
    let result = XCTWaiter.wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, .completed)

    streamingExpectation.expectedFulfillmentCount = 5
    for _ in 0..<10 {
      camera.captureOutput(nil, didOutputSampleBuffer: sampleBuffer, from: nil)
    }

    camera.receivedImageStreamData()
    camera.captureOutput(nil, didOutputSampleBuffer: sampleBuffer, from: nil)

    waitForExpectations(timeout: 30, handler: nil)
  }
}
