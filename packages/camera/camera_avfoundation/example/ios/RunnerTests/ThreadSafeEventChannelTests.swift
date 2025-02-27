// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

final class ThreadSafeEventChannelTests: XCTestCase {
  func testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread() {
    let mockEventChannel = MockEventChannel()
    let threadSafeEventChannel = FLTThreadSafeEventChannel(eventChannel: mockEventChannel)

    let mainThreadExpectation = expectation(
      description: "setStreamHandler must be called on the main thread")
    let mainThreadCompletionExpectation = expectation(
      description: "setStreamHandler's completion block must be called on the main thread")

    mockEventChannel.setStreamHandlerStub = { handler in
      if Thread.isMainThread {
        mainThreadExpectation.fulfill()
      }
    }
    threadSafeEventChannel.setStreamHandler(nil) {
      if Thread.isMainThread {
        mainThreadCompletionExpectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread() {
    let mockEventChannel = MockEventChannel()
    let threadSafeEventChannel = FLTThreadSafeEventChannel(eventChannel: mockEventChannel)

    let mainThreadExpectation = expectation(
      description: "setStreamHandler must be called on the main thread")
    let mainThreadCompletionExpectation = expectation(
      description: "setStreamHandler's completion block must be called on the main thread")

    mockEventChannel.setStreamHandlerStub = { handler in
      if Thread.isMainThread {
        mainThreadExpectation.fulfill()
      }
    }
    DispatchQueue.global(qos: .default).async {
      threadSafeEventChannel.setStreamHandler(nil) {
        if Thread.isMainThread {
          mainThreadCompletionExpectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testEventChannel_shouldBeKeptAliveWhenDispatchingBackToMainThread() {
    let mockEventChannel = MockEventChannel()

    let expectation = self.expectation(description: "Completion should be called.")

    DispatchQueue(label: "test").async {
      let channel = FLTThreadSafeEventChannel(eventChannel: mockEventChannel)

      channel.setStreamHandler(nil) {
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
