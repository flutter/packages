// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import StoreKit
import XCTest

@testable import in_app_purchase_storekit

final class RequestHandlerTest: XCTestCase {

  func testRequestHandlerWithProductRequestSuccess() {
    let productIdentifiers = Set(["123"])
    let request = SKProductRequestStub(productIdentifiers: productIdentifiers)
    let handler = FIAPRequestHandler(request: request)

    let expectation = expectation(description: "Expect response with 1 product")
    var response: SKProductsResponse?

    handler.startProductRequest { requestResponse, _ in
      response = requestResponse
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)

    XCTAssertNotNil(response)
    XCTAssertEqual(response?.products.count, 1)
    XCTAssertEqual(response?.products.first?.productIdentifier, "123")
  }

  func testRequestHandlerWithProductRequestFailure() {
    let request = SKProductRequestStub(
      failureError: NSError(domain: "test", code: 123, userInfo: [:]))
    let handler = FIAPRequestHandler(request: request)

    let expectation = expectation(description: "Expect response with error")
    var error: Error?
    var response: SKProductsResponse?

    handler.startProductRequest { r, e in
      response = r
      error = e
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)

    XCTAssertNotNil(error)
    XCTAssertEqual((error as NSError?)?.domain, "test")
    XCTAssertNil(response)
  }

  func testRequestHandlerWithRefreshReceiptSuccess() {
    let request = SKReceiptRefreshRequestStub(receiptProperties: nil)
    let handler = FIAPRequestHandler(request: request)

    let expectation = expectation(description: "Expect no error")
    var error: Error?

    handler.startProductRequest { _, e in
      error = e
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
    XCTAssertNil(error)
  }

  func testRequestHandlerWithRefreshReceiptFailure() {
    let request = SKReceiptRefreshRequestStub(
      failureError: NSError(domain: "test", code: 123, userInfo: [:]))
    let handler = FIAPRequestHandler(request: request)

    let expectation = expectation(description: "Expect error")
    var error: Error?
    var response: SKProductsResponse?

    handler.startProductRequest { r, e in
      response = r
      error = e
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)

    XCTAssertNotNil(error)
    XCTAssertEqual((error as NSError?)?.domain, "test")
    XCTAssertNil(response)
  }
}
