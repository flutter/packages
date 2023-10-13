// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import ios_platform_images

final class UIImageIosPlatformImagesTests: XCTestCase {

  func testMultiResolutionImageUsesBest() {
    if let image = flutterImageWithName(withName: "assets/multisize.png") {
      XCTAssertNotNil(image)
      let height1x: Double = 125  // The height of assets/multisize.png.
      let height2x: Double = 250  // The height of assets/2.0x/multisize.png.

      // Loading assets should get the best available asset for the screen scale when resolution-aware
      // assets are available (and the example app has 1x and 2x for this asset).
      if UIScreen.main.scale > 1.0 {
        XCTAssertEqual(image.size.height, height2x, accuracy: 0.00001)
      } else {
        XCTAssertEqual(image.size.height, height1x, accuracy: 0.00001)
      }
    }
  }

  func testSingleResolutionFindsImage() {
    // When there is no resolution-aware asset, the main asset should be used.
    if let image = flutterImageWithName(withName: "assets/monosize.png") {
      XCTAssertNotNil(image)
    }
  }

  func testMissingImageReturnsNil() {
    let image = flutterImageWithName(withName: "assets/no_such_image.png")
    XCTAssertNil(image)
  }
}
