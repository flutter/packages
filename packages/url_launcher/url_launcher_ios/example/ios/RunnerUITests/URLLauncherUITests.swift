// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class URLLauncherUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() {
    continueAfterFailure = false

    app = XCUIApplication()
    app.launch()
  }

  func testLaunch() {
    let app = self.app!

    let buttonNames: [String] = [
      "Launch in app", "Launch in app(JavaScript ON)", "Launch in app(DOM storage ON)",
      "Launch a universal link in a native app, fallback to Safari.(Youtube)",
    ]
    for buttonName in buttonNames {
      let button = app.buttons[buttonName]
      XCTAssertTrue(button.waitForExistence(timeout: 30.0))
      XCTAssertEqual(app.webViews.count, 0)
      button.tap()
      let webView = app.webViews.firstMatch
      XCTAssertTrue(webView.waitForExistence(timeout: 30.0))
      XCTAssertTrue(app.buttons["ForwardButton"].waitForExistence(timeout: 30.0))
      XCTAssertTrue(app.buttons["Share"].exists)
      XCTAssertTrue(app.buttons["OpenInSafariButton"].exists)
      let doneButton = app.buttons["Done"]
      XCTAssertTrue(doneButton.waitForExistence(timeout: 30.0))
      // This should just be doneButton.tap, but for some reason that stopped working in Xcode 15;
      // tapping via coordinate works, however.
      doneButton.coordinate(withNormalizedOffset: CGVector()).withOffset(CGVector(dx: 10, dy: 10))
        .tap()
    }
  }
}
