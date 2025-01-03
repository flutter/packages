// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import image_picker_macos

final class ImageResizeTests: XCTestCase {

  func testNilMaxSize() {
    let originalImage = createTestImage(size: NSSize(width: 1200, height: 800))

    let resizedImage = originalImage.resizedOrOriginal(maxSize: nil)

    XCTAssertEqual(
      resizedImage, originalImage, "Should return the original image when \(MaxSize.self) is nil.")
  }

  func testResizeExceedingMaxSize() {
    let originalImage = createTestImage(size: NSSize(width: 1200, height: 800))

    let maxSize = MaxSize(width: 600, height: 400)
    let resizedImage = originalImage.resizedOrOriginal(maxSize: maxSize)

    // The resized image should be scaled down to fit within the max size while maintaining the aspect ratio.
    XCTAssertEqual(
      resizedImage.size.width, maxSize.width,
      "Resized image width should not exceed the maximum allowed width.")
    XCTAssertEqual(
      resizedImage.size.height, maxSize.height,
      "Resized image height should not exceed the maximum allowed height.")
  }

  func testResizeBelowMaxSize() {
    let originalImage = createTestImage(size: NSSize(width: 600, height: 400))

    let resizedImage = originalImage.resizedOrOriginal(maxSize: MaxSize(width: 1200, height: 800))

    // The resized image should remain the same size, as it's already smaller than the max size.
    XCTAssertEqual(
      resizedImage.size.width, originalImage.size.width,
      "Resized image width should remain unchanged when smaller than the maximum allowed width.")
    XCTAssertEqual(
      resizedImage.size.height, originalImage.size.height,
      "Resized image height should remain unchanged when smaller than the maximum allowed height.")
  }

  func testResizeWidthOnly() {
    // An image where only the width exceeds the max size
    let originalImage = createTestImage(size: NSSize(width: 600, height: 200))

    let maxSize = MaxSize(width: 300, height: 400)
    let resizedImage = originalImage.resizedOrOriginal(maxSize: maxSize)

    // The image should be resized proportionally based on width
    XCTAssertEqual(
      resizedImage.size.width, maxSize.width, "The width should be equal to max width.")
    XCTAssertEqual(resizedImage.size.height, 100, "The height should be resized proportionally.")
  }

  func testResizeHeightOnly() {
    // An image where only the height exceeds the max size
    let originalImage = createTestImage(size: NSSize(width: 400, height: 600))

    let maxSize = MaxSize(width: 500, height: 300)
    let resizedImage = originalImage.resizedOrOriginal(maxSize: maxSize)

    // The image should be resized proportionally based on height
    XCTAssertEqual(resizedImage.size.width, 200, "The width should be resized proportionally.")
    XCTAssertEqual(
      resizedImage.size.height, maxSize.height, "The height should be equal to max height.")
  }

  func testResizeExtremeAspectRatio() {
    // An image (20:1) with an extreme aspect ratio (very wide)
    let originalImage = createTestImage(size: NSSize(width: 2000, height: 100))

    let maxSize = MaxSize(width: 600, height: 400)
    let resizedImage = originalImage.resizedOrOriginal(maxSize: maxSize)

    // The resized image should be within the max size while maintaining aspect ratio
    XCTAssertEqual(resizedImage.size.width, 600, "The width should be resized to max width")
    XCTAssertEqual(resizedImage.size.height, 30, "The height should be resized proportionally.")
  }

  func testResizeImageWithSameAspectRatio() {
    let originalImage = createTestImage(size: NSSize(width: 800, height: 400))

    let maxSize = MaxSize(width: 600, height: 300)
    let resizedImage = originalImage.resizedOrOriginal(maxSize: maxSize)

    XCTAssertEqual(
      resizedImage.size.width, maxSize.width,
      "Width should be equal to max width when the aspect ratio is the same")
    XCTAssertEqual(
      resizedImage.size.height, maxSize.height,
      "Height should be equal to height width when the aspect ratio is the same")
  }

  func testResizedOrOriginalWithUndefinedSize() {
    let image = createTestImage(size: NSSize(width: 300, height: 200))
    let resizedImage = image.resizedOrOriginal(maxSize: MaxSize())

    XCTAssertEqual(
      image.size.width, resizedImage.size.width,
      "Should return the original image without resizing.")
    XCTAssertEqual(
      image.size.height, resizedImage.size.height,
      "Should return the original image without resizing.")
  }

  func testShouldResize() {
    let imageSize = NSSize(width: 400, height: 600)
    let image = NSImage(size: imageSize)

    XCTAssertFalse(
      image.shouldResize(maxSize: MaxSize()),
      "Should not resize when both the width and height are nil."
    )

    XCTAssertTrue(
      image.shouldResize(maxSize: MaxSize(width: 300, height: 500)),
      "Should resize when image size larger than max size."
    )
    XCTAssertTrue(
      image.shouldResize(maxSize: MaxSize(width: 300)),
      "Should resize when image width larger than max width."
    )
    XCTAssertTrue(
      image.shouldResize(maxSize: MaxSize(height: 500)),
      "Should resize when image height larger than max height."
    )

    XCTAssertFalse(
      image.shouldResize(maxSize: MaxSize(width: 500, height: 700)),
      "Should not resize when image size smaller than max size."
    )
    XCTAssertFalse(
      image.shouldResize(maxSize: MaxSize(width: 500)),
      "Should not resize when image width smaller than max width."
    )
    XCTAssertFalse(
      image.shouldResize(maxSize: MaxSize(height: 700)),
      "Should not resize when image height smaller than max height."
    )

    XCTAssertFalse(
      image.shouldResize(maxSize: MaxSize(width: imageSize.width, height: imageSize.height)),
      "Should not resize when image size equal max size."
    )

    XCTAssertTrue(
      image.shouldResize(maxSize: MaxSize(width: 350, height: 700)),
      "Should resize when image width larger than max width and image height less than max height."
    )
    XCTAssertTrue(
      image.shouldResize(maxSize: MaxSize(width: 450, height: 500)),
      "Should resize when image height is larger than max height and image width less than max width"
    )

  }

  func testHasAnyDimension() {
    XCTAssertFalse(
      MaxSize(width: nil, height: nil).hasAnyDimension(),
      "Should not resize when both width and height are nil.")
    XCTAssertTrue(
      MaxSize(width: 20, height: nil).hasAnyDimension(),
      "Should resize when width is specified and height is nil.")
    XCTAssertTrue(
      MaxSize(width: nil, height: 20).hasAnyDimension(),
      "Should resize when height is specified and width is nil.")
    XCTAssertTrue(
      MaxSize(width: 20, height: 20).hasAnyDimension(),
      "Should resize when both width and height are specified.")
  }

  func testMaxSizeToNSSize_withDefinedWidthAndHeight() {
    let image = createTestImage(size: NSSize(width: 50, height: 50))
    let maxSize = MaxSize(width: 32, height: 96)

    XCTAssertEqual(
      maxSize.toNSSize(image: image).width, maxSize.width,
      "Expected width to match MaxSize width.")
    XCTAssertEqual(
      maxSize.toNSSize(image: image).height, maxSize.height,
      "Expected height to match MaxSize height.")
  }

  func testMaxSizeToNSSize_withDefinedWidthOnly() {
    let image = createTestImage(size: NSSize(width: 50, height: 50))
    let maxSize = MaxSize(width: 128)

    XCTAssertEqual(
      maxSize.toNSSize(image: image).width, maxSize.width,
      "Expected width to match MaxSize width.")
    XCTAssertEqual(
      maxSize.toNSSize(image: image).height, image.size.height,
      "Expected height to default to image height when MaxSize height is nil.")
  }

  func testMaxSizeToNSSize_withDefinedHeightOnly() {
    let image = createTestImage(size: NSSize(width: 50, height: 50))
    let maxSize = MaxSize(height: 64)

    XCTAssertEqual(
      maxSize.toNSSize(image: image).width, image.size.width,
      "Expected width to default to image width when MaxSize width is nil.")
    XCTAssertEqual(
      maxSize.toNSSize(image: image).height, maxSize.height,
      "Expected height to match MaxSize height.")
  }

  func testMaxSizeToNSSize_withUndefinedWidthAndHeight() {
    let image = createTestImage(size: NSSize(width: 50, height: 50))
    let maxSize = MaxSize()

    XCTAssertEqual(
      maxSize.toNSSize(image: image).width, image.size.width,
      "Expected width to default to image width when MaxSize width is nil.")
    XCTAssertEqual(
      maxSize.toNSSize(image: image).height, image.size.height,
      "Expected height to default to image height when MaxSize height is nil.")
  }

}
