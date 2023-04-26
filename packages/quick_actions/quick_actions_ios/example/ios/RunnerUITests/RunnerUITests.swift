// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let elementWaitingTime: TimeInterval = 5
private let quickActionPressDuration: TimeInterval = 1.5
private let pressDurationRetryAdjustment: TimeInterval = 0.2
// Max number of tries to open the quick action menu if failed.
private let quickActionMaxRetries: Int = 4;

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

  func testQuickActionWithFreshStart() {
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let quickActionsAppIcon = springboard.icons["quick_actions_example"]

    findAndTapQuickActionButton(buttonName: "Action two", quickActionsAppIcon: quickActionsAppIcon, springboard: springboard);

    let actionTwoConfirmation = exampleApp.otherElements["action_two"]
    if !actionTwoConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionTwoConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionTwoConfirmation.exists)
  }

  func testQuickActionWhenAppIsInBackground() {
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

    findAndTapQuickActionButton(buttonName: "Action one", quickActionsAppIcon: quickActionsAppIcon, springboard: springboard);

    let actionOneConfirmation = exampleApp.otherElements["action_one"]
    if !actionOneConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionOneConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionOneConfirmation.exists)
  }

  private func findAndTapQuickActionButton(buttonName: String, quickActionsAppIcon: XCUIElement, springboard: XCUIElement) {
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
    if (!actionButton!.exists) {
      XCTFail(
        "Failed due to not able to find the \(buttonName) button from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    actionButton!.tap();
  }
}
