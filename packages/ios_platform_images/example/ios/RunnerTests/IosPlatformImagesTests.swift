// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import ios_platform_images

class IosPlatformImagesTests: XCTestCase {

  func testHandleMethodCall_loadImage() {
    let assetName = "flutter"

    let call = FlutterMethodCall(methodName: "loadImage", arguments: assetName)
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
    let assetName = "flutterNotFound"

    let call = FlutterMethodCall(methodName: "loadImage", arguments: [assetName])
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
    let assetName = "textfile"

    let call = FlutterMethodCall(methodName: "resolveURL", arguments: [assetName])
    let mockChannel = MockMethodChannel()
    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      let result = result as? String
      XCTAssertNotNil(result)
      XCTAssertEqual(result?.components(separatedBy: "/").last, assetName)
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testHandleMethodCall_resolveURL_notFound() {
    let assetName = "notFound"

    let call = FlutterMethodCall(methodName: "resolveURL", arguments: [assetName])
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
