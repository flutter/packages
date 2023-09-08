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

    plugin.handle(call) { result in
      let result = result as? [String: Any]
      XCTAssertNotNil(result)
      
      let scale = result?["scale"] as? CGFloat
      let data = result?["data"] as? FlutterStandardTypedData

      XCTAssertNotNil(scale)
      XCTAssertNotNil(data)

      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 2, handler: nil)
  }

  func testHandleMethodCall_loadImage_notFound() {
    let name = "flutterNotFound"

    let call = FlutterMethodCall(methodName: "loadImage", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      let result = result as? [String: Any]

      XCTAssertNil(result)
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 2, handler: nil)
  }

  func testHandleMethodCall_resolveURL() {
    let name = "textfile"

    let call = FlutterMethodCall(methodName: "resolveURL", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      let result = result as? String
      XCTAssertNotNil(result)
      XCTAssertEqual(result?.components(separatedBy: "/").last, name)
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testHandleMethodCall_resolveURL_notFound() {
    let name = "notFound"

    let call = FlutterMethodCall(methodName: "resolveURL", arguments: [name])

    let mockChannel = MockMethodChannel()

    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertNil(result)
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

}
