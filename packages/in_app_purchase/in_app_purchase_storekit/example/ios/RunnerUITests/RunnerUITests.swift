// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class RunnerUITests: XCTestCase {
  var app: XCUIApplication!

  var consumable_price = "$0.99";
  var upgrade_price = "$10.99";
  var subscription_silver_price = "$4.99";
  var subscription_gold_price = "$5.99";
  var bought_item_name = "Bought Item";

  var prices: [String] = [];

  override class func setUp() {
      super.setUp()
  }

  override func setUp() {
    continueAfterFailure = false
    prices = [
      consumable_price,
      upgrade_price,
      subscription_silver_price,
      subscription_gold_price
    ];

    app = XCUIApplication()
    app.launch()
    clearPurchases();
  }

  override func tearDown() {
    clearPurchases();
  }

  func testStoreInitalizesCorrectly() {
    let app = self.app!

    let button = app.staticTexts["The store is available."];
    XCTAssertTrue(button.waitForExistence(timeout: 30.0))

    for price in prices {
      let button = app.buttons[price];
      XCTAssertTrue(button.waitForExistence(timeout: 30.0))
    }
  }

  func testPurchaseConsumable() {
    // Bundle identifier for the process that handles in app purchases
    let springBoard =  XCUIApplication(bundleIdentifier: "com.apple.springboard")

    let consumable_button = app.buttons[consumable_price];
    XCTAssertTrue(consumable_button.waitForExistence(timeout: 30.0))

    consumable_button.tap();

    let purchase_button = springBoard.buttons["Purchase"];
    XCTAssertTrue(purchase_button.waitForExistence(timeout: 30.0));

    purchase_button.tap();

    let ok_button = springBoard.buttons["OK"];
    XCTAssertTrue(ok_button.waitForExistence(timeout: 30.0));

    ok_button.tap();

    XCTAssertTrue(app.buttons.matching(identifier: bought_item_name).count == 1);
  }

  func testRestorePurchases() {
    let restore_button = app.buttons["Restore purchases"];
    XCTAssertTrue(restore_button.waitForExistence(timeout: 30.0));

    restore_button.tap();

    let restored_buttons = app.buttons.matching(identifier: "Restored")
    XCTAssertTrue(restored_buttons.element(boundBy: 0).waitForExistence(timeout: 30.0));
    XCTAssertTrue(restored_buttons.count == 3);
  }

  func clearPurchases() {
    // Can't reset the IAP sandbox programmatically, so manually clear purchases.
    // Elements must be tapped in reverse order since they vanish on tap, causing the remaining elements to shift positions.
    for button in app.buttons.matching(identifier: bought_item_name).allElementsBoundByIndex.reversed() {
      button.tap();
    }
  }
}
