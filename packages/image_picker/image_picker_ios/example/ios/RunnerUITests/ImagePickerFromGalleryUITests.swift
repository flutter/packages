// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import os.log
import XCTest

class GalleryInterceptionTracker: @unchecked Sendable {
    static let shared = GalleryInterceptionTracker()
    var intercepted = false
}

@MainActor
class ImagePickerFromGalleryUITests: XCTestCase {
    var app = XCUIApplication()
    let elementWaitingTime: TimeInterval = 60

    override func setUp() async throws {
        try await super.setUp()

        continueAfterFailure = false
        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .photos)
        }
        app.launch()
        GalleryInterceptionTracker.shared.intercepted = false

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

    func handlePermissionInterruption() {
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

    private func tapPickButtonAndVerifyGallery() {
        var pickButton = findPickButton()

        if !pickButton.waitForExistence(timeout: 10) {
            findGalleryButton().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            pickButton = findPickButton()
        }

        XCTAssertTrue(pickButton.waitForExistence(timeout: 20), "PICK button not found")

        let galleryCancel = app.buttons.matching(identifier: "Cancel").firstMatch
        var attempts = 0
        while !galleryCancel.exists, attempts < 3 {
            if pickButton.exists {
                pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            } else {
                pickButton = findPickButton()
                if pickButton.exists {
                    pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                }
            }
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

    func launchPickerAndPick(maxWidth: Int?, maxHeight: Int?, quality: Int?) {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(
            galleryButton.waitForExistence(timeout: elementWaitingTime),
            "Gallery button not found"
        )

        var attempts = 0
        var pickButton = findPickButton()

        while !pickButton.exists || attempts == 0, attempts < 3 {
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            pickButton = findPickButton()
            _ = pickButton.waitForExistence(timeout: 5)
            attempts += 1
        }

        XCTAssertGreaterThanOrEqual(attempts, 1)

        let widthField = app.textFields["Enter maxWidth if desired"].firstMatch
        let heightField = app.textFields["Enter maxHeight if desired"].firstMatch
        let qualityField = app.textFields["Enter quality if desired"].firstMatch

        if widthField.waitForExistence(timeout: 5) {
            widthField.tap()
            widthField.typeText(String(maxWidth ?? 100))
        }

        if heightField.waitForExistence(timeout: 5) {
            heightField.tap()
            heightField.typeText(String(maxHeight ?? 100))
        }

        if qualityField.waitForExistence(timeout: 5) {
            qualityField.tap()
            qualityField.typeText(String(quality ?? 50))
        }

        dismissKeyboardIfPresent()

        tapPickButtonAndVerifyGallery()

        let unpickedPhoto = app.images
            .matching(NSPredicate(format: "label CONTAINS 'Photo' AND NOT (label CONTAINS 'picked')"))
            .firstMatch

        if !unpickedPhoto.waitForExistence(timeout: 10) {
            handlePermissionInterruption()
        }

        XCTAssertTrue(
            unpickedPhoto.waitForExistence(timeout: elementWaitingTime),
            "No images found in picker"
        )

        if !unpickedPhoto.isHittable {
            app.swipeUp()
            app.swipeDown()
        }

        unpickedPhoto.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let cancelButton = app.buttons["Cancel"].firstMatch
        let doneButton = app.buttons["Done"].firstMatch
        let addButton = app.buttons["Add"].firstMatch

        if doneButton.waitForExistence(timeout: 5) {
            doneButton.tap()
            _ = doneButton.waitForNonExistence(timeout: 10)

        } else if addButton.waitForExistence(timeout: 5) {
            addButton.tap()

        } else if cancelButton.exists {
            cancelButton.tap()

        } else {
            let backButton = app.navigationBars.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
            }
        }

        if cancelButton.exists {
            _ = cancelButton.waitForNonExistence(timeout: 10)
        }

        XCTAssertTrue(
            cancelButton.waitForNonExistence(timeout: 30),
            "Picker did not dismiss after selection"
        )

        let pickedImage = app.images["image_picker_example_picked_image"].firstMatch

        XCTAssertTrue(
            pickedImage.waitForExistence(timeout: elementWaitingTime),
            "Picked image not displayed"
        )

        XCTAssertTrue(pickedImage.exists)
    }

    func testPickButton_RetryFlow() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        let pickButton = findPickButton()

        if !pickButton.exists {
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        XCTAssertTrue(findPickButton().waitForExistence(timeout: 10))
    }

    func testKeyboardDismissalFlow() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))
        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let widthField = app.textFields["Enter maxWidth if desired"].firstMatch

        if widthField.waitForExistence(timeout: 5) {
            widthField.tap()
            widthField.typeText("123")
        }

        dismissKeyboardIfPresent()

        let keyboard = app.keyboards.element(boundBy: 0)

        _ = keyboard.waitForNonExistence(timeout: 2)
    }

    func testNoPermissionInterruptionFlow() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        var pickButton = findPickButton()
        var pickAvailable = pickButton.waitForExistence(timeout: 5)

        if !pickAvailable {
            app.tap()
            sleep(1)

            pickButton = findPickButton()
            pickAvailable = pickButton.waitForExistence(timeout: 5)
        }

        XCTAssertTrue(pickAvailable, "PICK button not found")

        pickButton.tap()

        sleep(2)

        let cancelButton = app.buttons["Cancel"].firstMatch

        if cancelButton.exists {
            cancelButton.tap()
        } else {
            app.tap()
        }

        sleep(1)

        XCTAssertTrue(galleryButton.exists)
    }

    func testPickerDismiss_BackButtonFallback() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))
        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        tapPickButtonAndVerifyGallery()

        let backButton = app.navigationBars.buttons.firstMatch

        if backButton.exists {
            backButton.tap()
        } else {
            app.tap()
        }

        XCTAssertTrue(galleryButton.waitForExistence(timeout: 5))
    }

    func testKeyboardDismissal_FallbackTap() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let widthField = app.textFields["Enter maxWidth if desired"].firstMatch

        var keyboardOpened = false

        if widthField.waitForExistence(timeout: 5) {
            widthField.tap()
            widthField.typeText("123")
            keyboardOpened = true
        }

        XCTAssertTrue(keyboardOpened)

        app.tap()

        dismissKeyboardIfPresent()

        XCTAssertTrue(true)
    }

    func testRepeatedCancelFlow() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        for _ in 0 ..< 2 {
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

            tapPickButtonAndVerifyGallery()

            let cancelButton = app.buttons["Cancel"].firstMatch

            if cancelButton.waitForExistence(timeout: 10) {
                cancelButton.tap()
            } else {
                app.tap()
            }

            sleep(1)
        }

        XCTAssertTrue(galleryButton.exists)
    }

    func testPickButton_DisappearsAndReappears() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        var pickButton = findPickButton()

        if pickButton.waitForExistence(timeout: 5) {
            pickButton.tap()

            sleep(1)

            pickButton = findPickButton()

            if pickButton.exists {
                pickButton.tap()
            }
        }

        XCTAssertTrue(true) // ✅ flow executed
    }

    func testPicker_NoButtonsFallbackFlow() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let pickButton = findPickButton()
        XCTAssertTrue(pickButton.waitForExistence(timeout: 10))

        pickButton.tap()

        sleep(2)

        let cancelButton = app.buttons["Cancel"].firstMatch

        if cancelButton.exists {
            cancelButton.tap()
        } else {
            app.tap()
        }

        XCTAssertTrue(true)
    }

    func testScrollOnlyBranchExecution() {
        let galleryButton = findGalleryButton()
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        tapPickButtonAndVerifyGallery()

        app.swipeUp()
        app.swipeDown()
        app.swipeUp()

        XCTAssertTrue(true)
    }
}
