import XCTest
import StoreKit
import StoreKitTest

@testable import in_app_purchase_storekit

class ObjectTranslatorTest: XCTestCase {

  typealias ProductDiscountType = SKProductDiscount.Type


    var periodMap: [String: Any] = [:]
  var discountMap: [String: Any] = [:]
    var discountMissingIdentifierMap: [String: Any] = [:]
    var productMap: [String: Any] = [:]
    var productResponseMap: [String: Any] = [:]
    var paymentMap: [String: Any] = [:]
    var paymentDiscountMap: [String: Any] = [:]
    var transactionMap: [String: Any] = [:]
    var errorMap: [String: Any] = [:]
    var localeMap: [String: Any]!
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
            "paymentMode": 1
        ]
      if #available(iOS 12.2, *) {
        discountMap["identifier"] = "test offer id"
        let type: SKProductDiscount.`Type` = .introductory
      }

        discountMissingIdentifierMap = [
            "price": "1",
            "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
            "numberOfPeriods": 1,
            "subscriptionPeriod": periodMap,
            "paymentMode": 1,
            "identifier": NSNull(),
            "type": 0
        ]

        productMap = [
            "price": "1",
            "priceLocale": FIAObjectTranslator.getMapFrom(NSLocale.system),
            "productIdentifier": "123",
            "localizedTitle": "title",
            "localizedDescription": "des",
            "subscriptionPeriod": periodMap,
            "introductoryPrice": discountMap,
            "subscriptionGroupIdentifier": "com.group"
        ]
        if #available(iOS 12.2, *) {
            productMap["discounts"] = [discountMap]
        }

        productResponseMap = ["products": [productMap], "invalidProductIdentifiers": []]
        paymentMap = [
            "productIdentifier": "123",
            "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
            "quantity": 2,
            "applicationUsername": "app user name",
            "simulatesAskToBuyInSandbox": false
        ]
        paymentDiscountMap = [
            "identifier": "payment_discount_identifier",
            "keyIdentifier": "payment_discount_key_identifier",
            "nonce": "d18981e0-9003-4365-98a2-4b90e3b62c52",
            "signature": "this is an encrypted signature",
            "timestamp": Date().timeIntervalSince1970
        ]
        let originalTransactionMap: [String: Any] = [
            "transactionIdentifier": "567",
            "transactionState": SKPaymentTransactionState.purchasing.rawValue,
            "payment": NSNull(),
            "error": FIAObjectTranslator.getMapFrom( NSError(domain: "test_stub", code: 123, userInfo: [:])),
            "transactionTimeStamp": Date().timeIntervalSince1970,
            "originalTransaction": NSNull()
        ]
        transactionMap = [
            "transactionIdentifier": "567",
            "transactionState": SKPaymentTransactionState.purchasing.rawValue,
            "payment": NSNull(),
            "error": FIAObjectTranslator.getMapFrom( NSError(domain: "test_stub", code: 123, userInfo: [:])),
            "transactionTimeStamp": Date().timeIntervalSince1970,
            "originalTransaction": originalTransactionMap
        ]
        errorMap = [
            "code": 123,
            "domain": "test_domain",
            "userInfo": ["key": "value"]
        ]
        storefrontMap = [
            "countryCode": "USA",
            "identifier": "unique_identifier"
        ]

        storefrontAndPaymentTransactionMap = [
            "storefront": storefrontMap,
            "transaction": transactionMap
        ]
    }

  func testSKProductSubscriptionPeriodStubToMap() {
      let period = SKProductSubscriptionPeriodStub(map: periodMap)
      let map = FIAObjectTranslator.getMapFrom(period)
      XCTAssertEqual(map as NSDictionary, periodMap as NSDictionary)
  }


}
