// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import os.log

/// Thread-safe tracker for interception state.
class GalleryInterceptionTracker: @unchecked Sendable {
  static let shared = GalleryInterceptionTracker()
  var intercepted = false
}

@MainActor
class ImagePickerFromGalleryUITests: XCTestCase {

  var app: XCUIApplication!
  let elementWaitingTime: TimeInterval = 60

  override func setUp() async throws {
    try await super.setUp()

    continueAfterFailure = false
    app = XCUIApplication()
    if #available(iOS 13.4, *) {
      app.resetAuthorizationStatus(for: .photos)
    }
    app.launch()
    GalleryInterceptionTracker.shared.intercepted = false

    // Monitor for system alerts and handle them automatically.
    addUIInterruptionMonitor(withDescription: "Permission popups") { interruptingElement in
      let labels = [
        "Allow Full Access", "Allow Access to All Photos", "Allow Access", "OK", "Allow",
        "Select Photos...", "Select More Photos...", "Continue", "Keep Current Selection",
      ]
      for label in labels {
        let button = interruptingElement.buttons.matching(
          NSPredicate(format: "label CONTAINS[c] %@", label)
        ).firstMatch
        if button.exists {
          button.tap()
          GalleryInterceptionTracker.shared.intercepted = true
          return true
        }
      }
      return false
    }
  }

  override func tearDown() async throws {
    app.terminate()
    try await super.tearDown()
  }

  /// Manually triggers the interruption monitor or checks springboard for permission buttons.
  func handlePermissionInterruption() {
    // A small interaction helps trigger the interruption monitor.
    app.swipeUp(velocity: .slow)

    let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let labels = [
      "Allow Full Access", "Allow Access to All Photos", "Allow Access", "OK", "Allow",
      "Select Photos...", "Select More Photos...", "Continue", "Keep Current Selection",
    ]
    for label in labels {
      let button = springboardApp.buttons.matching(
        NSPredicate(format: "label CONTAINS[c] %@", label)
      ).firstMatch
      if button.exists {
        button.tap()
        GalleryInterceptionTracker.shared.intercepted = true
        break
      }
    }
  }

  private func dismissKeyboardIfPresent() {
    if app.keyboards.element(boundBy: 0).exists {
      if UIDevice.current.userInterfaceIdiom == .pad {
        let hideButton = app.keyboards.buttons["Hide keyboard"]
        if hideButton.exists { hideButton.tap() }
      } else {
        let doneButton = app.buttons.matching(NSPredicate(format: "label == 'Done' OR label == 'Hide keyboard'")).firstMatch
        if doneButton.exists {
          doneButton.tap()
        } else {
          // Tap safely above the keyboard.
          let keyboard = app.keyboards.element(boundBy: 0)
          let topPoint = keyboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.05))
          topPoint.tap()
        }
      }
      _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait for keyboard")], timeout: 1.0)
    }
  }

  private func findGalleryButton() -> XCUIElement {
    let identifier = "image_picker_example_from_gallery"
    let discoveryOrder = [
      app.buttons[identifier],
      app.otherElements[identifier],
      app.buttons["Pick image from gallery"],
      app.descendants(matching: .any)[identifier],
    ]

    for element in discoveryOrder {
      if element.exists {
        return element
      }
    }
    return app.buttons[identifier].firstMatch
  }

  private func findPickButton() -> XCUIElement {
    let discoveryOrder = [
      app.buttons["PICK"],
      app.buttons["pick"],
      app.otherElements["PICK"],
      app.descendants(matching: .button)["PICK"],
    ]
    for element in discoveryOrder {
      if element.exists {
        return element
      }
    }
    return app.buttons["PICK"].firstMatch
  }

  /// Taps the "PICK" button and waits for the gallery to appear, retrying if necessary.
  private func tapPickButtonAndVerifyGallery() {
    var pickButton = findPickButton()

    // 1. Ensure the "Add optional parameters" dialog is shown.
    if !pickButton.waitForExistence(timeout: 10) {
        // Retry tapping the home screen gallery button.
        findGalleryButton().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        pickButton = findPickButton()
    }

    XCTAssertTrue(pickButton.waitForExistence(timeout: 20), "PICK button not found")

    // 2. Tap PICK and wait for the gallery (Cancel button).
    // Note: We use a case-sensitive match for "Cancel" to try to distinguish from dialog's "CANCEL".
    let galleryCancel = app.buttons.matching(identifier: "Cancel").firstMatch
    var attempts = 0
    while !galleryCancel.exists && attempts < 3 {
      if pickButton.exists {
        pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
      } else {
        // If PICK is gone, the tap likely worked but gallery is just slow or obscured.
        pickButton = findPickButton()
        if pickButton.exists {
            pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
      }
      handlePermissionInterruption()
      if galleryCancel.waitForExistence(timeout: 15) {
        return
      }
      attempts += 1
    }
    XCTAssertTrue(galleryCancel.exists, "Gallery (Cancel button) did not appear after tapping PICK")
  }

  func testCancel() {
    let galleryButton = findGalleryButton()
    XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime), "Gallery button not found")
    galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

    tapPickButtonAndVerifyGallery()

    let cancelButton = app.buttons["Cancel"].firstMatch
    XCTAssertTrue(cancelButton.waitForExistence(timeout: elementWaitingTime), "Cancel button in gallery not found")
    cancelButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

    let unpickedText = app.staticTexts["You have not yet picked an image."].firstMatch
    XCTAssertTrue(unpickedText.waitForExistence(timeout: elementWaitingTime), "Expected 'not yet picked' text")
  }

  func testPickingFromGallery() {
    launchPickerAndPick(maxWidth: nil, maxHeight: nil, quality: nil)
  }

  func testPickingWithConstraintsFromGallery() {
    launchPickerAndPick(maxWidth: 200, maxHeight: 100, quality: 50)
  }

  func launchPickerAndPick(maxWidth: Int?, maxHeight: Int?, quality: Int?) {
    let galleryButton = findGalleryButton()
    XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime), "Gallery button not found")

    // Retry logic for initial tap to handle slow app startup.
    var attempts = 0
    var pickButton = findPickButton()
    while !pickButton.exists && attempts < 3 {
        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        pickButton = findPickButton()
        if pickButton.waitForExistence(timeout: 5) { break }
        attempts += 1
    }

    if let maxWidth = maxWidth {
      let field = app.textFields["Enter maxWidth if desired"].firstMatch
      XCTAssertTrue(field.waitForExistence(timeout: 10))
      field.tap()
      field.typeText(String(maxWidth))
    }
    if let maxHeight = maxHeight {
      let field = app.textFields["Enter maxHeight if desired"].firstMatch
      XCTAssertTrue(field.waitForExistence(timeout: 10))
      field.tap()
      field.typeText(String(maxHeight))
    }
    if let quality = quality {
      let field = app.textFields["Enter quality if desired"].firstMatch
      XCTAssertTrue(field.waitForExistence(timeout: 10))
      field.tap()
      field.typeText(String(quality))
    }

    if maxWidth != nil || maxHeight != nil || quality != nil {
        dismissKeyboardIfPresent()
    }

    tapPickButtonAndVerifyGallery()

    let unpickedPhoto = app.images.matching(NSPredicate(format: "label CONTAINS 'Photo' AND NOT (label CONTAINS 'picked')")).firstMatch
    if !unpickedPhoto.waitForExistence(timeout: 20) {
      handlePermissionInterruption()
    }
    XCTAssertTrue(unpickedPhoto.waitForExistence(timeout: elementWaitingTime), "No images found in picker")

    let cancelButton = app.buttons["Cancel"].firstMatch
    // Coordinate tap is used to ensure hittability.
    unpickedPhoto.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

    if cancelButton.exists && !cancelButton.waitForNonExistence(timeout: 10) {
      let dismissButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add' OR label CONTAINS 'Done'")).firstMatch
      if dismissButton.exists {
        dismissButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
      }
    }

    XCTAssertTrue(cancelButton.waitForNonExistence(timeout: 30), "Picker did not dismiss after selection")

    let pickedImage = app.images["image_picker_example_picked_image"].firstMatch
    XCTAssertTrue(pickedImage.waitForExistence(timeout: elementWaitingTime), "Picked image not displayed")
  }
}

extension XCUIElement {
  func waitForNonExistence(timeout: TimeInterval) -> Bool {
    let predicate = NSPredicate(format: "exists == false")
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
    let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
    return result == .completed
  }
}
