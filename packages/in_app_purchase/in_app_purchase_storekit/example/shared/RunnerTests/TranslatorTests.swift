// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKit
import XCTest

@testable import in_app_purchase_storekit

final class ObjectTranslatorTest: XCTestCase {
  private var periodMap: [String: Any] {
    ["numberOfUnits": 0, "unit": 0]
  }
  private var discountMap: [String: Any] {
    var map: [String: Any] = [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
      "numberOfPeriods": 1,
      "subscriptionPeriod": periodMap,
      "paymentMode": 1,
    ]
    if #available(iOS 12.2, *) {
      map["identifier"] = "test offer id"
      // Type is being instantiated like this because of Swift naming weirdness
      let type: SKProductDiscount.`Type` = .introductory
      map["type"] = type.rawValue
    }
    return map
  }
  private var discountMissingIdentifierMap: [String: Any] {
    [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
      "numberOfPeriods": 1,
      "subscriptionPeriod": periodMap,
      "paymentMode": 1,
      "identifier": NSNull(),
      "type": 0,
    ]
  }
  private var productMap: [String: Any] {
    var map: [String: Any] = [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
      "productIdentifier": "123",
      "localizedTitle": "title",
      "localizedDescription": "des",
      "subscriptionPeriod": periodMap,
      "introductoryPrice": discountMap,
      "subscriptionGroupIdentifier": "com.group",
    ]
    if #available(iOS 12.2, *) {
      map["discounts"] = [discountMap]
    }
    return map
  }
  private var productResponseMap: [String: Any] {
    ["products": [productMap], "invalidProductIdentifiers": []]
  }
  private var paymentMap: [String: Any] {
    [
      "productIdentifier": "123",
      "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
      "quantity": 2,
      "applicationUsername": "app user name",
      "simulatesAskToBuyInSandbox": false,
    ]
  }
  private var paymentDiscountMap: [String: Any] {
    [
      "identifier": "payment_discount_identifier",
      "keyIdentifier": "payment_discount_key_identifier",
      "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
      "signature": "this is an encrypted signature",
      "timestamp": Int(Date().timeIntervalSince1970),
    ]
  }
  private var transactionMap: [String: Any] {
    [
      "transactionIdentifier": "567",
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": Int(Date().timeIntervalSince1970),
      "originalTransaction": originalTransactionMap,
    ]
  }
  private var originalTransactionMap: [String: Any] {
    [
      "transactionIdentifier": "567",
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": Int(Date().timeIntervalSince1970),
      "originalTransaction": NSNull(),
    ]
  }
  private var errorMap: [String: Any] {
    [
      "code": 123,
      "domain": "test_domain",
      "userInfo": ["key": "value"],
    ]
  }
  private var storefrontMap: [String: Any] {
    [
      "countryCode": "USA",
      "identifier": "unique_identifier",
    ]
  }
  private var storefrontAndPaymentTransactionMap: [String: Any] {
    [
      "storefront": storefrontMap,
      "transaction": transactionMap,
    ]
  }

  func testSKProductSubscriptionPeriodStubToMap() {
    let period = SKProductSubscriptionPeriodStub(map: periodMap)
    let map = FIAObjectTranslator.getMapFrom(period)

    XCTAssertEqual(map as NSDictionary, periodMap as NSDictionary)
  }

  func testSKProductDiscountStubToMap() {
    let discount = SKProductDiscountStub(map: discountMap)
    let map = FIAObjectTranslator.getMapFrom(discount)

    XCTAssertEqual(map as NSDictionary, discountMap as NSDictionary)
  }

  func testProductToMap() {
    let product = SKProductStub(map: productMap)
    let map = FIAObjectTranslator.getMapFrom(product)

    XCTAssertEqual(map as NSDictionary, productMap as NSDictionary)
  }

  func testProductResponseToMap() {
    let response = SKProductsResponseStub(map: productResponseMap)
    let map = FIAObjectTranslator.getMapFrom(response)

    XCTAssertEqual(map as NSDictionary, productResponseMap as NSDictionary)
  }

  func testPaymentToMap() {
    let payment = FIAObjectTranslator.getSKMutablePayment(fromMap: paymentMap)
    let map = FIAObjectTranslator.getMapFrom(payment)

    XCTAssertEqual(map as NSDictionary, paymentMap as NSDictionary)
  }

  func testPaymentTransactionToMap() {
    let paymentTransaction = SKPaymentTransactionStub(map: transactionMap)
    let map = FIAObjectTranslator.getMapFrom(paymentTransaction)

    XCTAssertEqual(map as NSDictionary, transactionMap as NSDictionary)
  }

  func testError() {
    let error = NSErrorStub(map: errorMap)
    let map = FIAObjectTranslator.getMapFrom(error)

    XCTAssertEqual(map as NSDictionary, errorMap as NSDictionary)
  }

  func testErrorWithNSNumberAsUserInfo() {
    let error = NSError(domain: SKErrorDomain, code: 3, userInfo: ["key": 42])
    let expectedMap: [String: Any] = [
      "domain": SKErrorDomain,
      "code": 3,
      "userInfo": ["key": 42],
    ]
    let map = FIAObjectTranslator.getMapFrom(error)

    XCTAssertEqual(map as NSDictionary, expectedMap as NSDictionary)
  }

  func testErrorWithMultipleUnderlyingErrors() {
    let underlyingErrorOne = NSError(domain: SKErrorDomain, code: 2, userInfo: nil)
    let underlyingErrorTwo = NSError(domain: SKErrorDomain, code: 1, userInfo: nil)
    let mainError = NSError(
      domain: SKErrorDomain,
      code: 3,
      userInfo: ["underlyingErrors": [underlyingErrorOne, underlyingErrorTwo]]
    )
    let expectedMap: [String: Any] = [
      "domain": SKErrorDomain,
      "code": 3,
      "userInfo": [
        "underlyingErrors": [
          ["domain": SKErrorDomain, "code": 2, "userInfo": [:]],
          ["domain": SKErrorDomain, "code": 1, "userInfo": [:]],
        ]
      ],
    ]
    let map = FIAObjectTranslator.getMapFrom(mainError)

    XCTAssertEqual(map as NSDictionary, expectedMap as NSDictionary)
  }

  func testErrorWithNestedUnderlyingError() {
    let underlyingError = NSError(domain: SKErrorDomain, code: 2, userInfo: nil)
    let mainError = NSError(
      domain: SKErrorDomain,
      code: 3,
      userInfo: ["nesting": ["underlyingError": underlyingError]]
    )
    let expectedMap: [String: Any] = [
      "domain": SKErrorDomain,
      "code": 3,
      "userInfo": [
        "nesting": [
          "underlyingError": ["domain": SKErrorDomain, "code": 2, "userInfo": [:]]
        ]
      ],
    ]
    let map = FIAObjectTranslator.getMapFrom(mainError)

    XCTAssertEqual(map as NSDictionary, expectedMap as NSDictionary)
  }

  func testErrorWithUnsupportedUserInfo() {
    let error = NSError(
      domain: SKErrorDomain,
      code: 3,
      userInfo: ["user_info": NSObject()]
    )
    let expectedMap: [String: Any] = [
      "domain": SKErrorDomain,
      "code": 3,
      "userInfo": [
        "user_info": String(
          format: """
            Unable to encode native userInfo object of type %@ to map. \
            Please submit an issue at https://github.com/flutter/flutter/issues/new \
            with the title "[in_app_purchase_storekit] Unable to encode userInfo of type %@\" \
            and add reproduction steps and the error details in the description field.
            """,
          NSStringFromClass(NSObject.self), NSStringFromClass(NSObject.self)
        )
      ],
    ]
    let map = FIAObjectTranslator.getMapFrom(error)

    XCTAssertEqual(map as NSDictionary, expectedMap as NSDictionary)
  }

  func testLocaleToMap() {
    let system = Locale(identifier: "en_US")
    let map = FIAObjectTranslator.getMapFrom(system)

    XCTAssertEqual(map["currencySymbol"] as? String, system.currencySymbol)
    XCTAssertEqual(map["countryCode"] as? String, system.regionCode)
  }

  func testSKStorefrontToMap() {
    if #available(iOS 13.0, *) {
      let storefront = SKStorefrontStub(map: storefrontMap)
      let map = FIAObjectTranslator.getMapFrom(storefront)

      XCTAssertEqual(map as NSDictionary, storefrontMap as NSDictionary)
    }
  }

  func testSKStorefrontAndSKPaymentTransactionToMap() {
    if #available(iOS 13.0, *) {
      let storefront = SKStorefrontStub(map: storefrontMap)
      let transaction = SKPaymentTransactionStub(map: transactionMap)
      let map = FIAObjectTranslator.getMapFrom(storefront, andSKPaymentTransaction: transaction)

      XCTAssertEqual(map as NSDictionary, storefrontAndPaymentTransactionMap as NSDictionary)
    }
  }

  func testSKPaymentDiscountFromMap() throws {
    if #available(iOS 12.2, *) {
      var error: NSString?
      let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(
        fromMap: paymentDiscountMap, withError: &error)

      XCTAssertNil(error)

      let unwrappedDiscount = try XCTUnwrap(paymentDiscount)
      let unwrappedNonce = try XCTUnwrap(paymentDiscountMap["nonce"] as? String)

      XCTAssertEqual(unwrappedDiscount.identifier, paymentDiscountMap["identifier"] as? String)
      XCTAssertEqual(
        unwrappedDiscount.keyIdentifier, paymentDiscountMap["keyIdentifier"] as? String)
      XCTAssertEqual(
        unwrappedDiscount.nonce, UUID(uuidString: unwrappedNonce))
      XCTAssertEqual(unwrappedDiscount.signature, paymentDiscountMap["signature"] as? String)
      XCTAssertEqual(unwrappedDiscount.timestamp as? Int, paymentDiscountMap["timestamp"] as? Int)
    }
  }

  func testSKPaymentDiscountFromMapMissingIdentifier() {
    if #available(iOS 12.2, *) {
      let invalidValues: [Any?] = [NSNull(), 1, ""]
      for value in invalidValues {
        let discountMap: [String: Any?] = [
          "identifier": value,
          "keyIdentifier": "payment_discount_key_identifier",
          "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
          "signature": "this is an encrypted signature",
          "timestamp": Int(Date().timeIntervalSince1970),
        ]
        var error: NSString?
        let _ = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: discountMap as [String: Any], withError: &error)

        XCTAssertNotNil(error)
        XCTAssertEqual(
          error, "When specifying a payment discount the 'identifier' field is mandatory.")
      }
    }
  }

  func testGetMapFromSKProductDiscountMissingIdentifier() {
    if #available(iOS 12.2, *) {
      let discount = SKProductDiscountStub(map: discountMissingIdentifierMap)
      let map = FIAObjectTranslator.getMapFrom(discount)

      XCTAssertEqual(map as NSDictionary, discountMissingIdentifierMap as NSDictionary)
    }
  }

  func testSKPaymentDiscountFromMapMissingKeyIdentifier() {
    if #available(iOS 12.2, *) {
      let invalidValues: [Any?] = [NSNull(), 1, ""]
      for value in invalidValues {
        let discountMap: [String: Any?] = [
          "identifier": "payment_discount_identifier",
          "keyIdentifier": value,
          "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
          "signature": "this is an encrypted signature",
          "timestamp": Int(Date().timeIntervalSince1970),
        ]
        var error: NSString?
        let _ = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: discountMap as [String: Any], withError: &error)

        XCTAssertNotNil(error)
        XCTAssertEqual(
          error, "When specifying a payment discount the 'keyIdentifier' field is mandatory.")
      }
    }
  }

  func testSKPaymentDiscountFromMapMissingNonce() {
    if #available(iOS 12.2, *) {
      let invalidValues: [Any?] = [NSNull(), 1, ""]
      for value in invalidValues {
        let discountMap: [String: Any?] = [
          "identifier": "payment_discount_identifier",
          "keyIdentifier": "payment_discount_key_identifier",
          "nonce": value,
          "signature": "this is an encrypted signature",
          "timestamp": Int(Date().timeIntervalSince1970),
        ]
        var error: NSString?
        let _ = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: discountMap as [String: Any], withError: &error)

        XCTAssertNotNil(error)
        XCTAssertEqual(error, "When specifying a payment discount the 'nonce' field is mandatory.")
      }
    }
  }

  func testSKPaymentDiscountFromMapMissingSignature() {
    if #available(iOS 12.2, *) {
      let invalidValues: [Any?] = [NSNull(), 1, ""]
      for value in invalidValues {
        let discountMap: [String: Any?] = [
          "identifier": "payment_discount_identifier",
          "keyIdentifier": "payment_discount_key_identifier",
          "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
          "signature": value,
          "timestamp": Int(Date().timeIntervalSince1970),
        ]
        var error: NSString?
        let _ = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: discountMap as [String: Any], withError: &error)

        XCTAssertNotNil(error)
        XCTAssertEqual(
          error, "When specifying a payment discount the 'signature' field is mandatory.")
      }
    }
  }

  func testSKPaymentDiscountFromMapMissingTimestamp() {
    if #available(iOS 12.2, *) {
      let invalidValues: [Any?] = [NSNull(), "", -1]
      for value in invalidValues {
        let discountMap: [String: Any?] = [
          "identifier": "payment_discount_identifier",
          "keyIdentifier": "payment_discount_key_identifier",
          "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
          "signature": "this is an encrypted signature",
          "timestamp": value,
        ]
        var error: NSString?
        let _ = FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: discountMap as [String: Any], withError: &error)

        XCTAssertNotNil(error)
        XCTAssertEqual(
          error, "When specifying a payment discount the 'timestamp' field is mandatory.")
      }
    }
  }

  func testSKPaymentDiscountFromMapOverflowingTimestamp() throws {
    if #available(iOS 12.2, *) {
      let discountMap: [String: Any] = [
        "identifier": "payment_discount_identifier",
        "keyIdentifier": "payment_discount_key_identifier",
        "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
        "signature": "this is an encrypted signature",
        "timestamp": 1_665_044_583_595,  // timestamp 2022 Oct
      ]
      var error: NSString?
      let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(
        fromMap: discountMap, withError: &error)
      XCTAssertNil(error)

      let unwrappedPaymentDiscount = try XCTUnwrap(paymentDiscount)
      let identifier = try XCTUnwrap(discountMap["identifier"] as? String)
      XCTAssertEqual(unwrappedPaymentDiscount.identifier, identifier)

      let keyIdentifier = try XCTUnwrap(discountMap["keyIdentifier"] as? String)
      XCTAssertEqual(unwrappedPaymentDiscount.keyIdentifier, keyIdentifier)

      let nonceString = try XCTUnwrap(discountMap["nonce"] as? String)
      let nonce = try XCTUnwrap(UUID(uuidString: nonceString))
      XCTAssertEqual(unwrappedPaymentDiscount.nonce, nonce)

      let signature = try XCTUnwrap(discountMap["signature"] as? String)
      XCTAssertEqual(unwrappedPaymentDiscount.signature, signature)

      let timestamp = try XCTUnwrap(discountMap["timestamp"] as? Int)
      XCTAssertEqual(unwrappedPaymentDiscount.timestamp as? Int, timestamp)
    }
  }

  func testSKPaymentDiscountConvertToPigeon() throws {
    if #available(iOS 12.2, *) {
      var error: NSString?
      let paymentDiscount = try XCTUnwrap(
        FIAObjectTranslator.getSKPaymentDiscount(
          fromMap: paymentDiscountMap, withError: &error))
      let paymentDiscountPigeon = try XCTUnwrap(
        FIAObjectTranslator.convertPaymentDiscount(
          toPigeon: paymentDiscount))

      XCTAssertNotNil(paymentDiscountPigeon)
      XCTAssertEqual(paymentDiscount.identifier, paymentDiscountPigeon.identifier)
      XCTAssertEqual(paymentDiscount.keyIdentifier, paymentDiscount.keyIdentifier)
      XCTAssertEqual(paymentDiscount.nonce, UUID(uuidString: paymentDiscountPigeon.nonce))
      XCTAssertEqual(paymentDiscount.signature, paymentDiscountPigeon.signature)

      let paymentDiscountTimestamp = paymentDiscount.timestamp as? Int
      let paymentDiscountPigeonTimestamp = paymentDiscountPigeon.timestamp

      XCTAssertEqual(paymentDiscountTimestamp, paymentDiscountPigeonTimestamp)
    }
  }

  func testSKErrorConvertToPigeon() throws {
    let error = NSError(domain: SKErrorDomain, code: 3, userInfo: ["key": 42])
    let msg = FIASKErrorMessage.make(
      withCode: 3, domain: SKErrorDomain, userInfo: ["key": 42] as [String: Any])
    let skerror = try XCTUnwrap(FIAObjectTranslator.convertSKError(toPigeon: error))

    XCTAssertEqual(skerror.domain, msg.domain)
    XCTAssertEqual(skerror.code, msg.code)

    let skerrorUserInfo = skerror.userInfo
    let msgUserInfo = try XCTUnwrap(msg.userInfo)

    XCTAssertEqual(skerrorUserInfo as NSDictionary?, msgUserInfo as NSDictionary)
  }

  func testSKPaymentConvertToPigeon() throws {
    if #available(iOS 12.2, *) {
      let payment = FIAObjectTranslator.getSKMutablePayment(fromMap: paymentMap)
      let msg = try XCTUnwrap(FIAObjectTranslator.convertPayment(toPigeon: payment))
      let msgRequestData = try XCTUnwrap(msg.requestData)

      XCTAssertEqual(payment.productIdentifier, msg.productIdentifier)
      XCTAssertEqual(payment.requestData, msgRequestData.data(using: .utf8))
      XCTAssertEqual(payment.quantity, msg.quantity)
      XCTAssertEqual(payment.applicationUsername, msg.applicationUsername)
      XCTAssertEqual(payment.simulatesAskToBuyInSandbox, msg.simulatesAskToBuyInSandbox)
    }
  }

  func testSKPaymentTransactionConvertToPigeon() throws {
    let paymentTransaction = SKPaymentTransactionStub(map: transactionMap)
    let msg = FIAObjectTranslator.convertTransaction(toPigeon: paymentTransaction)

    let unwrappedMsg = try XCTUnwrap(msg)
    let unwrappedTimeStamp = try XCTUnwrap(unwrappedMsg.transactionTimeStamp)

    XCTAssertEqual(unwrappedMsg.transactionState, FIASKPaymentTransactionStateMessage.purchasing)
    XCTAssertEqual(
      paymentTransaction.transactionDate,
      Date(timeIntervalSince1970: TimeInterval(truncating: unwrappedTimeStamp)))
    XCTAssertEqual(paymentTransaction.transactionIdentifier, unwrappedMsg.transactionIdentifier)
  }

  func testSKProductResponseCovertToPigeon() throws {
    let response = SKProductsResponseStub(map: productResponseMap)
    let responseMsg = FIAObjectTranslator.convertProductsResponse(toPigeon: response)
    let unwrappedMsg = try XCTUnwrap(responseMsg)

    let products = try XCTUnwrap(unwrappedMsg.products)
    XCTAssertEqual(products.count, 1)

    let invalidProductIdentifiers = try XCTUnwrap(unwrappedMsg.invalidProductIdentifiers)
    XCTAssertTrue(invalidProductIdentifiers.isEmpty)

    let productMsg = try XCTUnwrap(unwrappedMsg.products?.first)
    XCTAssertEqual(productMsg.productIdentifier, "123")
    XCTAssertEqual(productMsg.localizedTitle, "title")
    XCTAssertEqual(productMsg.localizedDescription, "des")
    XCTAssertEqual(productMsg.subscriptionGroupIdentifier, "com.group")

    let localeMsg = try XCTUnwrap(productMsg.priceLocale)
    XCTAssertEqual(localeMsg.countryCode, "")
    XCTAssertEqual(localeMsg.currencyCode, "")
    XCTAssertEqual(localeMsg.currencySymbol, "\u{00a4}")

    let subPeriod = try XCTUnwrap(productMsg.subscriptionPeriod)
    XCTAssertEqual(subPeriod.unit, FIASKSubscriptionPeriodUnitMessage.day)
    XCTAssertEqual(subPeriod.numberOfUnits, 0)

    let introDiscount = try XCTUnwrap(productMsg.introductoryPrice)
    XCTAssertEqual(introDiscount.price, "1")
    XCTAssertEqual(introDiscount.numberOfPeriods, 1)
    XCTAssertEqual(introDiscount.paymentMode, FIASKProductDiscountPaymentModeMessage.payUpFront)

    let discounts = try XCTUnwrap(productMsg.discounts)
    XCTAssertEqual(discounts.count, 1)
  }
}
