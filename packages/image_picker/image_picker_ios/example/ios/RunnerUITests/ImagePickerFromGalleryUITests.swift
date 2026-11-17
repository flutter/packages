// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import os

class ImagePickerFromGalleryUITests: XCTestCase {
  private let elementWaitingTime: TimeInterval = 30

  var app: XCUIApplication!
  var interceptedPermissionInterruption = false

  override func setUp() {
    super.setUp()

    continueAfterFailure = false
    app = XCUIApplication()
    // Reset the authorization status for Photos to test permission popups.
    app.resetAuthorizationStatus(for: .photos)
    app.launch()
    interceptedPermissionInterruption = false
    addUIInterruptionMonitor(withDescription: "Permission popups") {
      [weak self] interruptingElement in
      guard let self else {
        return false
      }
      let allPhotoPermission = interruptingElement.buttons[self.allowAccessPermissionText]
      if !allPhotoPermission.waitForExistence(timeout: self.elementWaitingTime) {
        os_log(.error, "%{public}@", self.app.debugDescription)
        XCTFail(
          "Failed due to not able to find allPhotoPermission button with \(self.elementWaitingTime) seconds"
        )
      }
      allPhotoPermission.tap()
      self.interceptedPermissionInterruption = true
      return true
    }
  }

  override func tearDown() {
    app.terminate()
    super.tearDown()
  }

  var allowAccessPermissionText: String {
    if #available(iOS 17, *) {
      return "Allow Full Access"
    }
    return "Allow Access to All Photos"
  }

  func handlePermissionInterruption() {
    // addUIInterruptionMonitor is only invoked when trying to interact with an element
    // (the app in this case) the alert is blocking. We expect a permission popup here so do a swipe
    // up action (which should be harmless).
    app.swipeUp()

    if #available(iOS 17, *) {
      // addUIInterruptionMonitor does not work consistently on Xcode 15 simulators, so
      // use a backup method of accepting permissions popup.
      if interceptedPermissionInterruption {
        return
      }

      // If cancel button exists, permission has already been given.
      let cancelButton = app.buttons["Cancel"].firstMatch
      if cancelButton.waitForExistence(timeout: elementWaitingTime) {
        return
      }

      let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
      let allowButton = springboardApp.buttons[allowAccessPermissionText]
      if !allowButton.waitForExistence(timeout: elementWaitingTime) {
        os_log(.error, "%{public}@", app.debugDescription)
        XCTFail(
          "Failed due to not able to find Allow Access button with \(elementWaitingTime) seconds")
      }
      allowButton.tap()
    }
  }

  func testCancel() {
    // Find and tap on the pick from gallery button.
    let imageFromGalleryButton = app.otherElements["image_picker_example_from_gallery"].firstMatch
    if !imageFromGalleryButton.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail(
        "Failed due to not able to find image from gallery button with \(elementWaitingTime) seconds"
      )
    }

    imageFromGalleryButton.tap()

    // Find and tap on the `pick` button.
    let pickButton = app.buttons["PICK"].firstMatch
    if !pickButton.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find pick button with \(elementWaitingTime) seconds")
    }

    pickButton.tap()

    handlePermissionInterruption()

    // Find and tap on the `Cancel` button.
    let cancelButton = app.buttons["Cancel"].firstMatch
    if !cancelButton.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find Cancel button with \(elementWaitingTime) seconds")
    }

    cancelButton.tap()

    // Find the "not picked image text".
    let imageNotPickedText = app.staticTexts["You have not yet picked an image."].firstMatch
    if !imageNotPickedText.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail(
        "Failed due to not able to find imageNotPickedText with \(elementWaitingTime) seconds")
    }
  }

  func testPickingFromGallery() {
    launchPickerAndPick(maxWidth: nil, maxHeight: nil, quality: nil)
  }

  func testPickingWithContraintsFromGallery() {
    launchPickerAndPick(maxWidth: 200, maxHeight: 100, quality: 50)
  }

  func launchPickerAndPick(maxWidth: Int?, maxHeight: Int?, quality: Int?) {
    // Find and tap on the pick from gallery button.
    let imageFromGalleryButton = app.otherElements["image_picker_example_from_gallery"].firstMatch
    if !imageFromGalleryButton.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail(
        "Failed due to not able to find image from gallery button with \(elementWaitingTime) seconds"
      )
    }
    imageFromGalleryButton.tap()

    if let maxWidth {
      let field = app.textFields["Enter maxWidth if desired"].firstMatch
      field.tap()
      field.typeText(String(maxWidth))
    }

    if let maxHeight {
      let field = app.textFields["Enter maxHeight if desired"].firstMatch
      field.tap()
      field.typeText(String(maxHeight))
    }

    if let quality {
      let field = app.textFields["Enter quality if desired"].firstMatch
      field.tap()
      field.typeText(String(quality))
    }

    // Find and tap on the `pick` button.
    let pickButton = app.buttons["PICK"].firstMatch
    if !pickButton.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find pick button with \(elementWaitingTime) seconds")
    }
    pickButton.tap()

    handlePermissionInterruption()

    // Find an image and tap on it.
    let imagePredicate = NSPredicate(format: "label BEGINSWITH 'Photo, '")
    let aImage = app.images.matching(imagePredicate).firstMatch
    os_log(.error, "description before picking image %{public}@", app.debugDescription)
    if !aImage.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find an image with \(elementWaitingTime) seconds")
    }
    if aImage.isHittable {
      aImage.tap()
    } else {
      // Known issue where tappable elements are not hittable. Tap it anyway.
      // See https://github.com/flutter/plugins/pull/6783 for a similar case.
      let coordinate = aImage.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
      coordinate.tap()
    }

    // Find the picked image.
    let pickedImage = app.images["image_picker_example_picked_image"].firstMatch
    if !pickedImage.waitForExistence(timeout: elementWaitingTime) {
      os_log(.error, "%{public}@", app.debugDescription)
      XCTFail("Failed due to not able to find pickedImage with \(elementWaitingTime) seconds")
    }
  }
}
