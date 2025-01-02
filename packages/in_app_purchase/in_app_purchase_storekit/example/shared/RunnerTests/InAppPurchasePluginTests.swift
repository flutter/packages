// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import StoreKitTest
import XCTest

@testable import in_app_purchase_storekit

final class InAppPurchasePluginTests: XCTestCase {
  var receiptManagerStub: FIAPReceiptManagerStub!
  var plugin: InAppPurchasePlugin!

  override func setUp() {
    super.setUp()
    receiptManagerStub = FIAPReceiptManagerStub()
    plugin = InAppPurchasePluginStub(receiptManager: receiptManagerStub) { request in
      DefaultRequestHandler(requestHandler: FIAPRequestHandler(request: request))
    }
  }

  override func tearDown() {
    receiptManagerStub = nil
    plugin = nil
    super.tearDown()
  }

  func testCanMakePayments() throws {
    var error: FlutterError?
    let result = plugin.canMakePaymentsWithError(&error)
    let unwrappedResult = try XCTUnwrap(result)
    XCTAssertTrue(unwrappedResult.boolValue)
    XCTAssertNil(error)
  }

  func testPaymentQueueStorefrontReturnsNil() throws {
    if #available(iOS 13, macOS 10.15, *) {
      let storefrontMap = [
        "countryCode": "USA",
        "identifier": "unique_identifier",
      ]
      let queueStub = PaymentQueueStub()
      let cache = TransactionCacheStub()

      queueStub.storefront = SKStorefrontStub(map: storefrontMap)

      plugin.paymentQueueHandler = FIAPaymentQueueHandler(
        queue: queueStub,
        transactionsUpdated: nil,
        transactionRemoved: nil,
        restoreTransactionFailed: nil,
        restoreCompletedTransactionsFinished: nil,
        shouldAddStorePayment: nil,
        updatedDownloads: nil,
        transactionCache: cache)

      var error: FlutterError?
      let result = plugin.storefrontWithError(&error)

      let unwrappedResult = try XCTUnwrap(result)
      XCTAssertEqual(unwrappedResult.countryCode, storefrontMap["countryCode"])
      XCTAssertEqual(unwrappedResult.identifier, storefrontMap["identifier"])
      XCTAssertNil(error)
    } else {
      print("Skip testPaymentQueueStorefront for iOS lower than 13.0 or macOS lower than 10.15.")
    }
  }
  func testGetProductResponse() {
    let argument = ["123"]
    let expectation = self.expectation(description: "completion handler successfully called")

    plugin.startProductRequestProductIdentifiers(argument) { response, startProductRequestError in
      guard let response = response else {
        XCTFail("Response should not be nil")
        return
      }

      guard let unwrappedProducts = response.products else {
        XCTFail("Products should not be nil")
        return
      }

      XCTAssertEqual(unwrappedProducts.count, 1)
      XCTAssertEqual(response.invalidProductIdentifiers, [])
      XCTAssertEqual(unwrappedProducts[0].productIdentifier, "123")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFinishTransactionSucceedsWithNilTransaction() {
    let args: [String: Any] = [
      "transactionIdentifier": NSNull(),
      "productIdentifier": "unique_identifier",
    ]

    let paymentMap: [String: Any] = [
      "productIdentifier": "123",
      "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
      "quantity": 2,
      "applicationUsername": "app user name",
      "simulatesAskToBuyInSandbox": false,
    ]

    let transactionMap: [String: Any] = [
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": paymentMap,
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": NSDate().timeIntervalSince1970,
    ]

    let paymentTransactionStub = SKPaymentTransactionStub(map: transactionMap)

    let queueStub = PaymentQueueStub()
    queueStub.transactions = [paymentTransactionStub]

    let cache = TransactionCacheStub()

    plugin.paymentQueueHandler = FIAPaymentQueueHandler(
      queue: queueStub,
      transactionsUpdated: nil,
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: nil,
      updatedDownloads: nil,
      transactionCache: cache)

    var error: FlutterError?
    plugin.finishTransactionFinishMap(args, error: &error)

    XCTAssertNil(error)
  }

  func testFinishTransactionNotCalledOnPurchasingTransactions() {
    let args: [String: Any] = [
      "transactionIdentifier": NSNull(),
      "productIdentifier": "unique_identifier",
    ]

    let paymentMap: [String: Any] = [
      "productIdentifier": "123",
      "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
      "quantity": 2,
      "applicationUsername": "app user name",
      "simulatesAskToBuyInSandbox": false,
    ]

    let transactionMap: [String: Any] = [
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": paymentMap,
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": NSDate().timeIntervalSince1970,
    ]

    let paymentTransactionStub = SKPaymentTransactionStub(map: transactionMap)

    let handler = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handler

    var finishTransactionInvokeCount = 0

    handler.finishTransactionStub = { _ in
      finishTransactionInvokeCount += 1
    }

    var error: FlutterError?
    plugin.finishTransactionFinishMap(args, error: &error)

    XCTAssertNil(error)
    XCTAssertEqual(finishTransactionInvokeCount, 0)
  }

  func testGetProductResponseWithRequestError() {
    let argument = ["123"]
    let expectation = self.expectation(description: "completion handler successfully called")

    let handlerStub = RequestHandlerStub()
    let plugin = InAppPurchasePlugin(receiptManager: receiptManagerStub) { request in
      return handlerStub
    }

    let error = NSError(
      domain: "errorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "description"])

    handlerStub.startProductRequestWithCompletionHandlerStub = { completion in
      completion(nil, error)
    }

    plugin.startProductRequestProductIdentifiers(argument) { response, startProductRequestError in
      expectation.fulfill()
      XCTAssertNotNil(error)
      XCTAssertNotNil(startProductRequestError)
      XCTAssertEqual(startProductRequestError?.code, "storekit_getproductrequest_platform_error")
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testGetProductResponseWithNoResponse() {
    let argument = ["123"]
    let expectation = self.expectation(description: "completion handler successfully called")

    let handlerStub = RequestHandlerStub()
    let plugin = InAppPurchasePlugin(receiptManager: receiptManagerStub) { request in
      return handlerStub
    }

    let error = NSError(
      domain: "errorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "description"])

    handlerStub.startProductRequestWithCompletionHandlerStub = { completion in
      completion(nil, nil)
    }

    plugin.startProductRequestProductIdentifiers(argument) { response, startProductRequestError in
      expectation.fulfill()
      XCTAssertNotNil(error)
      XCTAssertNotNil(startProductRequestError)
      XCTAssertEqual(startProductRequestError?.code, "storekit_platform_no_response")
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testAddPaymentShouldReturnFlutterErrorWhenPaymentFails() {
    let argument: [String: Any] = [
      "productIdentifier": "123",
      "quantity": 1,
      "simulatesAskToBuyInSandbox": true,
    ]

    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub

    var error: FlutterError?

    var addPaymentInvokeCount = 0
    handlerStub.addPaymentStub = { payment in
      addPaymentInvokeCount += 1
      return false
    }

    plugin.addPaymentPaymentMap(argument, error: &error)

    XCTAssertEqual(addPaymentInvokeCount, 1)

    guard let error = error else {
      XCTFail("Error should not be nil")
      return
    }

    XCTAssertEqual(error.code, "storekit_duplicate_product_object")
    XCTAssertEqual(
      error.message,
      "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases."
    )
    XCTAssertEqual(error.details as! NSDictionary, argument as NSDictionary)
  }

  func testAddPaymentShouldReturnFlutterErrorWhenInvalidProduct() {
    let argument: [String: Any] = [
      // stubbed function will return nil for an empty productIdentifier
      "productIdentifier": "",
      "quantity": 1,
      "simulatesAskToBuyInSandbox": true,
    ]

    var error: FlutterError?
    plugin.addPaymentPaymentMap(argument, error: &error)

    guard let error = error else {
      XCTFail("Error should not be nil")
      return
    }

    XCTAssertEqual(error.code, "storekit_invalid_payment_object")
    XCTAssertEqual(
      error.message,
      "You have requested a payment for an invalid product. Either the `productIdentifier` of the payment is not valid or the product has not been fetched before adding the payment to the payment queue."
    )
    XCTAssertEqual(error.details as! NSDictionary, argument as NSDictionary)
  }

  func testAddPaymentSuccessWithoutPaymentDiscount() {
    let argument: [String: Any] = [
      "productIdentifier": "123",
      "quantity": 1,
      "simulatesAskToBuyInSandbox": true,
    ]

    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub

    var error: FlutterError?

    var addPaymentInvokeCount = 0
    handlerStub.addPaymentStub = { payment in
      XCTAssertNotNil(payment)
      XCTAssertEqual(payment.productIdentifier, "123")
      XCTAssertEqual(payment.quantity, 1)
      addPaymentInvokeCount += 1
      return false
    }

    plugin.addPaymentPaymentMap(argument, error: &error)

    XCTAssertEqual(addPaymentInvokeCount, 1)

    guard let error = error else {
      XCTFail("Error should not be nil")
      return
    }

    XCTAssertEqual(error.code, "storekit_duplicate_product_object")
    XCTAssertEqual(
      error.message,
      "There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases."
    )
    XCTAssertEqual(error.details as! NSDictionary, argument as NSDictionary)
  }

  func testAddPaymentSuccessWithPaymentDiscount() {
    let argument: [String: Any] = [
      "productIdentifier": "123",
      "quantity": 1,
      "simulatesAskToBuyInSandbox": true,
      "paymentDiscount": [
        "identifier": "test_identifier",
        "keyIdentifier": "test_key_identifier",
        "nonce": "4a11a9cc-3bc3-11ec-8d3d-0242ac130003",
        "signature": "test_signature",
        "timestamp": 1_635_847_102,
      ],
    ]

    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub

    var addPaymentInvokeCount = 0
    handlerStub.addPaymentStub = { payment in
      if #available(iOS 12.2, *) {
        guard let discount = payment.paymentDiscount else {
          XCTFail("Discount should not be nil")
          return false
        }
        XCTAssertEqual(discount.identifier, "test_identifier")
        XCTAssertEqual(discount.keyIdentifier, "test_key_identifier")
        XCTAssertEqual(discount.nonce, UUID(uuidString: "4a11a9cc-3bc3-11ec-8d3d-0242ac130003"))
        XCTAssertEqual(discount.signature, "test_signature")
        XCTAssertEqual(discount.timestamp, 1_635_847_102)
        addPaymentInvokeCount += 1
        return true
      } else {
        addPaymentInvokeCount += 1
        return true
      }
    }

    var error: FlutterError?

    plugin.addPaymentPaymentMap(argument, error: &error)
    XCTAssertEqual(addPaymentInvokeCount, 1)
    XCTAssertNil(error)
  }

  func testAddPaymentFailureWithInvalidPaymentDiscount() {
    if #available(iOS 12.2, *) {
      let invalidDiscount: [String: Any] = [
        "productIdentifier": "123",
        "quantity": 1,
        "simulatesAskToBuyInSandbox": true,
        "paymentDiscount": [
          // This payment discount is missing the field `identifier`, and is thus malformed
          "keyIdentifier": "test_key_identifier",
          "nonce": "4a11a9cc-3bc3-11ec-8d3d-0242ac130003",
          "signature": "test_signature",
          "timestamp": 1_635_847_102,
        ],
      ]

      let handlerStub = PaymentQueueHandlerStub()

      var addPaymentCount = 0
      handlerStub.addPaymentStub = { payment in
        addPaymentCount += 1
        return true
      }

      plugin.paymentQueueHandler = handlerStub
      var error: FlutterError?

      plugin.addPaymentPaymentMap(invalidDiscount, error: &error)

      guard let error = error else {
        XCTFail("Error should not be nil")
        return
      }

      XCTAssertEqual(error.code, "storekit_invalid_payment_discount_object")
      XCTAssertEqual(
        error.message,
        "You have requested a payment and specified a payment discount with invalid properties. When specifying a payment discount the 'identifier' field is mandatory."
      )
      XCTAssertEqual(error.details as! NSDictionary, invalidDiscount as NSDictionary)
      XCTAssertEqual(addPaymentCount, 0)
    }
  }

  func testAddPaymentWithNullSandboxArgument() {
    let argument: [String: Any] = [
      "productIdentifier": "123",
      "quantity": 1,
      "simulatesAskToBuyInSandbox": NSNull(),
    ]

    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub
    var error: FlutterError?

    var addPaymentInvokeCount = 0
    handlerStub.addPaymentStub = { payment in
      XCTAssertEqual(payment.simulatesAskToBuyInSandbox, false)
      addPaymentInvokeCount += 1
      return true
    }

    plugin.addPaymentPaymentMap(argument, error: &error)
    XCTAssertEqual(addPaymentInvokeCount, 1)
  }

  func testRestoreTransactions() {
    let expectation = self.expectation(description: "result successfully restore transactions")

    let cacheStub = TransactionCacheStub()
    let queueStub = PaymentQueueStub()

    var callbackInvoked = false
    plugin.paymentQueueHandler = FIAPaymentQueueHandler(
      queue: queueStub,
      transactionsUpdated: { transactions in },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: {
        callbackInvoked = true
        expectation.fulfill()
      },
      shouldAddStorePayment: nil,
      updatedDownloads: nil,
      transactionCache: cacheStub)
    queueStub.add(plugin.paymentQueueHandler!)

    var error: FlutterError?
    plugin.restoreTransactionsApplicationUserName(nil, error: &error)

    waitForExpectations(timeout: 5, handler: nil)
    XCTAssertTrue(callbackInvoked)
  }

  func testRetrieveReceiptDataSuccess() {
    var error: FlutterError?
    let result = plugin.retrieveReceiptDataWithError(&error)
    XCTAssertNotNil(result)
  }

  func testRetrieveReceiptDataNil() {
    receiptManagerStub.returnNilURL = true

    var error: FlutterError?
    let result = plugin.retrieveReceiptDataWithError(&error)
    XCTAssertNil(result)
  }

  func testRetrieveReceiptDataError() {
    receiptManagerStub.returnError = true
    var error: FlutterError?
    let result = plugin.retrieveReceiptDataWithError(&error)

    XCTAssertNil(result)
    XCTAssertNotNil(error)

    guard let error = error else {
      XCTFail("Error should not be nil")
      return
    }

    guard let details = error.details as? [String: Any],
      let errorDetails = details["error"] as? [String: Any],
      let errorCode = errorDetails["code"] as? NSNumber
    else {
      XCTFail("Error details are not in the correct format")
      return
    }

    XCTAssertEqual(errorCode, 99)
  }

  func testRefreshReceiptRequest() {
    let expectation = self.expectation(description: "completion handler successfully called")

    let handlerStub = RequestHandlerStub()
    let plugin = InAppPurchasePlugin(receiptManager: receiptManagerStub) { request in
      return handlerStub
    }

    let receiptError = NSError(
      domain: "errorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "description"])

    handlerStub.startProductRequestWithCompletionHandlerStub = { completion in
      completion(nil, receiptError)
    }

    plugin.refreshReceiptReceiptProperties(nil) { error in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testRefreshReceiptRequestWithParams() {
    let properties = [
      "isExpired": false,
      "isRevoked": false,
      "isVolumePurchase": false,
    ]
    let expectation = self.expectation(description: "completion handler successfully called")

    let handlerStub = RequestHandlerStub()
    let plugin = InAppPurchasePlugin(receiptManager: receiptManagerStub) { request in
      return handlerStub
    }

    let receiptError = NSError(
      domain: "errorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "description"])

    handlerStub.startProductRequestWithCompletionHandlerStub = { completion in
      completion(nil, receiptError)
    }

    plugin.refreshReceiptReceiptProperties(properties) { error in
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testRefreshReceiptRequestWithError() {
    let properties: [String: Any] = [
      "isExpired": false,
      "isRevoked": false,
      "isVolumePurchase": false,
    ]

    let expectation = self.expectation(description: "completion handler successfully called")

    let handlerStub = RequestHandlerStub()
    let plugin = InAppPurchasePlugin(receiptManager: receiptManagerStub) { request in
      return handlerStub
    }

    let receiptError = NSError(
      domain: "errorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "description"])

    handlerStub.startProductRequestWithCompletionHandlerStub = { completion in
      completion(nil, receiptError)
    }

    plugin.refreshReceiptReceiptProperties(properties) { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "storekit_refreshreceiptrequest_platform_error")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  #if os(iOS)
    func testPresentCodeRedemptionSheet() {
      let handlerStub = PaymentQueueHandlerStub()
      plugin.paymentQueueHandler = handlerStub

      var presentCodeRedemptionSheetCount = 0
      handlerStub.presentCodeRedemptionSheetStub = {
        presentCodeRedemptionSheetCount += 1
      }

      var error: FlutterError?
      plugin.presentCodeRedemptionSheetWithError(&error)

      XCTAssertEqual(presentCodeRedemptionSheetCount, 1)
    }
  #endif

  func testGetPendingTransactions() {
    let queueStub = PaymentQueueStub()
    let cacheStub = TransactionCacheStub()
    let transactionMap: [String: Any] = [
      "transactionIdentifier": "567",
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": NSDate().timeIntervalSince1970,
      "originalTransaction": NSNull(),
    ]
    queueStub.transactions = [SKPaymentTransactionStub(map: transactionMap)]
    plugin.paymentQueueHandler = FIAPaymentQueueHandler(
      queue: queueStub,
      transactionsUpdated: nil,
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: nil,
      updatedDownloads: nil,
      transactionCache: cacheStub)

    var error: FlutterError?
    let original = SKPaymentTransactionStub(map: transactionMap)
    let originalPigeon = FIAObjectTranslator.convertTransaction(toPigeon: original)

    guard let result = plugin.transactionsWithError(&error)?.first else {
      XCTFail("Expected a transaction but got nil")
      return
    }
    XCTAssertEqual(result.payment, originalPigeon?.payment)
    XCTAssertEqual(result.transactionIdentifier, originalPigeon?.transactionIdentifier)
    XCTAssertEqual(result.transactionState, originalPigeon?.transactionState)
    XCTAssertEqual(result.transactionTimeStamp, originalPigeon?.transactionTimeStamp)
    XCTAssertEqual(result.originalTransaction, originalPigeon?.originalTransaction)
    XCTAssertEqual(result.error?.domain, originalPigeon?.error?.domain)
    XCTAssertEqual(result.error?.code, originalPigeon?.error?.code)
  }

  func testStartObservingPaymentQueue() {
    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub

    var startObservingCount = 0
    handlerStub.startObservingPaymentQueueStub = {
      startObservingCount += 1
    }

    var error: FlutterError?
    plugin.startObservingPaymentQueueWithError(&error)

    XCTAssertEqual(startObservingCount, 1)
  }

  func testStopObservingPaymentQueue() {
    let handlerStub = PaymentQueueHandlerStub()
    plugin.paymentQueueHandler = handlerStub

    var stopObservingCount = 0
    handlerStub.stopObservingPaymentQueueStub = {
      stopObservingCount += 1
    }

    var error: FlutterError?
    plugin.stopObservingPaymentQueueWithError(&error)

    XCTAssertEqual(stopObservingCount, 1)
  }

  #if os(iOS)
    func testRegisterPaymentQueueDelegate() {
      let cacheStub = TransactionCacheStub()
      let queueStub = PaymentQueueStub()

      if #available(iOS 13, *) {
        plugin.paymentQueueHandler = FIAPaymentQueueHandler(
          queue: queueStub,
          transactionsUpdated: nil,
          transactionRemoved: nil,
          restoreTransactionFailed: nil,
          restoreCompletedTransactionsFinished: nil,
          shouldAddStorePayment: nil,
          updatedDownloads: nil,
          transactionCache: cacheStub)

        plugin.registrar = FlutterPluginRegistrarStub()

        // Verify the delegate is nil before we register one.
        XCTAssertNil(plugin.paymentQueueHandler?.delegate)

        var error: FlutterError?
        plugin.registerPaymentQueueDelegateWithError(&error)

        // Verify the delegate is not nil after we registered one.
        XCTAssertNotNil(plugin.paymentQueueHandler?.delegate)
      }
    }

    func testRemovePaymentQueueDelegate() {
      if #available(iOS 13, *) {
        let cacheStub = TransactionCacheStub()
        let queueStub = PaymentQueueStub()

        plugin.paymentQueueHandler = FIAPaymentQueueHandler(
          queue: queueStub,
          transactionsUpdated: nil,
          transactionRemoved: nil,
          restoreTransactionFailed: nil,
          restoreCompletedTransactionsFinished: nil,
          shouldAddStorePayment: nil,
          updatedDownloads: nil,
          transactionCache: cacheStub)

        plugin.registrar = FlutterPluginRegistrarStub()

        // Verify the delegate is nil before we register one.
        XCTAssertNil(plugin.paymentQueueHandler?.delegate)

        var error: FlutterError?
        plugin.registerPaymentQueueDelegateWithError(&error)

        // Verify the delegate is not nil before removing it.
        XCTAssertNotNil(plugin.paymentQueueHandler?.delegate)

        plugin.removePaymentQueueDelegateWithError(&error)

        // Verify the delegate is nil after removing it.
        XCTAssertNil(plugin.paymentQueueHandler?.delegate)
      }
    }
  #endif

  func testHandleTransactionsUpdated() {
    let transactionMap: [String: Any] = [
      "transactionIdentifier": "567",
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": NSDate().timeIntervalSince1970,
    ]

    let channelStub = MethodChannelStub()
    var invokeMethodCount = 0

    channelStub.invokeMethodChannelStub = { method, arguments in
      XCTAssertEqual(method, "updatedTransactions")
      XCTAssertNotNil(arguments)
      invokeMethodCount += 1
    }

    let plugin = InAppPurchasePlugin(
      receiptManager: receiptManagerStub, transactionCallbackChannel: channelStub)

    let paymentTransactionStub = SKPaymentTransactionStub(map: transactionMap)
    let array = [paymentTransactionStub]

    plugin.handleTransactionsUpdated(array)
    XCTAssertEqual(invokeMethodCount, 1)
  }

  func testHandleTransactionsRemoved() {
    let transactionMap: [String: Any] = [
      "transactionIdentifier": "567",
      "transactionState": SKPaymentTransactionState.purchasing.rawValue,
      "payment": NSNull(),
      "error": FIAObjectTranslator.getMapFrom(
        NSError(domain: "test_stub", code: 123, userInfo: [:])),
      "transactionTimeStamp": NSDate().timeIntervalSince1970,
    ]

    let paymentTransactionStub = SKPaymentTransactionStub(map: transactionMap)
    let array = [paymentTransactionStub]
    let maps = [FIAObjectTranslator.getMapFrom(paymentTransactionStub)]

    let channelStub = MethodChannelStub()
    var invokeMethodCount = 0

    channelStub.invokeMethodChannelStub = { method, arguments in
      XCTAssertEqual(method, "removedTransactions")
      XCTAssertEqual(arguments as! NSObject, maps as NSObject)
      invokeMethodCount += 1
    }

    let plugin = InAppPurchasePlugin(
      receiptManager: receiptManagerStub, transactionCallbackChannel: channelStub)

    plugin.handleTransactionsRemoved(array)
    XCTAssertEqual(invokeMethodCount, 1)
  }

  func testHandleTransactionRestoreFailed() {
    let channelStub = MethodChannelStub()
    var invokeMethodCount = 0
    let error = NSError(domain: "error", code: 0, userInfo: nil)

    channelStub.invokeMethodChannelStub = { method, arguments in
      XCTAssertEqual(method, "restoreCompletedTransactionsFailed")
      XCTAssertEqual(arguments as! NSObject, FIAObjectTranslator.getMapFrom(error) as NSObject)
      invokeMethodCount += 1
    }

    let plugin = InAppPurchasePlugin(
      receiptManager: receiptManagerStub, transactionCallbackChannel: channelStub)

    plugin.handleTransactionRestoreFailed(error)
    XCTAssertEqual(invokeMethodCount, 1)
  }

  func testRestoreCompletedTransactionsFinished() {
    let channelStub = MethodChannelStub()
    var invokeMethodCount = 0

    channelStub.invokeMethodChannelStub = { method, arguments in
      XCTAssertEqual(method, "paymentQueueRestoreCompletedTransactionsFinished")
      XCTAssertNil(arguments)
      invokeMethodCount += 1
    }

    let plugin = InAppPurchasePlugin(
      receiptManager: receiptManagerStub, transactionCallbackChannel: channelStub)

    plugin.restoreCompletedTransactionsFinished()
    XCTAssertEqual(invokeMethodCount, 1)
  }

  func testShouldAddStorePayment() {
    let paymentMap: [String: Any] = [
      "productIdentifier": "123",
      "requestData": "abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
      "quantity": 2,
      "applicationUsername": "app user name",
      "simulatesAskToBuyInSandbox": false,
    ]

    let productMap: [String: Any] = [
      "price": "1",
      "priceLocale": FIAObjectTranslator.getMapFrom(Locale.current),
      "productIdentifier": "123",
      "localizedTitle": "title",
      "localizedDescription": "des",
    ]

    let payment = FIAObjectTranslator.getSKMutablePayment(fromMap: paymentMap)
    let productStub = SKProductStub(map: productMap)

    let args: [String: Any] = [
      "payment": FIAObjectTranslator.getMapFrom(payment),
      "product": FIAObjectTranslator.getMapFrom(productStub),
    ]

    let channelStub = MethodChannelStub()

    var invokeMethodCount = 0
    channelStub.invokeMethodChannelStub = { method, arguments in
      XCTAssertEqual(method, "shouldAddStorePayment")
      XCTAssertEqual(arguments as! NSObject, args as NSObject)
      invokeMethodCount += 1
    }

    let plugin = InAppPurchasePlugin(
      receiptManager: receiptManagerStub, transactionCallbackChannel: channelStub)

    let result = plugin.shouldAddStorePayment(payment: payment, product: productStub)
    XCTAssertEqual(result, false)
    XCTAssertEqual(invokeMethodCount, 1)
  }
  #if os(iOS)
    func testShowPriceConsentIfNeeded() {
      let cacheStub = TransactionCacheStub()
      let queueStub = PaymentQueueStub()
      plugin.paymentQueueHandler = FIAPaymentQueueHandler(
        queue: queueStub,
        transactionsUpdated: nil,
        transactionRemoved: nil,
        restoreTransactionFailed: nil,
        restoreCompletedTransactionsFinished: nil,
        shouldAddStorePayment: nil,
        updatedDownloads: nil,
        transactionCache: cacheStub)

      var error: FlutterError?
      var showPriceConsentIfNeededCount = 0

      queueStub.showPriceConsentIfNeededStub = {
        showPriceConsentIfNeededCount += 1
      }

      plugin.showPriceConsentIfNeededWithError(&error)

      if #available(iOS 13.4, *) {
        XCTAssertEqual(showPriceConsentIfNeededCount, 1)
      } else {
        XCTAssertEqual(showPriceConsentIfNeededCount, 0)
      }
    }
  #endif
}
