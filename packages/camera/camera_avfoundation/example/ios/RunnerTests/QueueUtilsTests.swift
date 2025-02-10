// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation
import XCTest

final class QueueUtilsTests: XCTestCase {
  func testShouldStayOnMainQueueIfCalledFromMainQueue() {
    let expectation = expectation(description: "Block must be run on the main queue")

    FLTEnsureToRunOnMainQueue {
      if Thread.isMainThread {
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30)
  }

  func testShouldDispatchToMainQueueIfCalledFromBackgroundQueue() {
    let expectation = expectation(description: "Block must be run on the main queue")

    DispatchQueue.global(qos: .default).async {
      FLTEnsureToRunOnMainQueue {
        if Thread.isMainThread {
          expectation.fulfill()
        }
      }
    }

    waitForExpectations(timeout: 30)
  }
}
