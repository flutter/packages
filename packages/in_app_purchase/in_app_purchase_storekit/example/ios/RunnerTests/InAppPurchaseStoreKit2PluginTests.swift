// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

@available(iOS 15.0, *)
final class InAppPurchase2PluginTests: XCTestCase {
  private var session: SKTestSession!
  private var plugin: InAppPurchasePlugin!

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

    let testProductMsg = testProduct?.convertToPigeon

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
      case .failure(_):
        XCTFail("Products should be successfully fetched")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)

    XCTAssert(fetchedProductMsg?.count == 0)
  }

  //TODO(louisehsu): Add testing for lower versions.
  @available(iOS 17.0, *)
  func testGetProductsWithStoreKitError() async throws {
    try await session.setSimulatedError(
      .generic(.networkError(URLError(.badURL))), forAPI: .loadProducts)

    let expectation = self.expectation(description: "products request should fail")

    plugin.products(identifiers: ["subscription_silver"]) { result in
      switch result {
      case .success(_):
        XCTFail("This `products` call should not succeed")
      case .failure(let error):
        expectation.fulfill()
        print(error.localizedDescription)
        XCTAssert(
          error.localizedDescription
            == "The operation couldn’t be completed. (in_app_purchase_storekit.PigeonError error 1.)"
        )
      }
    }
    await fulfillment(of: [expectation], timeout: 5)

    // Reset test session
    try await session.setSimulatedError(nil, forAPI: .loadProducts)
  }
}
