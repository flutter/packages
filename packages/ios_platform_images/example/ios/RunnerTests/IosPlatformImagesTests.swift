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

  func testImageLoading() {
    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    mockChannel.invokeMethodStub = { method, arguments in

      if method == "loadImage" {
        let imageData: [String: Any] = [
          "scale": 2.0,
          "data": FlutterStandardTypedData(bytes: [UInt8(0), UInt8(1), UInt8(2)]),
        ]
        plugin.handleLoadImage(
          arguments as! FlutterMethodCall,
          { result in
            result(imageData)
          })
      }
    }

    let image = UIImage.flutterImage(withName: "testImage.png")

    XCTAssertNotNil(image)
  }

  func testResolveURL() {
    let plugin = IosPlatformImagesPlugin(channel: mockChannel)

    mockChannel.invokeMethodStub = { method, arguments in

      if method == "resolveURL" {
        let url = "https://example.com/testImage.png"
        plugin.handleResolveURL(
          arguments as! FlutterMethodCall,
          { result in
            result(url)
          })
      }
    }

    let resolvedURL = IosPlatformImages.resolveURL("testImage.png")

    XCTAssertEqual(resolvedURL, "https://example.com/testImage.png")
  }
}
