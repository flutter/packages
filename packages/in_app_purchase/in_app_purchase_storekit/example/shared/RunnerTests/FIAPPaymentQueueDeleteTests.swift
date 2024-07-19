// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit
import XCTest

@testable import in_app_purchase_storekit

@available(iOS 13.0, *)
final class FIAPPaymentQueueDelegateTests: XCTestCase {
  var transaction: SKPaymentTransaction!
  var storefront: SKStorefront!

  override func setUp() {
    super.setUp()
    let transactionMap: [String: Any] = [
      "transactionIdentifier": NSNull(),
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": Date().timeIntervalSince1970,
      "originalTransaction": NSNull(),
    ]
    self.transaction = SKPaymentTransactionStub(map: transactionMap)

    let storefrontMap: [String: Any] = [
      "countryCode": "USA",
      "identifier": "unique_identifier",
    ]
    self.storefront = SKStorefrontStub(map: storefrontMap)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testShouldContinueTransaction() {
    let channelStub = MethodChannelStub()
    channelStub.invokeMethodChannelWithResultsStub = { method, arguments, result in
      XCTAssertEqual(method, "shouldContinueTransaction")
      XCTAssertEqual(
        arguments as! NSDictionary,
        FIAObjectTranslator.getMapFrom(
          self.storefront,
          andSKPaymentTransaction: self.transaction) as NSDictionary)

      guard let result = result else {
        XCTFail("Result should not be nil")
        return
      }
      result(false)
    }

    let delegate = FIAPPaymentQueueDelegate(methodChannel: channelStub)

    let shouldContinue = delegate.paymentQueue(
      SKPaymentQueueStub(),
      shouldContinue: self.transaction,
      in: self.storefront)

    XCTAssertFalse(shouldContinue)
  }

  func testShouldContinueTransactionShouldDefaultToYes() {
    let channelStub = MethodChannelStub()
    let delegate = FIAPPaymentQueueDelegate(methodChannel: channelStub)

    channelStub.invokeMethodChannelWithResultsStub = { method, arguments, result in
      XCTAssertEqual(method, "shouldContinueTransaction")
      XCTAssertEqual(
        arguments as! NSDictionary,
        FIAObjectTranslator.getMapFrom(
          self.storefront,
          andSKPaymentTransaction: self.transaction) as NSDictionary)
    }

    let shouldContinue = delegate.paymentQueue(
      SKPaymentQueueStub(),
      shouldContinue: self.transaction,
      in: self.storefront)

    XCTAssertTrue(shouldContinue)
  }

  #if TARGET_OS_IOS
    func testShouldShowPriceConsentIfNeeded() throws {
      if #available(iOS 13.4, *) {
        let channelStub = MethodChannelStub()
        let delegate = FIAPPaymentQueueDelegate(methodChannel: channelStub)

        channelStub.invokeMethodChannelWithResultsStub = { method, arguments, result in
          XCTAssertEqual(method, "shouldShowPriceConsent")
          XCTAssertNil(arguments)

          guard let result = result else {
            XCTFail("Result should not be nil")
            return
          }
          result(false)
        }

        let shouldShow = delegate.paymentQueueShouldShowPriceConsent(SKPaymentQueueStub())

        XCTAssertFalse(shouldShow)
      }
    }

    func testShouldShowPriceConsentIfNeededShouldDefaultToYes() {
      if #available(iOS 13.4, *) {
        let channelStub = MethodChannelStub()
        let delegate = FIAPPaymentQueueDelegate(methodChannel: channelStub)

        channelStub.invokeMethodChannelWithResultsStub = { method, arguments, result in
          XCTAssertEqual(method, "shouldShowPriceConsent")
          XCTAssertNil(arguments)
        }

        let shouldShow = delegate.paymentQueueShouldShowPriceConsent(SKPaymentQueueStub())

        XCTAssertTrue(shouldShow)
      }
    }
  #endif
}
