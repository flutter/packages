// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import image_picker_macos

final class ImageCompressTests: XCTestCase {

  private func createTestImage(size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    NSColor.white.set()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
    image.unlockFocus()
    return image
  }

  func testShouldCompressImage() {
    XCTAssertFalse(shouldCompressImage(quality: 100), "Quality 100 should not compress the image.")
    XCTAssertTrue(shouldCompressImage(quality: 80), "Quality bellow 100 should compress the image.")
  }

  func testImageCompression() throws {
    let testImage = createTestImage(size: NSSize(width: 100, height: 100))

    let compressedImage = try testImage.compressed(quality: 80)

    XCTAssertLessThan(
      compressedImage.tiffRepresentation!.count, testImage.tiffRepresentation!.count,
      "Compressed image data should be smaller than the original image data.")
  }

}
