import Foundation
import StoreKit
import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

final class ObjectTranslatorTest: XCTestCase {

  typealias ProductDiscountType = SKProductDiscount.Type

  var periodMap: [String: Any] = [:]
  var discountMap: [String: Any] = [:]
  var discountMissingIdentifierMap: [String: Any] = [:]
  var productMap: [String: Any] = [:]
  var productResponseMap: [String: Any] = [:]
  var paymentMap: [String: Any] {
    [
      "productIdentifier": "123",
      "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
      "quantity": 2,
      "applicationUsername": "app user name",
      "simulatesAskToBuyInSandbox": false,
    ]
  }
  var paymentDiscountMap: [String: Any] = [:]
  var transactionMap: [String: Any] {
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
  var originalTransactionMap: [String: Any] {
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
  var errorMap: [String: Any] = [:]
  var localeMap: [String: Any] = [:]
  var storefrontMap: [String: Any] = [:]
  var storefrontAndPaymentTransactionMap: [String: Any] = [:]

  override func setUp() {
    super.setUp()

    periodMap = ["numberOfUnits": 0, "unit": 0]

    discountMap = [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
      "numberOfPeriods": 1,
      "subscriptionPeriod": periodMap,
      "paymentMode": 1,
    ]
    if #available(iOS 12.2, *) {
      discountMap["identifier"] = "test offer id"

      // Type is being instantiated like this because swift naming weirdness
      let type: SKProductDiscount.`Type` = .introductory
      discountMap["type"] = type.rawValue
    }

    discountMissingIdentifierMap = [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
      "numberOfPeriods": 1,
      "subscriptionPeriod": periodMap,
      "paymentMode": 1,
      "identifier": NSNull(),
      "type": 0,
    ]

    productMap = [
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
      productMap["discounts"] = [discountMap]
    }

    productResponseMap = ["products": [productMap], "invalidProductIdentifiers": []]
    paymentDiscountMap = [
      "identifier": "payment_discount_identifier",
      "keyIdentifier": "payment_discount_key_identifier",
      "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
      "signature": "this is an encrypted signature",
      "timestamp": Int(Date().timeIntervalSince1970),
    ]
    errorMap = [
      "code": 123,
      "domain": "test_domain",
      "userInfo": ["key": "value"],
    ]
    storefrontMap = [
      "countryCode": "USA",
      "identifier": "unique_identifier",
    ]

    storefrontAndPaymentTransactionMap = [
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
      // Unwrapping with XCTUnwrap
      let unwrappedDiscount = try XCTUnwrap(paymentDiscount)

      XCTAssertEqual(unwrappedDiscount.identifier, paymentDiscountMap["identifier"] as? String)
      XCTAssertEqual(
        unwrappedDiscount.keyIdentifier, paymentDiscountMap["keyIdentifier"] as? String)
      XCTAssertEqual(
        unwrappedDiscount.nonce, UUID(uuidString: paymentDiscountMap["nonce"] as! String))
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

  func testSKPaymentDiscountFromMapOverflowingTimestamp() {
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
      XCTAssertNotNil(paymentDiscount)
      XCTAssertEqual(paymentDiscount?.identifier, discountMap["identifier"] as? String)
      XCTAssertEqual(paymentDiscount?.keyIdentifier, discountMap["keyIdentifier"] as? String)
      XCTAssertEqual(paymentDiscount?.nonce, UUID(uuidString: discountMap["nonce"] as! String))
      XCTAssertEqual(paymentDiscount?.signature, discountMap["signature"] as? String)
      XCTAssertEqual(paymentDiscount?.timestamp as? Int, discountMap["timestamp"] as? Int)
    }
  }

  func testSKPaymentDiscountConvertToPigeon() {
    if #available(iOS 12.2, *) {
      var error: NSString?
      let paymentDiscount = FIAObjectTranslator.getSKPaymentDiscount(
        fromMap: paymentDiscountMap, withError: &error)
      let paymentDiscountPigeon = FIAObjectTranslator.convertPaymentDiscount(
        toPigeon: paymentDiscount)

      XCTAssertNotNil(paymentDiscountPigeon)
      XCTAssertEqual(paymentDiscount?.identifier, paymentDiscountPigeon?.identifier)
      XCTAssertEqual(paymentDiscount?.keyIdentifier, paymentDiscount?.keyIdentifier)
      XCTAssertEqual(paymentDiscount?.nonce, UUID(uuidString: paymentDiscountPigeon?.nonce ?? ""))
      XCTAssertEqual(paymentDiscount?.signature, paymentDiscountPigeon?.signature)
      let paymentDiscountTimestamp = paymentDiscount?.timestamp as? Int
      let paymentDiscountPigeonTimestamp = paymentDiscountPigeon?.timestamp as? Int
      XCTAssertEqual(paymentDiscountTimestamp, paymentDiscountPigeonTimestamp)
    }
  }

  func testSKErrorConvertToPigeon() {
    let error = NSError(domain: SKErrorDomain, code: 3, userInfo: ["key": 42])
    let msg = SKErrorMessage.make(
      withCode: 3, domain: SKErrorDomain, userInfo: ["key": 42] as [String: Any])
    let skerror = FIAObjectTranslator.convertSKError(toPigeon: error)

    XCTAssertEqual(skerror?.domain, msg.domain)
    XCTAssertEqual(skerror?.code, msg.code)

    let skerrorUserInfo = skerror?.userInfo as? [String: Any]
    let msgUserInfo = msg.userInfo! as [String: Any]

    XCTAssertEqual(skerrorUserInfo as NSDictionary?, msgUserInfo as NSDictionary)
  }

  func testSKPaymentConvertToPigeon() {
    if #available(iOS 12.2, *) {
      let payment = FIAObjectTranslator.getSKMutablePayment(fromMap: paymentMap)
      let msg = FIAObjectTranslator.convertPayment(toPigeon: payment)

      XCTAssertEqual(payment.productIdentifier, msg?.productIdentifier)
      XCTAssertEqual(payment.requestData, msg?.requestData?.data(using: .utf8))
      XCTAssertEqual(payment.quantity, msg?.quantity)
      XCTAssertEqual(payment.applicationUsername, msg?.applicationUsername)
      XCTAssertEqual(payment.simulatesAskToBuyInSandbox, msg?.simulatesAskToBuyInSandbox)
    }
  }

  func testSKPaymentTransactionConvertToPigeon() throws {
    let paymentTransaction = SKPaymentTransactionStub(map: transactionMap)
    let msg = FIAObjectTranslator.convertTransaction(toPigeon: paymentTransaction)

    let unwrappedMsg = try XCTUnwrap(msg)
    XCTAssertEqual(unwrappedMsg.transactionState, SKPaymentTransactionStateMessage.purchasing)
    XCTAssertEqual(
      paymentTransaction.transactionDate,
      Date(timeIntervalSince1970: TimeInterval(truncating: unwrappedMsg.transactionTimeStamp ?? 0)))
    XCTAssertEqual(paymentTransaction.transactionIdentifier, unwrappedMsg.transactionIdentifier)
  }

  func testSKProductResponseCovertToPigeon() throws {
    let response = SKProductsResponseStub(map: productResponseMap)
    let responseMsg = FIAObjectTranslator.convertProductsResponse(toPigeon: response)

    let unwrappedMsg = try XCTUnwrap(responseMsg)
    XCTAssertEqual(unwrappedMsg.products?.count, 1)
    let unwrappedInvalidProductIdentifiers = try XCTUnwrap(unwrappedMsg.invalidProductIdentifiers)
    XCTAssertTrue(unwrappedInvalidProductIdentifiers.isEmpty)

    let productMsg = try XCTUnwrap(unwrappedMsg.products?.first)

    // These values are being set in productResponseMap in setUp()
    XCTAssertEqual(productMsg.price, "1")
    XCTAssertEqual(productMsg.productIdentifier, "123")
    XCTAssertEqual(productMsg.localizedTitle, "title")
    XCTAssertEqual(productMsg.localizedDescription, "des")
    XCTAssertEqual(productMsg.subscriptionGroupIdentifier, "com.group")

    let localeMsg = productMsg.priceLocale
    let subPeriod = productMsg.subscriptionPeriod
    let introDiscount = productMsg.introductoryPrice
    let discounts = productMsg.discounts

    XCTAssertEqual(localeMsg.countryCode, "")
    XCTAssertEqual(localeMsg.currencyCode, "")
    XCTAssertEqual(localeMsg.currencySymbol, "\u{00a4}")

    XCTAssertEqual(subPeriod?.unit, SKSubscriptionPeriodUnitMessage.day)
    XCTAssertEqual(subPeriod?.numberOfUnits, 0)

    XCTAssertEqual(introDiscount?.price, "1")
    XCTAssertEqual(introDiscount?.numberOfPeriods, 1)
    XCTAssertEqual(introDiscount?.paymentMode, SKProductDiscountPaymentModeMessage.payUpFront)

    XCTAssertEqual(discounts?.count, 1)
  }

}
