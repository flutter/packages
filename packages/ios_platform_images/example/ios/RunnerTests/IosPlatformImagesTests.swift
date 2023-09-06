// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import ios_platform_images

class IosPlatformImagesTests: XCTestCase {

  var mockChannel: MockMethodChannel!

  override func setUp() {
    super.setUp()
    mockChannel = MockMethodChannel()
  }

  func testHandleMethodCall_loadImage() {

    let name = "flutter"

    let call = FlutterMethodCall(methodName: "loadImage", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      plugin.handle(call) { result in
        let result = result as? [String: Any]
        XCTAssertNotNil(result)

      }
      resultExpectation.fulfill()
    }

    XCTWaiter().wait(for: [resultExpectation], timeout: 2)

  }

  func testHandleMethodCall_loadImage_notFound() {
    let name = "testImage"

    let call = FlutterMethodCall(methodName: "loadImage", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    DispatchQueue.main.asyncAfter(deadline: .now()) {
      plugin.handle(call) { result in
        XCTAssertNil(result)
        resultExpectation.fulfill()
      }
    }

    XCTWaiter().wait(for: [resultExpectation], timeout: 1)
  }

  func testHandleMethodCall_resolveURL_notFound() {
    let name = "testFile"

    let call = FlutterMethodCall(methodName: "resolveURL", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    DispatchQueue.main.asyncAfter(deadline: .now()) {
      plugin.handle(call) { result in
        XCTAssertNil(result)
        resultExpectation.fulfill()
      }
    }

    XCTWaiter().wait(for: [resultExpectation], timeout: 1)
  }
}
