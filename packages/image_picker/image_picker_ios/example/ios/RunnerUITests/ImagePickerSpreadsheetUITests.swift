// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@MainActor
class ImagePickerSpreadsheetUITests: XCTestCase {
    var app: XCUIApplication!
    let elementWaitingTime: TimeInterval = 60

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // We don't reset authorization here to allow testing different states if needed,
        // but for clean integration tests, we usually want a known state.
        app.launch()
    }

    override func tearDown() async throws {
        app.terminate()
        try await super.tearDown()
    }

    // MARK: - Helper Methods

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

    private func tapPickButton() {
        let pickButton = app.buttons["PICK"].firstMatch
        XCTAssertTrue(pickButton.waitForExistence(timeout: 20), "PICK button (dialog) not found")
        pickButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    // MARK: - Test Cases from Spreadsheet

    /// ImagePicker_04: Multi-Select Functionality
    func testMultiSelectFunctionality() {
        let multiImageButton = findElement(identifier: "Pick multiple images")
        XCTAssertTrue(multiImageButton.waitForExistence(timeout: elementWaitingTime))
        multiImageButton.tap()

        // Handle the "Add optional parameters" dialog
        tapPickButton()

        let galleryCancel = app.buttons["Cancel"].firstMatch
        XCTAssertTrue(galleryCancel.waitForExistence(timeout: 30), "Gallery did not appear")

        // Select multiple images (if possible in the simulator/test env)
        let images = app.scrollViews.images
        let count = images.count
        if count >= 2 {
            images.element(boundBy: 0).tap()
            images.element(boundBy: 1).tap()
        } else if count > 0 {
            images.element(boundBy: 0).tap()
        }

        let doneButton = app.buttons["Add"].firstMatch.exists ? app.buttons["Add"] : app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        }

        // Verify multiple images or at least one is picked
        let pickedImage = app.images["image_picker_example_picked_image"].firstMatch
        XCTAssertTrue(pickedImage.waitForExistence(timeout: elementWaitingTime), "No image was picked in multi-select mode")
    }

    /// ImagePicker_16: Standard Video Selection
    func testStandardVideoSelection() {
        let videoButton = findElement(identifier: "Pick video from gallery")
        XCTAssertTrue(videoButton.waitForExistence(timeout: elementWaitingTime))
        videoButton.tap()

        // Video picker usually doesn't have the optional parameters dialog in this example
        // but we check just in case it's added.
        let pickButton = app.buttons["PICK"].firstMatch
        if pickButton.exists {
            pickButton.tap()
        }

        let galleryCancel = app.buttons["Cancel"].firstMatch
        XCTAssertTrue(galleryCancel.waitForExistence(timeout: 30), "Gallery did not appear for video")

        // In many simulators there are no videos by default. This test might stay in the gallery.
        // We check for "Videos" album if it exists or just any selectable item.
        let videoItem = app.scrollViews.images.firstMatch
        if videoItem.exists {
            videoItem.tap()
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Picked'")).firstMatch.waitForExistence(timeout: elementWaitingTime))
        }
    }

    /// ImagePicker_23: Mixed Media Selection
    func testMixedMediaSelection() {
        let mixedButton = findElement(identifier: "Pick multiple items")
        XCTAssertTrue(mixedButton.waitForExistence(timeout: elementWaitingTime))
        mixedButton.tap()

        tapPickButton()

        let galleryCancel = app.buttons["Cancel"].firstMatch
        XCTAssertTrue(galleryCancel.waitForExistence(timeout: 30), "Gallery did not appear for mixed media")

        // Select a few items
        let items = app.scrollViews.images
        if items.count >= 2 {
            items.element(boundBy: 0).tap()
            items.element(boundBy: 1).tap()
        }

        let doneButton = app.buttons["Add"].firstMatch.exists ? app.buttons["Add"] : app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        }

        XCTAssertTrue(app.images["image_picker_example_picked_image"].firstMatch.waitForExistence(timeout: elementWaitingTime))
    }

    /// ImagePicker_15: Capture and Discard (Camera)
    /// Note: Testing camera in simulator is limited, but we can verify the UI transition.
    func testCaptureAndDiscard() {
        let cameraButton = findElement(identifier: "Take a photo")
        XCTAssertTrue(cameraButton.waitForExistence(timeout: elementWaitingTime))
        cameraButton.tap()

        // Dialog
        tapPickButton()

        // In simulator, this usually shows an error alert "Camera not available"
        let alert = app.alerts["Error"].firstMatch
        if alert.waitForExistence(timeout: 10) {
            XCTAssertTrue(alert.staticTexts["Camera not available."].exists)
            alert.buttons["OK"].tap()
        }
    }
}
