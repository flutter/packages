// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import ios_platform_images

class IosPlatformImagesTests: XCTestCase {
  let plugin = IosPlatformImagesPlugin()

  func testLoadImage() {
    let assetName = "flutter"
    let imageData = plugin.loadImage(name: assetName)

    XCTAssertNotNil(imageData)
    XCTAssertNotNil(imageData?.data)
  }

  func testLoadImageNotFound() {
    let assetName = "notFound"
    let imageData = plugin.loadImage(name: assetName)

    XCTAssertNil(imageData)
  }

  func testResolveURL() {
    let resourceName = "textfile"
    let extensionName: String? = nil
    do {
      let url = try plugin.resolveUrl(resourceName: resourceName, extension: extensionName)
      XCTAssertNotNil(url)
      XCTAssertTrue(url!.contains(resourceName))
    } catch {
      XCTFail("Error while resolving URL: \(error)")
    }
  }

  func testResolveURLNotFound() {
    let resourceName = "notFound"
    let extensionName: String? = nil
    do {
      let url = try plugin.resolveUrl(resourceName: resourceName, extension: extensionName)
      XCTAssertNil(url)
    } catch {
      XCTFail("Error while resolving URL: \(error)")
    }
  }
}
