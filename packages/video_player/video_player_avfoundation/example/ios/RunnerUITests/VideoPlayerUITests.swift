// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@MainActor
class VideoPlayerUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() async throws {
    try await super.setUp()
    continueAfterFailure = false

    app = XCUIApplication()
    app.launch()
  }

  func testPlayVideo() {
    let app = self.app!
    let remoteTab = app.otherElements.matching(NSPredicate(format: "selected == YES")).element(
      boundBy: 0)
    XCTAssertTrue(remoteTab.waitForExistence(timeout: 30.0))
    XCTAssertTrue(remoteTab.label.contains("Remote"))

    // Go through both platform view and texture view.
    for tabName in ["Platform view", "Texture view"] {
      let predicate = NSPredicate(format: "label BEGINSWITH %@", tabName)
      let viewTypeTab = app.staticTexts.element(matching: predicate)
      XCTAssertTrue(viewTypeTab.waitForExistence(timeout: 30.0))
      XCTAssertFalse(viewTypeTab.isSelected)
      viewTypeTab.tap()

      let playButton = app.staticTexts["Play"]
      XCTAssertTrue(playButton.waitForExistence(timeout: 30.0))
      playButton.tap()

      let find1xButton = NSPredicate(format: "label CONTAINS '1.0x'")
      let playbackSpeed1x = app.staticTexts.element(matching: find1xButton)
      let foundPlaybackSpeed1x = playbackSpeed1x.waitForExistence(timeout: 30.0)
      XCTAssertTrue(foundPlaybackSpeed1x)
      playbackSpeed1x.tap()

      let playbackSpeed5xButton = app.buttons["5.0x"]
      XCTAssertTrue(playbackSpeed5xButton.waitForExistence(timeout: 30.0))
      playbackSpeed5xButton.tap()

      let find5xButton = NSPredicate(format: "label CONTAINS '5.0x'")
      let playbackSpeed5x = app.staticTexts.element(matching: find5xButton)
      let foundPlaybackSpeed5x = playbackSpeed5x.waitForExistence(timeout: 30.0)
      XCTAssertTrue(foundPlaybackSpeed5x)
    }

    // Cycle through tabs.
    for tabName in ["Asset mp4", "Remote mp4"] {
      let predicate = NSPredicate(format: "label BEGINSWITH %@", tabName)
      let unselectedTab = app.staticTexts.element(matching: predicate)
      XCTAssertTrue(unselectedTab.waitForExistence(timeout: 30.0))
      XCTAssertFalse(unselectedTab.isSelected)
      unselectedTab.tap()

      let selectedTab = app.otherElements.element(
        matching: NSPredicate(format: "label BEGINSWITH %@", tabName))
      XCTAssertTrue(selectedTab.waitForExistence(timeout: 30.0))
      XCTAssertTrue(selectedTab.isSelected)
    }
  }
}
