// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreLocation
import XCTest
import os.log

private let kWaitTime: TimeInterval = 60

class GoogleMapsUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false

    app = XCUIApplication()
    app.launch()

    addUIInterruptionMonitor(withDescription: "Permission popups") { interruptingElement in
      if #available(iOS 14, *) {
        let locationPermission = interruptingElement.buttons["Allow While Using App"]
        if !locationPermission.waitForExistence(timeout: kWaitTime) {
          XCTFail("Failed due to not able to find locationPermission button")
        }
        locationPermission.tap()
      } else {
        let allow = interruptingElement.buttons["Allow"]
        if !allow.waitForExistence(timeout: kWaitTime) {
          XCTFail("Failed due to not able to find Allow button")
        }
        allow.tap()
      }
      return true
    }
  }

  func testUserInterface() throws {
    let userInterface = app.buttons["User interface"]
    if !userInterface.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find User interface")
    }
    userInterface.tap()

    let platformView = app.otherElements["platform_view[0]"]
    if !platformView.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find platform view")
    }

    // There is a known bug where the permission popups interruption won't get fired until a tap
    // happened in the app. We expect a permission popup so we do a tap here.
    // iOS 16 has a bug where if the app itself is directly tapped: [app tap], the first button
    // (disable compass) in the app is also tapped, so instead we tap a arbitrary location in the app
    // instead.
    let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
    coordinate.tap()
    let compass = app.buttons["disable compass"]
    if !compass.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find disable compass button")
    }

    forceTap(compass)
  }

  func testMapCoordinatesPage() throws {
    let mapCoordinates = app.buttons["Map coordinates"]
    if !mapCoordinates.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find 'Map coordinates'")
    }
    mapCoordinates.tap()

    let platformView = app.otherElements["platform_view[0]"]
    if !platformView.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find platform view")
    }

    let titleBar = app.staticTexts["Map coordinates"]
    if !titleBar.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find title bar")
    }

    let visibleRegionPredicate = NSPredicate(format: "label BEGINSWITH 'VisibleRegion'")
    let visibleRegionText = app.staticTexts.element(matching: visibleRegionPredicate)
    if !visibleRegionText.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find Visible Region label")
    }

    // Validate visible region does not change when scrolled under safe areas.
    // https://github.com/flutter/flutter/issues/107913

    // Example -33.79495661816674, 151.313996873796
    let (originalNortheast, originalSouthwest) = try XCTUnwrap(
      validateVisibleRegion(visibleRegionText.label)
    )
    XCTAssertGreaterThan(originalNortheast.latitude, originalSouthwest.latitude)
    XCTAssertGreaterThan(originalNortheast.longitude, originalSouthwest.longitude)

    XCTAssertLessThan(originalNortheast.latitude, 0)
    XCTAssertLessThan(originalSouthwest.latitude, 0)
    XCTAssertGreaterThan(originalNortheast.longitude, 0)
    XCTAssertGreaterThan(originalSouthwest.longitude, 0)

    // Drag the map upward to under the title bar.
    platformView.press(forDuration: 0, thenDragTo: titleBar)

    let (draggedNortheast, draggedSouthwest) = try XCTUnwrap(
      validateVisibleRegion(visibleRegionText.label)
    )
    XCTAssertEqual(originalNortheast.latitude, draggedNortheast.latitude)
    XCTAssertEqual(originalNortheast.longitude, draggedNortheast.longitude)
    XCTAssertEqual(originalSouthwest.latitude, draggedSouthwest.latitude)
    XCTAssertEqual(originalSouthwest.longitude, draggedSouthwest.longitude)
  }

  func validateVisibleRegion(
    _ label: String
  ) -> (northeast: CLLocationCoordinate2D, southwest: CLLocationCoordinate2D)? {
    // String will be "VisibleRegion:\nnortheast: LatLng(-33.79495661816674,
    // 151.313996873796),\nsouthwest: LatLng(-33.90900557679571, 151.10800322145224)"
    let scan = Scanner(string: label)

    // northeast
    _ = scan.scanString("VisibleRegion:\nnortheast: LatLng(")
    guard let northeastLatitude = scan.scanDouble() else {
      XCTFail("Failed to scan northeastLatitude")
      return nil
    }
    _ = scan.scanString(", ")
    XCTAssertNotEqual(northeastLatitude, 0)
    guard let northeastLongitude = scan.scanDouble() else {
      XCTFail("Failed to scan northeastLongitude")
      return nil
    }
    XCTAssertNotEqual(northeastLongitude, 0)

    _ = scan.scanString("),\nsouthwest: LatLng(")
    guard let southwestLatitude = scan.scanDouble() else {
      XCTFail("Failed to scan southwestLatitude")
      return nil
    }
    XCTAssertNotEqual(southwestLatitude, 0)
    _ = scan.scanString(", ")
    guard let southwestLongitude = scan.scanDouble() else {
      XCTFail("Failed to scan southwestLongitude")
      return nil
    }
    XCTAssertNotEqual(southwestLongitude, 0)

    return (
      CLLocationCoordinate2D(latitude: northeastLatitude, longitude: northeastLongitude),
      CLLocationCoordinate2D(latitude: southwestLatitude, longitude: southwestLongitude)
    )
  }

  func testMapClickPage() throws {
    let mapClick = app.buttons["Map click"]
    if !mapClick.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find 'Map click'")
    }
    mapClick.tap()

    let platformView = app.otherElements["platform_view[0]"]
    if !platformView.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find platform view")
    }

    platformView.tap()

    let tapped = app.staticTexts["Tapped"]
    if !tapped.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find 'tapped'")
    }

    platformView.press(forDuration: 5.0)

    let longPressed = app.staticTexts["Long pressed"]
    if !longPressed.waitForExistence(timeout: kWaitTime) {
      os_log("%@", log: .default, type: .error, app.debugDescription as NSString)
      XCTFail("Failed due to not able to find 'longPressed'")
    }
  }

  func forceTap(_ button: XCUIElement) {
    // iOS 16 introduced a bug where hittable is NO for buttons. We force hit the location of the
    // button if that is the case. It is likely similar to
    // https://github.com/flutter/flutter/issues/113377.
    if button.isHittable {
      button.tap()
      return
    }
    let coordinate = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
    coordinate.tap()
  }

  func testMarkerDraggingCallbacks() throws {
    let application = XCUIApplication()
    application.launch()
    let placeMarkerButton = application.buttons["Place marker"]
    if !placeMarkerButton.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the Place marker button.")
    }
    placeMarkerButton.tap()

    let add = application.buttons["Add"]
    if !add.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the Add button.")
    }
    add.tap()

    let marker = application.buttons["marker_id_1"]
    if !marker.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the marker.")
    }
    marker.tap()

    let toggleDraggable = application.buttons["toggle draggable"]
    if !toggleDraggable.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the toggle draggable.")
    }
    toggleDraggable.tap()

    // Drag marker to center
    marker.press(forDuration: 5, thenDragTo: application)

    let predicateDragStart = NSPredicate(format: "label CONTAINS[c] %@", "_onMarkerDragStart")
    let predicateDrag = NSPredicate(format: "label CONTAINS[c] %@", "_onMarkerDrag called")
    let predicateDragEnd = NSPredicate(format: "label CONTAINS[c] %@", "_onMarkerDragEnd")

    let dragStart = application.staticTexts.matching(predicateDragStart).element
    if !dragStart.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the _onMarkerDragStart.")
    }
    XCTAssertTrue(dragStart.exists)

    let drag = application.staticTexts.matching(predicateDrag).element
    if !drag.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the _onMarkerDrag.")
    }
    XCTAssertTrue(drag.exists)

    let dragEnd = application.staticTexts.matching(predicateDragEnd).element
    if !dragEnd.waitForExistence(timeout: kWaitTime) {
      NSLog("application.debugDescription: %@", application.debugDescription as NSString)
      XCTFail("Failed to find the _onMarkerDragEnd.")
    }
    XCTAssertTrue(dragEnd.exists)
  }
}
