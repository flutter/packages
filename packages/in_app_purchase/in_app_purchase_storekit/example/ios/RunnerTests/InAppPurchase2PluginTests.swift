// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

@available(iOS 15.0, *)
final class InAppPurchase2PluginTests: XCTestCase {
  var session: SKTestSession!
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
    let result = try plugin.canMakePayments()
    XCTAssertTrue(result)
  }

  func testGetProducts() async throws {
    let expectation = self.expectation(description: "products successfully fetched")

    var fetchedProductMsg: SK2ProductMessage?
    plugin.products(identifiers: ["subscription_silver"]) { result in
      switch result {
      case .success(let productMessages):
        fetchedProductMsg = productMessages.first
        expectation.fulfill()
      case .failure(let error):
        // Handle the error
        print("Failed to fetch products: \(error.localizedDescription)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)

    let testProduct = try await Product.products(for: ["subscription_silver"]).first

    let testProductMsg = testProduct?.convertToPigeon()

    XCTAssertNotNil(fetchedProductMsg)
    XCTAssertEqual(testProductMsg, fetchedProductMsg)
  }

  func testGetInvalidProducts() async throws {
    let expectation = self.expectation(description: "products successfully fetched")

    var fetchedProductMsg: [SK2ProductMessage]?
    plugin.products(identifiers: ["invalid_product"]) { result in
      switch result {
      case .success(let productMessages):
        fetchedProductMsg = productMessages
        expectation.fulfill()
      case .failure(let error):
        // Handle the error
        print("Failed to fetch products: \(error.localizedDescription)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)

    XCTAssert(fetchedProductMsg?.count == 0)
  }
}
