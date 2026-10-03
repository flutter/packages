// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import XCTest

@testable import camera_avfoundation

private class MockEventSink: PigeonEventSink<PlatformCameraImageData> {
  var eventSinkSuccessStub: ((PlatformCameraImageData?) -> Void)?

  init() {
    super.init({ event in })
  }

  override func success(_ event: PlatformCameraImageData?) {
    eventSinkSuccessStub?(event)
  }

  override func error(code: String, message: String?, details: Any?) {}

  override func endOfStream() {}
}

private class MockImageStreamHandler: ImageDataStreamStreamHandler, ImageStreamHandler {
  var mockEventSink = MockEventSink()
  var captureSessionQueue: DispatchQueue {
    preconditionFailure("Attempted to access unimplemented property: captureSessionQueue")
  }
  var eventSink: PigeonEventSink<PlatformCameraImageData>? {
    set {
    }
    get {
      return mockEventSink
    }
  }

  var eventSinkSuccessStub: ((PlatformCameraImageData?) -> Void)? {
    set {
      mockEventSink.eventSinkSuccessStub = newValue
    }
    get {
      return mockEventSink.eventSinkSuccessStub
    }
  }

  override func onListen(
    withArguments arguments: Any?, sink: PigeonEventSink<PlatformCameraImageData>
  ) {
  }

  override func onCancel(withArguments arguments: Any?) {
  }
}

final class StreamingTests: XCTestCase {
  private func createCamera() -> (
    DefaultCamera,
    AVCaptureOutput,
    CMSampleBuffer,
    CMSampleBuffer,
    AVCaptureConnection
  ) {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue

    let camera = CameraTestUtils.createTestCamera(configuration)
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let sampleBuffer = CameraTestUtils.createTestSampleBuffer()
    let audioSampleBuffer = CameraTestUtils.createTestAudioSampleBuffer()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    return (camera, testAudioOutput, sampleBuffer, audioSampleBuffer, testAudioConnection)
  }

  func testExceedMaxStreamingPendingFramesCount() {
    let (camera, testAudioOutput, sampleBuffer, _, testAudioConnection) = createCamera()
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

    handlerMock.eventSinkSuccessStub = { event in
      streamingExpectation.fulfill()
    }

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(camera.isStreamingImages, true)

    streamingExpectation.expectedFulfillmentCount = 4
    for _ in 0..<10 {
      camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testReceivedImageStreamData() {
    let (camera, testAudioOutput, sampleBuffer, _, testAudioConnection) = createCamera()
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
    handlerMock.eventSinkSuccessStub = { event in
      streamingExpectation.fulfill()
    }

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

  func testIgnoresNonImageBuffers() {
    let (camera, testAudioOutput, _, audioSampleBuffer, testAudioConnection) = createCamera()
    let handlerMock = MockImageStreamHandler()
    handlerMock.eventSinkSuccessStub = { event in
      XCTFail()
    }

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
    XCTAssertEqual(camera.isStreamingImages, true)

    camera.captureOutput(testAudioOutput, didOutput: audioSampleBuffer, from: testAudioConnection)

    waitForQueueRoundTrip(with: DispatchQueue.main)
  }

  func testImageStreamEventFormat() throws {
    let (camera, testAudioOutput, sampleBuffer, _, testAudioConnection) = createCamera()

    let expectation = expectation(description: "Received a valid event")

    let handlerMock = MockImageStreamHandler()
    handlerMock.eventSinkSuccessStub = { event in
      guard let imageBuffer = event else {
        XCTFail()
        return
      }
      XCTAssertGreaterThan(imageBuffer.width, 0)
      XCTAssertGreaterThan(imageBuffer.height, 0)
      XCTAssertGreaterThan(imageBuffer.formatCode, 0)
      XCTAssertGreaterThan(imageBuffer.lensAperture, 0)
      XCTAssertGreaterThan(imageBuffer.sensorExposureTimeNanoseconds, 0)
      XCTAssertGreaterThan(imageBuffer.sensorSensitivity, 0)

      let planes = imageBuffer.planes
      let planeBuffer = planes[0]

      XCTAssertGreaterThan(planeBuffer.bytesPerRow, 0)
      XCTAssertGreaterThan(planeBuffer.width, 0)
      XCTAssertGreaterThan(planeBuffer.height, 0)
      XCTAssertGreaterThan(planeBuffer.bytes.data.count, 0)

      expectation.fulfill()
    }
    let messenger = MockFlutterBinaryMessenger()
    camera.startImageStream(with: messenger, imageStreamHandler: handlerMock) { _ in }

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(camera.isStreamingImages, true)

    camera.captureOutput(testAudioOutput, didOutput: sampleBuffer, from: testAudioConnection)

    waitForExpectations(timeout: 30, handler: nil)
  }
}
