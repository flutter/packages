// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let elementWaitingTime: TimeInterval = 30
private let quickActionPressDuration: TimeInterval = 1.5
// Max number of tries to open the quick action menu if failed.
private let quickActionMaxRetries: Int = 3;

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
    if !quickActionsAppIcon.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the example app from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    quickActionsAppIcon.press(forDuration: quickActionPressDuration)

    let actionTwo = springboard.buttons["Action two"]
    if !actionTwo.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionTwo button from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    actionTwo.tap()

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

    quickActionsAppIcon.press(forDuration: quickActionPressDuration)

    let actionOne = springboard.buttons["Action one"]
    if !actionOne.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionOne button from springboard with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    actionOne.tap()

    let actionOneConfirmation = exampleApp.otherElements["action_one"]
    if !actionOneConfirmation.waitForExistence(timeout: elementWaitingTime) {
      XCTFail(
        "Failed due to not able to find the actionOneConfirmation in the app with \(elementWaitingTime) seconds. Springboard debug description: \(springboard.debugDescription)"
      )
    }

    XCTAssert(actionOneConfirmation.exists)
  }
}
