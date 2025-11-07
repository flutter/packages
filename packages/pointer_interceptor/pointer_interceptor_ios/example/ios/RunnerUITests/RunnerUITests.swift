// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

final class RunnerUITests: XCTestCase {

  override func setUp() {
    continueAfterFailure = false
  }

  func testPointerInterceptorBlocksGesturesFromFlutter() {
    let app = XCUIApplication()
    app.launch()

    let fabInitial = app.buttons["Initial"]
    if !(fabInitial.waitForExistence(timeout: 30)) {
      print(app.debugDescription)
      XCTFail("Could not find Flutter button to click on")
      return
    }

    fabInitial.tap()

    let fabAfter = app.buttons["Tapped"]
    if !(fabAfter.waitForExistence(timeout: 30)) {
      print(app.debugDescription)
      XCTFail("Flutter button did not change on tap")
      return
    }

    let exp = expectation(description: "Check platform view not clicked after 3 seconds")
    let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
    if result == XCTWaiter.Result.timedOut {
      let dummyButton = app.staticTexts["Not Clicked"]
      if !(dummyButton.waitForExistence(timeout: 30)) {
        print(app.debugDescription)
        XCTFail("Pointer interceptor did not block gesture from hitting platform view")
        return
      }
    }
  }
}
