// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@MainActor
class ImagePickerFromLimitedGalleryUITests: XCTestCase {
    var app = XCUIApplication()
    let elementWaitingTime: TimeInterval = 60

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false

        if #available(iOS 13.4, *) {
            app.resetAuthorizationStatus(for: .photos)
        }

        app.launch()

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

    private func handlePermissionInterruption() {
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
                break
            }
        }
    }

    private func findElement(identifier: String) -> XCUIElement {
        let discoveryOrder = [
            app.buttons[identifier],
            app.otherElements[identifier],
            app.descendants(matching: .any)[identifier],
        ]

        for element in discoveryOrder {
            if element.exists {
                return element
            }
        }
        return app.buttons[identifier].firstMatch
    }

    private func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let hideButton = app.keyboards.buttons["Hide keyboard"]
                if hideButton.exists { hideButton.tap() }
            } else {
                let doneButton = app.toolbars.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                } else {
                    app.keyboards.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.05)).tap()
                }
            }
            _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait for keyboard")], timeout: 1.0)
        }
    }

    func testPickingFromLimitedGallery() {
        let galleryButton = findElement(identifier: "image_picker_example_from_gallery")
        XCTAssertTrue(
            galleryButton.waitForExistence(timeout: elementWaitingTime), "Gallery button not found"
        )
        galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let pickButton = app.buttons["PICK"].firstMatch
        if !pickButton.waitForExistence(timeout: 10) {
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        XCTAssertTrue(pickButton.waitForExistence(timeout: elementWaitingTime), "PICK button not found")

        let cancelButton = app.buttons["Cancel"].firstMatch
        var retryCount = 0
        while !cancelButton.exists, retryCount < 3 {
            pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            if cancelButton.waitForExistence(timeout: 15) {
                break
            }
            retryCount += 1
        }

        _ = app.wait(for: .runningForeground, timeout: 5)

        let firstImage = app.scrollViews.images.firstMatch
        XCTAssertTrue(
            firstImage.waitForExistence(timeout: elementWaitingTime), "No images found in picker."
        )
        firstImage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let doneButton = app.buttons["Done"].firstMatch
        if doneButton.exists {
            doneButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            _ = doneButton.waitForNonExistence(timeout: 20)
        }

        if cancelButton.waitForNonExistence(timeout: 20) {
        } else if cancelButton.exists {
            cancelButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        XCTAssertTrue(
            cancelButton.waitForNonExistence(timeout: 30), "Picker did not dismiss after selection."
        )
    }

    func testPickingFromGallery_CancelFlow() {
        let galleryButton = findElement(identifier: "image_picker_example_from_gallery")
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))
        galleryButton.tap()

        let pickButton = app.buttons["PICK"].firstMatch
        XCTAssertTrue(pickButton.waitForExistence(timeout: elementWaitingTime))
        pickButton.tap()

        let cancelButton = app.buttons["Cancel"].firstMatch
        let doneButton = app.buttons["Done"].firstMatch
        let addButton = app.buttons["Add"].firstMatch
        let backButton = app.navigationBars.buttons.firstMatch

        let pickerAppeared =
            cancelButton.waitForExistence(timeout: 10) ||
            doneButton.waitForExistence(timeout: 10) ||
            addButton.waitForExistence(timeout: 10) ||
            backButton.waitForExistence(timeout: 10)

        XCTAssertTrue(pickerAppeared, "No picker UI appeared")

        if cancelButton.exists {
            cancelButton.tap()
        } else if doneButton.exists {
            doneButton.tap()
        } else if addButton.exists {
            addButton.tap()
        } else if backButton.exists {
            backButton.tap()
        } else {
            app.tap()
        }

        sleep(1)

        let pickedImage = app.images["image_picker_example_picked_image"].firstMatch
        XCTAssertFalse(pickedImage.exists)
    }

    func testSelectingImageMultipleTimes() {
        let galleryButton = findElement(identifier: "image_picker_example_from_gallery")
        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        for _ in 0 ..< 2 {
            XCTAssertTrue(galleryButton.exists)
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

            let pickButton = app.buttons["PICK"].firstMatch
            XCTAssertTrue(pickButton.waitForExistence(timeout: 10))
            pickButton.tap()

            let firstImage = app.scrollViews.images.firstMatch

            XCTAssertTrue(
                firstImage.waitForExistence(timeout: 20),
                "No image found in picker"
            )

            if !firstImage.isHittable {
                app.swipeUp()
                app.swipeDown()
            }

            firstImage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

            let dismissButton = app.buttons.matching(NSPredicate(format: "label == 'Done' OR label == 'Add' OR label == 'Cancel'")).firstMatch
            if dismissButton.waitForExistence(timeout: 10) {
                dismissButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }

            _ = firstImage.waitForNonExistence(timeout: 20)
            sleep(1)
        }

        let pickedImage = app.images["image_picker_example_picked_image"].firstMatch
    }

    func testGallery_OpenCloseWithoutSelection() {
        let galleryButton = findElement(identifier: "image_picker_example_from_gallery")

        XCTAssertTrue(galleryButton.waitForExistence(timeout: elementWaitingTime))

        for _ in 0 ..< 2 {
            XCTAssertTrue(galleryButton.waitForExistence(timeout: 10))
            galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

            let pickButton = app.buttons["PICK"].firstMatch

            var pickAvailable = pickButton.waitForExistence(timeout: 10)

            if !pickAvailable {
                galleryButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                pickAvailable = pickButton.waitForExistence(timeout: 10)
            }

            XCTAssertTrue(pickAvailable, "PICK button not found")

            pickButton.tap()

            sleep(2)

            let dismissButton = app.buttons.matching(NSPredicate(format: "label == 'Cancel' OR label == 'Done' OR label == 'Add'")).firstMatch
            if dismissButton.waitForExistence(timeout: 10) {
                dismissButton.tap()
            } else {
                app.tap()
            }

            sleep(1)
        }

        XCTAssertTrue(galleryButton.exists)
    }
}
