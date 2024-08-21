// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import StoreKitTest

@testable import in_app_purchase_storekit

@available(iOS 15.0, *)
final class InAppPurchase2PluginTests : XCTestCase {
  var session : SKTestSession!
  var plugin: InAppPurchasePlugin!

  override func setUp() async throws {
    try await super.setUp()

    self.session = try! SKTestSession(configurationFileNamed: "Configuration")
    self.session.clearTransactions()
    let receiptManagerStub = FIAPReceiptManagerStub()
    plugin = InAppPurchasePluginStub(receiptManager: receiptManagerStub) { request in
      DefaultRequestHandler(requestHandler: FIAPRequestHandler(request: request))
    }
  }

  func testCanMakePayments() throws {
    let result = try plugin.canMakePayments();
    XCTAssertTrue(result);
  }

  func testGetInvalidProducts() throws {
    let expectation = self.expectation(description: "completion handler successfully called")
    plugin.products(identifiers: ["subscription_silver", "subscription_gold"]) { result in
      switch result {
      case .success(let productMessages):
        expectation.fulfill()
        for productMessage in productMessages {
          print("Fetched product: \(productMessage)")
        }
      case .failure(let error):
        // Handle the error
        print("Failed to fetch products: \(error.localizedDescription)")
      }
    }
    waitForExpectations(timeout: 5, handler: nil)
  }

    func testGetProducts() throws {
      plugin.products(identifiers: ["123"]) { response in
        XCTAssertNotNil(response)
        print(response)
      }
    }



  }

