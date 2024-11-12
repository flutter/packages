// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

@available(iOS 15.0, macOS 12.0, *)

final class InAppPurchase2PluginTests: XCTestCase {
  private var session: SKTestSession!
  private var plugin: InAppPurchasePlugin!

  override func setUp() async throws {
    try await super.setUp()

    session = try! SKTestSession(configurationFileNamed: "Configuration")
    session.resetToDefaultState()
    session.clearTransactions()
    session.disableDialogs = true

    plugin = InAppPurchasePluginStub(receiptManager: FIAPReceiptManagerStub()) { request in
      DefaultRequestHandler(requestHandler: FIAPRequestHandler(request: request))
    }
    try plugin.startListeningToTransactions()
  }

  override func tearDown() async throws {
    self.session.clearTransactions()
    session.disableDialogs = false
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
        print("Failed to fetch products: \(error.localizedDescription)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)

    let testProduct = try await Product.products(for: ["subscription_silver"]).first

    let testProductMsg = testProduct?.convertToPigeon

    XCTAssertNotNil(fetchedProductMsg)
    XCTAssertEqual(testProductMsg, fetchedProductMsg)
  }

  func testGetDiscountedProducts() async throws {
    let expectation = self.expectation(description: "products successfully fetched")

    var fetchedProductMsg: SK2ProductMessage?
    plugin.products(identifiers: ["subscription_silver"]) { result in
      switch result {
      case .success(let productMessages):
        fetchedProductMsg = productMessages.first
        expectation.fulfill()
      case .failure(let error): print("Failed to fetch products: \(error.localizedDescription)")
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
  @available(iOS 17.0, macOS 14.0, *)
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
        XCTAssert(
          error.localizedDescription
            == "The operation couldn’t be completed. (in_app_purchase_storekit.PigeonError error 1.)"
        )
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testSuccessfulPurchase() async throws {
    let expectation = self.expectation(description: "Purchase request should succeed")
    plugin.purchase(id: "consumable", options: nil) { result in
      switch result {
      case .success(let purchaseResult):
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Purchase should NOT fail. Failed with \(error)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  @available(iOS 17.0, macOS 14.0, *)
  func testFailedNetworkErrorPurchase() async throws {
    try await session.setSimulatedError(
      .generic(.networkError(URLError(.badURL))), forAPI: .loadProducts)
    let expectation = self.expectation(description: "products request should fail")
    plugin.purchase(id: "consumable", options: nil) { result in
      switch result {
      case .success(_):
        XCTFail("Purchase should NOT suceed.")
      case .failure(let error):
        XCTAssertEqual(
          error.localizedDescription,
          "The operation couldn’t be completed. (NSURLErrorDomain error -1009.)")
        expectation.fulfill()
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  @available(iOS 17.0, macOS 14.0, *)
  func testFailedProductUnavilablePurchase() async throws {
    try await session.setSimulatedError(
      .purchase(.productUnavailable), forAPI: .purchase)
    let expectation = self.expectation(description: "Purchase request should succeed")
    plugin.purchase(id: "consumable", options: nil) { result in
      switch result {
      case .success(_):
        XCTFail("Purchase should NOT suceed.")
      case .failure(let error):
        XCTAssertEqual(error.localizedDescription, "Item Unavailable")
        expectation.fulfill()
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testInvalidProductPurchase() async throws {
    let expectation = self.expectation(description: "products request should fail")
    plugin.purchase(id: "invalid_product", options: nil) { result in
      switch result {
      case .success(_):
        XCTFail("Purchase should NOT suceed.")
      case .failure(let error):
        let pigeonError = error as! PigeonError

        XCTAssertEqual(pigeonError.code, "storekit2_failed_to_fetch_product")
        expectation.fulfill()
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testPurchaseUpgradeConsumableSuccess() async throws {
    let expectation = self.expectation(description: "Purchase request should succeed")
    plugin.purchase(id: "subscription_discounted", options: nil) { result in
      switch result {
      case .success(let purchaseResult):
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Purchase should NOT fail. Failed with \(error)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testDiscountedSubscriptionSuccess() async throws {
    let expectation = self.expectation(description: "Purchase request should succeed")
    plugin.purchase(id: "subscription_discounted", options: nil) { result in
      switch result {
      case .success(let purchaseResult):
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Purchase should NOT fail. Failed with \(error)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testDiscountedProductSuccess() async throws {
    let expectation = self.expectation(description: "Purchase request should succeed")
    plugin.purchase(id: "consumable_discounted", options: nil) { result in
      switch result {
      case .success(let purchaseResult):
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Purchase should NOT fail. Failed with \(error)")
      }
    }
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testRestoreProductSuccess() async throws {
    let purchaseExpectation = self.expectation(description: "Purchase request should succeed")
    let restoreExpectation = self.expectation(description: "Restore request should succeed")

    plugin.purchase(id: "subscription_silver", options: nil) { result in
      switch result {
      case .success(_):
        purchaseExpectation.fulfill()
      case .failure(let error):
        XCTFail("Purchase should NOT fail. Failed with \(error)")
      }
    }
    plugin.restorePurchases { result in
      switch result {
      case .success():
        restoreExpectation.fulfill()
      case .failure(let error):
        XCTFail("Restore purchases should NOT fail. Failed with \(error)")
      }
    }

    await fulfillment(of: [restoreExpectation, purchaseExpectation], timeout: 5)
  }
}
