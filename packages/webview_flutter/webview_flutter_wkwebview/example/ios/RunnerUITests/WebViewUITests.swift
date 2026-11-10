// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private func getPixelColorInImage(image: CGImage, x: Int, y: Int) -> UIColor? {
  guard let provider = image.dataProvider,
    let pixelData = provider.data,
    let data = CFDataGetBytePtr(pixelData)
  else {
    return nil
  }

  // `data` is an unsafe pointer, so ensure its target stays valid.
  return withExtendedLifetime(pixelData) {
    let pixelInfo = (image.bytesPerRow * y) + (x * 4)  // 4 bytes per pixel
    guard pixelInfo + 3 < CFDataGetLength(pixelData) else {
      return nil
    }
    let red = data[pixelInfo + 0]
    let green = data[pixelInfo + 1]
    let blue = data[pixelInfo + 2]
    let alpha = data[pixelInfo + 3]

    return UIColor(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: CGFloat(alpha) / 255.0)
  }
}

class WebViewUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUp() {
    self.continueAfterFailure = false

    app = XCUIApplication()
    app.launch()
  }

  func testTransparentBackground() throws {
    try XCTSkipIf(true, "Test is flaky. See https://github.com/flutter/flutter/issues/124156")

    let menu = app.buttons["Show menu"]
    if !menu.waitForExistence(timeout: 30.0) {
      XCTFail("Unable to find menu: \(app.debugDescription)")
    }
    menu.tap()

    let transparentBackground = app.buttons["Transparent background example"]
    if !transparentBackground.waitForExistence(timeout: 30.0) {
      XCTFail("Unable to find Transparent background example: \(app.debugDescription)")
    }
    transparentBackground.tap()

    let transparentBackgroundLoaded = app.webViews.staticTexts["Transparent background test"]
    if !transparentBackgroundLoaded.waitForExistence(timeout: 30.0) {
      XCTFail("Unable to find Transparent background test: \(app.debugDescription)")
    }

    let screenshot = XCUIScreen.main.screenshot()
    let screenshotCGImage = try XCTUnwrap(screenshot.image.cgImage)
    let centerLeftColor = try XCTUnwrap(
      getPixelColorInImage(image: screenshotCGImage, x: 0, y: screenshotCGImage.height / 2))
    let centerColor = try XCTUnwrap(
      getPixelColorInImage(
        image: screenshotCGImage, x: screenshotCGImage.width / 2, y: screenshotCGImage.height / 2))

    let centerLeftColorSpace = try XCTUnwrap(centerLeftColor.cgColor.colorSpace)
    // Flutter Colors.green color : 0xFF4CAF50 -> rgba(76, 175, 80, 1)
    // https://github.com/flutter/flutter/blob/f4abaa0735eba4dfd8f33f73363911d63931fe03/packages/flutter/lib/src/material/colors.dart#L1208
    // The background color of the webview is : rgba(0, 0, 0, 0.5)
    // The expected color is : rgba(38, 87, 40, 1)
    let flutterGreenComponents: [CGFloat] = [38.0 / 255.0, 87.0 / 255.0, 40.0 / 255.0, 1.0]
    let flutterGreenColor = flutterGreenComponents.withUnsafeBufferPointer { buffer in
      CGColor(colorSpace: centerLeftColorSpace, components: buffer.baseAddress!)
    }

    let redColorComponents: [CGFloat] = [1.0, 0.0, 0.0, 1.0]
    let redColor = redColorComponents.withUnsafeBufferPointer { buffer in
      CGColor(colorSpace: centerLeftColorSpace, components: buffer.baseAddress!)
    }

    XCTAssertEqual(flutterGreenColor, centerLeftColor.cgColor)
    XCTAssertEqual(redColor, centerColor.cgColor)
  }
}
