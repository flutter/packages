// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import StoreKit
import XCTest

@testable import in_app_purchase_storekit

final class PaymentQueueTest: XCTestCase {
  private var periodMap: [String: Any] {
    return ["numberOfUnits": 0, "unit": 0]
  }
  private var discountMap: [String: Any] {
    return [
      "price": 1.0,
      "currencyCode": "USD",
      "numberOfPeriods": 1,
      "subscriptionPeriod": periodMap,
      "paymentMode": 1,
    ]
  }
  private var productMap: [String: Any] {
    return [
      "price": 1.0,
      "currencyCode": "USD",
      "productIdentifier": "123",
      "localizedTitle": "title",
      "localizedDescription": "des",
      "subscriptionPeriod": periodMap,
      "introductoryPrice": discountMap,
      "subscriptionGroupIdentifier": "com.group",
    ]
  }
  private var productResponseMap: [String: Any] {
    return ["products": [productMap], "invalidProductIdentifiers": []]
  }

  func testTransactionPurchased() throws {
    let expectation = self.expectation(description: "expect to get purchased transaction.")
    let queue = PaymentQueueStub()
    queue.testState = .purchased
    var transactionStub: SKPaymentTransactionStub?
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        let transaction = transactions[0]
        transactionStub = transaction as? SKPaymentTransactionStub
        expectation.fulfill()
      },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)
    waitForExpectations(timeout: 5)

    let unwrappedTransaction = try XCTUnwrap(transactionStub)
    XCTAssertEqual(unwrappedTransaction.transactionState, .purchased)
    XCTAssertEqual(unwrappedTransaction.transactionIdentifier, "fakeID")
  }

  func testTransactionFailed() throws {
    let expectation = self.expectation(description: "expect to get failed transaction.")
    let queue = PaymentQueueStub()
    queue.testState = .failed
    var transactionStub: SKPaymentTransactionStub?
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        let transaction = transactions[0]
        transactionStub = transaction as? SKPaymentTransactionStub
        expectation.fulfill()
      },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)
    waitForExpectations(timeout: 5)

    let unwrappedTransaction = try XCTUnwrap(transactionStub)
    XCTAssertEqual(unwrappedTransaction.transactionState, .failed)
    XCTAssertEqual(unwrappedTransaction.transactionIdentifier, nil)
  }

  func testTransactionRestored() throws {
    let expectation = self.expectation(description: "expect to get restored transaction.")
    let queue = PaymentQueueStub()
    queue.testState = .restored
    var transactionStub: SKPaymentTransactionStub?
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        let transaction = transactions[0]
        transactionStub = transaction as? SKPaymentTransactionStub
        expectation.fulfill()
      },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)
    waitForExpectations(timeout: 5)

    let unwrappedTransaction = try XCTUnwrap(transactionStub)
    XCTAssertEqual(unwrappedTransaction.transactionState, .restored)
    XCTAssertEqual(unwrappedTransaction.transactionIdentifier, "fakeID")
  }

  func testTransactionPurchasing() throws {
    let expectation = self.expectation(description: "expect to get purchasing transaction.")
    let queue = PaymentQueueStub()
    queue.testState = .purchasing
    var transactionStub: SKPaymentTransactionStub?
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        let transaction = transactions[0]
        transactionStub = transaction as? SKPaymentTransactionStub
        expectation.fulfill()
      },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)
    waitForExpectations(timeout: 5)

    let unwrappedTransaction = try XCTUnwrap(transactionStub)
    XCTAssertEqual(unwrappedTransaction.transactionState, .purchasing)
    XCTAssertEqual(unwrappedTransaction.transactionIdentifier, nil)
  }

  func testTransactionDeferred() throws {
    let expectation = self.expectation(description: "expect to get deferred transaction.")
    let queue = PaymentQueueStub()
    queue.testState = .deferred
    var transactionStub: SKPaymentTransactionStub?
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        let transaction = transactions[0]
        transactionStub = transaction as? SKPaymentTransactionStub
        expectation.fulfill()
      },
      transactionRemoved: nil,
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)
    waitForExpectations(timeout: 5)

    let unwrappedTransaction = try XCTUnwrap(transactionStub)
    XCTAssertEqual(unwrappedTransaction.transactionState, .deferred)
    XCTAssertEqual(unwrappedTransaction.transactionIdentifier, nil)
  }

  func testFinishTransaction() {
    let expectation = self.expectation(description: "handler.transactions should be empty.")
    let queue = PaymentQueueStub()
    queue.testState = .deferred
    var handler: FIAPaymentQueueHandler!
    handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        XCTAssertEqual(transactions.count, 1)
        let transaction = transactions[0]
        handler.finish(transaction)
      },
      transactionRemoved: { transactions in
        XCTAssertEqual(transactions.count, 1)
        expectation.fulfill()
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: nil,
      transactionCache: TransactionCacheStub())
    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    handler.startObservingPaymentQueue()
    handler.add(payment)

    waitForExpectations(timeout: 5)
  }

  func testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheIsEmpty() {
    let cacheStub = TransactionCacheStub()
    let handler = FIAPaymentQueueHandler(
      queue: PaymentQueueStub(),
      transactionsUpdated: { _ in
        XCTFail("transactionsUpdated callback should not be called when cache is empty.")
      },
      transactionRemoved: { _ in
        XCTFail("transactionRemoved callback should not be called when cache is empty.")
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: { _ in
        XCTFail("updatedDownloads callback should not be called when cache is empty.")
      },
      transactionCache: cacheStub)

    var transactionCacheKeyUpdatedTransactionsInvokedCount = 0
    var transactionCacheKeyUpdatedDownloadsInvokedCount = 0
    var transactionCacheKeyRemovedTransactionsInvokedCount = 0

    cacheStub.getObjectsForKeyStub = { key in
      switch key {
      case .updatedTransactions:
        transactionCacheKeyUpdatedTransactionsInvokedCount += 1
      case .updatedDownloads:
        transactionCacheKeyUpdatedDownloadsInvokedCount += 1
      case .removedTransactions:
        transactionCacheKeyRemovedTransactionsInvokedCount += 1
      default:
        XCTFail("Invalid transaction state was invoked.")
      }
      return []
    }

    handler.startObservingPaymentQueue()

    XCTAssertEqual(transactionCacheKeyUpdatedTransactionsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyUpdatedDownloadsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyRemovedTransactionsInvokedCount, 1)
  }

  func
    testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheContainsEmptyTransactionArrays()
  {
    let cacheStub = TransactionCacheStub()
    let handler = FIAPaymentQueueHandler(
      queue: PaymentQueueStub(),
      transactionsUpdated: { _ in
        XCTFail("transactionsUpdated callback should not be called when cache is empty.")
      },
      transactionRemoved: { _ in
        XCTFail("transactionRemoved callback should not be called when cache is empty.")
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: { _ in
        XCTFail("updatedDownloads callback should not be called when cache is empty.")
      },
      transactionCache: cacheStub)

    var transactionCacheKeyUpdatedTransactionsInvokedCount = 0
    var transactionCacheKeyUpdatedDownloadsInvokedCount = 0
    var transactionCacheKeyRemovedTransactionsInvokedCount = 0

    cacheStub.getObjectsForKeyStub = { key in
      switch key {
      case .updatedTransactions:
        transactionCacheKeyUpdatedTransactionsInvokedCount += 1
        return []
      case .updatedDownloads:
        transactionCacheKeyUpdatedDownloadsInvokedCount += 1
        return []
      case .removedTransactions:
        transactionCacheKeyRemovedTransactionsInvokedCount += 1
        return []
      default:
        XCTFail("Invalid transaction state was invoked.")
      }
      return []
    }

    handler.startObservingPaymentQueue()

    XCTAssertEqual(transactionCacheKeyUpdatedTransactionsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyUpdatedDownloadsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyRemovedTransactionsInvokedCount, 1)
  }

  func testStartObservingPaymentQueueShouldProcessTransactionsForItemsInCache() {
    let updateTransactionsExpectation = expectation(
      description: "transactionsUpdated callback should be called with one transaction.")
    let removeTransactionsExpectation = expectation(
      description: "transactionsRemoved callback should be called with one transaction.")
    let updateDownloadsExpectation = expectation(
      description: "downloadsUpdated callback should be called with one transaction.")
    let transactionStub = SKPaymentTransactionStub()
    let downloadStub = SKDownload()
    let cacheStub = TransactionCacheStub()
    let handler = FIAPaymentQueueHandler(
      queue: PaymentQueueStub(),
      transactionsUpdated: { transactions in
        XCTAssertEqual(transactions as? [SKPaymentTransactionStub], [transactionStub])
        updateTransactionsExpectation.fulfill()
      },
      transactionRemoved: { transactions in
        XCTAssertEqual(transactions as? [SKPaymentTransactionStub], [transactionStub])
        removeTransactionsExpectation.fulfill()
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: { downloads in
        XCTAssertEqual(downloads as NSArray, [downloadStub] as NSArray)
        updateDownloadsExpectation.fulfill()
      },
      transactionCache: cacheStub)

    var transactionCacheKeyUpdatedTransactionsInvokedCount = 0
    var transactionCacheKeyUpdatedDownloadsInvokedCount = 0
    var transactionCacheKeyRemovedTransactionsInvokedCount = 0

    cacheStub.getObjectsForKeyStub = { key in
      switch key {
      case .updatedTransactions:
        transactionCacheKeyUpdatedTransactionsInvokedCount += 1
        return [transactionStub]
      case .updatedDownloads:
        transactionCacheKeyUpdatedDownloadsInvokedCount += 1
        return [downloadStub]
      case .removedTransactions:
        transactionCacheKeyRemovedTransactionsInvokedCount += 1
        return [transactionStub]
      default:
        XCTFail("Invalid transaction state was invoked.")
      }
      return []
    }

    var clearInvokedCount = 0
    cacheStub.clearStub = {
      clearInvokedCount += 1
    }

    handler.startObservingPaymentQueue()

    waitForExpectations(timeout: 5)
    XCTAssertEqual(transactionCacheKeyUpdatedTransactionsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyUpdatedDownloadsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyRemovedTransactionsInvokedCount, 1)
    XCTAssertEqual(clearInvokedCount, 1)
  }

  func testTransactionsShouldBeCachedWhenNotObserving() {
    let queue = PaymentQueueStub()
    let cacheStub = TransactionCacheStub()
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { _ in
        XCTFail("transactionsUpdated callback should not be called when cache is empty.")
      },
      transactionRemoved: { _ in
        XCTFail("transactionRemoved callback should not be called when cache is empty.")
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: { _ in
        XCTFail("updatedDownloads callback should not be called when cache is empty.")
      },
      transactionCache: cacheStub)

    let payment = SKPayment(product: SKProductStub(map: productResponseMap))

    var transactionCacheKeyUpdatedTransactionsInvokedCount = 0
    var transactionCacheKeyUpdatedDownloadsInvokedCount = 0
    var transactionCacheKeyRemovedTransactionsInvokedCount = 0

    cacheStub.addObjectsStub = { objects, key in
      switch key {
      case .updatedTransactions:
        transactionCacheKeyUpdatedTransactionsInvokedCount += 1
      case .updatedDownloads:
        transactionCacheKeyUpdatedDownloadsInvokedCount += 1
      case .removedTransactions:
        transactionCacheKeyRemovedTransactionsInvokedCount += 1
      default:
        XCTFail("Invalid transaction state was invoked.")
      }
    }

    handler.add(payment)

    XCTAssertEqual(transactionCacheKeyUpdatedTransactionsInvokedCount, 1)
    XCTAssertEqual(transactionCacheKeyUpdatedDownloadsInvokedCount, 0)
    XCTAssertEqual(transactionCacheKeyRemovedTransactionsInvokedCount, 0)
  }

  func testTransactionsShouldNotBeCachedWhenObserving() {
    let updateTransactionsExpectation = expectation(
      description: "transactionsUpdated callback should be called with one transaction.")
    let removeTransactionsExpectation = expectation(
      description: "transactionsRemoved callback should be called with one transaction.")
    let updateDownloadsExpectation = expectation(
      description: "downloadsUpdated callback should be called with one transaction.")
    let transactionStub = SKPaymentTransactionStub()
    let downloadStub = SKDownload()
    let queue = PaymentQueueStub()
    queue.testState = .purchased
    let cacheStub = TransactionCacheStub()
    let handler = FIAPaymentQueueHandler(
      queue: queue,
      transactionsUpdated: { transactions in
        XCTAssertEqual(transactions as? [SKPaymentTransactionStub], [transactionStub])
        updateTransactionsExpectation.fulfill()
      },
      transactionRemoved: { transactions in
        XCTAssertEqual(transactions as? [SKPaymentTransactionStub], [transactionStub])
        removeTransactionsExpectation.fulfill()
      },
      restoreTransactionFailed: nil,
      restoreCompletedTransactionsFinished: nil,
      shouldAddStorePayment: { _, _ in
        return true
      },
      updatedDownloads: { downloads in
        XCTAssertEqual(downloads as NSArray, [downloadStub] as NSArray)
        updateDownloadsExpectation.fulfill()
      },
      transactionCache: cacheStub)

    let paymentQueueStub = SKPaymentQueueStub()

    handler.startObservingPaymentQueue()
    handler.paymentQueue(paymentQueueStub, updatedTransactions: [transactionStub])
    handler.paymentQueue(paymentQueueStub, removedTransactions: [transactionStub])
    handler.paymentQueue(paymentQueueStub, updatedDownloads: [downloadStub])

    waitForExpectations(timeout: 5)

    var transactionCacheKeyUpdatedTransactionsInvokedCount = 0
    var transactionCacheKeyUpdatedDownloadsInvokedCount = 0
    var transactionCacheKeyRemovedTransactionsInvokedCount = 0

    cacheStub.addObjectsStub = { objects, key in
      switch key {
      case .updatedTransactions:
        transactionCacheKeyUpdatedTransactionsInvokedCount += 1
      case .updatedDownloads:
        transactionCacheKeyUpdatedDownloadsInvokedCount += 1
      case .removedTransactions:
        transactionCacheKeyRemovedTransactionsInvokedCount += 1
      default:
        XCTFail("Invalid transaction state was invoked.")
      }
    }

    XCTAssertEqual(transactionCacheKeyUpdatedTransactionsInvokedCount, 0)
    XCTAssertEqual(transactionCacheKeyUpdatedDownloadsInvokedCount, 0)
    XCTAssertEqual(transactionCacheKeyRemovedTransactionsInvokedCount, 0)
  }
}
