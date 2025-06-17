// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let elementWaitingTime: TimeInterval = 30
// The duration in when pressing the app icon to open the
// quick action menu. This duration is undocumented by Apple.
// The duration will be adjusted with `pressDurationRetryAdjustment` if
// this duration does not result in the quick action menu opened.
private let quickActionPressDuration: TimeInterval = 1.5
// If the previous try to open quick action menu did not work,
// a new try with adjust the press time by this value.
// The adjusment could be + or - depends on the result of the previous try.
private let pressDurationRetryAdjustment: TimeInterval = 0.2
// Max number of tries to open the quick action menu if failed.
// This is to deflake a situation where the quick action menu is not present after
// the long press.
// See: https://github.com/flutter/flutter/issues/125509
private let quickActionMaxRetries: Int = 4

class RunnerUITests: XCTestCase {

  private var exampleApp: XCUIApplication!

  override func setUp() {
    super.setUp()
    self.continueAfterFailure = false
    exampleApp = XCUIApplication()
  }

  override func tearDown() {
    super.tearDown()
    exampleApp.terminate()
    exampleApp = nil
  }

  func testQuickActionWithFreshStart() throws {
    // See https://github.com/flutter/flutter/issues/169928
    throw XCTSkip("Temporarily disabled")

    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let quickActionsAppIcon = springboard.icons["quick_actions_example"]

    findAndTapQuickActionButton(
      buttonName: "Action two", quickActionsAppIcon: quickActionsAppIcon, springboard: springboard)

    let actionTwoConfirmation = exampleApp.otherElements["action_two"]
    if !actionTwoConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionTwoConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionTwoConfirmation.exists)
  }

  func testQuickActionWhenAppIsInBackground() throws {
    // See https://github.com/flutter/flutter/issues/169928
    throw XCTSkip("Temporarily disabled")

    exampleApp.launch()

    let actionsReady = exampleApp.otherElements["actions ready"]

    if !actionsReady.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionsReady in the app with \(elementWaitingTime) seconds. App debug description: \(exampleApp.debugDescription)"
      )
    }

    XCUIDevice.shared.press(.home)

    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let quickActionsAppIcon = springboard.icons["quick_actions_example"]
    if !quickActionsAppIcon.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the example app from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    findAndTapQuickActionButton(
      buttonName: "Action one, Action one subtitle", quickActionsAppIcon: quickActionsAppIcon,
      springboard: springboard)

    let actionOneConfirmation = exampleApp.otherElements["action_one"]
    if !actionOneConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionOneConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionOneConfirmation.exists)
  }

  private func findAndTapQuickActionButton(
    buttonName: String, quickActionsAppIcon: XCUIElement, springboard: XCUIElement
  ) {
    var actionButton: XCUIElement?
    var pressDuration = quickActionPressDuration
    for _ in 1...quickActionMaxRetries {
      if !quickActionsAppIcon.waitForExistence(timeout: elementWaitingTime) {
        XCTFail(
          "Failed due to not able to find the example app from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
        )
      }
      quickActionsAppIcon.press(forDuration: pressDuration)
      actionButton = springboard.buttons[buttonName]
      if actionButton!.waitForExistence(timeout: elementWaitingTime) {
        // find the button, exit the retry loop.
        break
      }
      let deleteButton = springboard.buttons["DeleteButton"]
      if deleteButton.waitForExistence(timeout: elementWaitingTime) {
        // Found delete button instead, we pressed too long, reduce the press time.
        pressDuration -= pressDurationRetryAdjustment
      } else {
        // Neither action button nor delete button was found, we need a longer press.
        pressDuration += pressDurationRetryAdjustment
      }
      // Reset to previous state.
      XCUIDevice.shared.press(XCUIDevice.Button.home)
    }
    if !actionButton!.exists {
      XCTFail(
        "Failed due to not able to find the \(buttonName) button from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    actionButton!.tap()
  }
}
