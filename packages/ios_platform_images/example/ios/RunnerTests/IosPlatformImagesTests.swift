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
    do {
      let url = try plugin.resolveUrl(resourceName: resourceName, extension: nil)
      XCTAssertNotNil(url)
      XCTAssertTrue(url?.contains(resourceName) ?? false)
    } catch {
      XCTFail("Error while resolving URL: \(error)")
    }
  }

  func testResolveURLNotFound() {
    do {
      let url = try plugin.resolveUrl(resourceName: "notFound", extension: nil)
      XCTAssertNil(url)
    } catch {
      XCTFail("Error while resolving URL: \(error)")
    }
  }

}
