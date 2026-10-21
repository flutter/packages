// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import os

class GoogleSignInUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() {
    continueAfterFailure = false

    app = XCUIApplication()
    app.launch()
  }

  func testSignInPopUp() throws {
    let app = try XCTUnwrap(self.app)

    let signInButton = app.buttons["SIGN IN"]
    if !signInButton.waitForExistence(timeout: 30.0) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find Sign In button")
    }
    signInButton.tap()

    allowSignInPermissions()
  }

  func allowSignInPermissions() {
    // The "Sign In" system permissions pop up isn't caught by
    // addUIInterruptionMonitorWithDescription.
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let permissionAlert = springboard.alerts.firstMatch
    if permissionAlert.waitForExistence(timeout: 5.0) {
      // The alert is titled in the simulator's language, so the confirmation
      // button can't be looked up by name. It is the last of the alert's two
      // buttons ("Cancel" and "Continue") in every localization.
      let alertButtons = permissionAlert.buttons
      let buttonCount = alertButtons.count
      guard buttonCount > 0 else {
        XCTFail("Sign In permission alert has no buttons")
        return
      }
      alertButtons.element(boundBy: buttonCount - 1).tap()
    } else {
      os_log("Permission alert not detected, continuing.")
    }
  }
}
