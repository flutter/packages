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

/// Helper function to create a sample buffer without an image buffer (nil)
/// This simulates the condition that occurs right after recording stops
private func createNilImageBufferSampleBuffer() -> CMSampleBuffer {
  var blockBuffer: CMBlockBuffer?
  CMBlockBufferCreateWithMemoryBlock(
    allocator: kCFAllocatorDefault,
    memoryBlock: nil,
    blockLength: 100,
    blockAllocator: kCFAllocatorDefault,
    customBlockSource: nil,
    offsetToData: 0,
    dataLength: 100,
    flags: kCMBlockBufferAssureMemoryNowFlag,
    blockBufferOut: &blockBuffer)

  var formatDescription: CMFormatDescription?
  var basicDescription = AudioStreamBasicDescription(
    mSampleRate: 44100,
    mFormatID: kAudioFormatLinearPCM,
    mFormatFlags: 0,
    mBytesPerPacket: 1,
    mFramesPerPacket: 1,
    mBitsPerChannel: 16,
    mChannelsPerFrame: 1,
    mReserved: 0)

  CMAudioFormatDescriptionCreate(
    allocator: kCFAllocatorDefault,
    asbd: &basicDescription,
    layoutSize: 0,
    layout: nil,
    magicCookieSize: 0,
    magicCookie: nil,
    extensions: nil,
    formatDescriptionOut: &formatDescription)

  var timingInfo = CMSampleTimingInfo(
    duration: CMTimeMake(value: 1, timescale: 44100),
    presentationTimeStamp: CMTime.zero,
    decodeTimeStamp: CMTime.invalid)

  var sampleBuffer: CMSampleBuffer?
  CMSampleBufferCreate(
    allocator: kCFAllocatorDefault,
    dataBuffer: blockBuffer,
    dataReady: true,
    makeDataReadyCallback: nil,
    refcon: nil,
    formatDescription: formatDescription,
    sampleCount: 1,
    sampleTimingEntryCount: 1,
    sampleTimingArray: &timingInfo,
    sampleSizeEntryCount: 0,
    sampleSizeArray: nil,
    sampleBufferOut: &sampleBuffer)

  return sampleBuffer!
}

final class StreamingNilBufferTests: XCTestCase {
  func testStreamingWithNilImageBuffer() {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue

    let camera = CameraTestUtils.createTestCamera(configuration)
    let testVideoOutput = camera.captureVideoOutput.avOutput
    let testVideoConnection = CameraTestUtils.createTestConnection(testVideoOutput)

    let handlerMock = MockImageStreamHandler()
    var eventCallCount = 0

    handlerMock.eventSinkStub = { event in
      eventCallCount += 1
    }

    let finishStartStreamExpectation = expectation(description: "Finish startStream")
    let messenger = MockFlutterBinaryMessenger()

    camera.startImageStream(
      with: messenger, imageStreamHandler: handlerMock,
      completion: { _ in
        finishStartStreamExpectation.fulfill()
      })

    waitForExpectations(timeout: 30, handler: nil)
    waitForQueueRoundTrip(with: DispatchQueue.main)

    XCTAssertEqual(camera.isStreamingImages, true)
    XCTAssertEqual(camera.streamingPendingFramesCount, 0)

    // Send a nil image buffer sample (simulating post-recording condition)
    let nilBufferSample = createNilImageBufferSampleBuffer()
    camera.captureOutput(testVideoOutput, didOutput: nilBufferSample, from: testVideoConnection)

    // Verify that the frame count is still 0 (frame was skipped)
    XCTAssertEqual(camera.streamingPendingFramesCount, 0)
    XCTAssertEqual(eventCallCount, 0, "No events should be sent for nil image buffers")

    // Send a valid sample buffer to ensure streaming still works
    let validSample = CameraTestUtils.createTestSampleBuffer()
    camera.captureOutput(testVideoOutput, didOutput: validSample, from: testVideoConnection)

    // Wait a bit for async processing
    waitForQueueRoundTrip(with: captureSessionQueue)
    waitForQueueRoundTrip(with: DispatchQueue.main)

    // Verify that the valid frame was processed
    XCTAssertEqual(camera.streamingPendingFramesCount, 1)
    XCTAssertEqual(eventCallCount, 1, "Valid frame should trigger an event")
  }

  func testStreamingWithMixedNilAndValidBuffers() {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue

    let camera = CameraTestUtils.createTestCamera(configuration)
    let testVideoOutput = camera.captureVideoOutput.avOutput
    let testVideoConnection = CameraTestUtils.createTestConnection(testVideoOutput)

    let handlerMock = MockImageStreamHandler()
    var eventCallCount = 0

    handlerMock.eventSinkStub = { event in
      eventCallCount += 1
    }

    let finishStartStreamExpectation = expectation(description: "Finish startStream")
    let messenger = MockFlutterBinaryMessenger()

    camera.startImageStream(
      with: messenger, imageStreamHandler: handlerMock,
      completion: { _ in
        finishStartStreamExpectation.fulfill()
      })

    waitForExpectations(timeout: 30, handler: nil)
    waitForQueueRoundTrip(with: DispatchQueue.main)

    // Send alternating nil and valid buffers
    let nilBufferSample = createNilImageBufferSampleBuffer()
    let validSample = CameraTestUtils.createTestSampleBuffer()

    camera.captureOutput(testVideoOutput, didOutput: validSample, from: testVideoConnection)
    camera.captureOutput(testVideoOutput, didOutput: nilBufferSample, from: testVideoConnection)
    camera.captureOutput(testVideoOutput, didOutput: validSample, from: testVideoConnection)
    camera.captureOutput(testVideoOutput, didOutput: nilBufferSample, from: testVideoConnection)
    camera.captureOutput(testVideoOutput, didOutput: validSample, from: testVideoConnection)

    // Wait for async processing
    waitForQueueRoundTrip(with: captureSessionQueue)
    waitForQueueRoundTrip(with: DispatchQueue.main)

    // Only valid buffers should be processed
    XCTAssertEqual(eventCallCount, 3, "Only valid frames should trigger events")
  }
}

// Helper to wait for a dispatch queue to process pending operations
private func waitForQueueRoundTrip(with queue: DispatchQueue) {
  let expectation = XCTestExpectation(description: "Queue round trip")
  queue.async {
    expectation.fulfill()
  }
  wait(for: [expectation], timeout: 5.0)
}

// Mock class from StreamingTests.swift
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
