// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import os

class ImagePickerFromLimitedGalleryUITests: XCTestCase {
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
    addUIInterruptionMonitor(withDescription: "Permission popups") {
      [weak self] interruptingElement in
      guard let self else {
        return false
      }
      let limitedPhotoPermission = interruptingElement.buttons.element(boundBy: 0)
      if !limitedPhotoPermission.waitForExistence(timeout: self.elementWaitingTime) {
        os_log(.error, "%{public}@", self.app.debugDescription)
        XCTFail(
          "Failed due to not able to find selectPhotos button with \(self.elementWaitingTime) seconds"
        )
      }
      limitedPhotoPermission.tap()
      self.interceptedPermissionInterruption = true
      return true
    }
  }

  override func tearDown() {
    app.terminate()
    super.tearDown()
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
      let allowButton = springboardApp.buttons["Limit Access…"]
      if !allowButton.waitForExistence(timeout: elementWaitingTime) {
        os_log(.error, "%{public}@", app.debugDescription)
        XCTFail(
          "Failed due to not able to find Limit Access button with \(elementWaitingTime) seconds")
      }
      allowButton.tap()
    }
  }

  func testSelectingFromGallery() throws {
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
      throw XCTSkip("Pick button isn't found so the test is skipped...")
    }
    pickButton.tap()

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
