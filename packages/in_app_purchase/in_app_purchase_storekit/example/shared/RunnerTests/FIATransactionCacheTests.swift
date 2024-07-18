// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import in_app_purchase_storekit

final class FIATransactionCacheTests: XCTestCase {

  func testAddObjectsForNewKey() {
    let dummyArray: [Int] = [1, 2, 3]
    let cache = FIATransactionCache()
    cache.add(dummyArray, for: TransactionCacheKey.updatedTransactions)

    XCTAssertEqual(
      dummyArray, cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as! [Int])
  }

  func testAddObjectsForExistingKey() {
    let dummyArray: [Int] = [1, 2, 3]
    let cache = FIATransactionCache()
    cache.add(dummyArray, for: TransactionCacheKey.updatedTransactions)

    XCTAssertEqual(
      dummyArray, cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as! [Int])

    cache.add([4, 5, 6], for: TransactionCacheKey.updatedTransactions)

    let expected: [Int] = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(expected, cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as! [Int])
  }

  func testGetObjectsForNonExistingKey() {
    let cache = FIATransactionCache()
    XCTAssert(cache.getObjectsFor(TransactionCacheKey.updatedTransactions).count == 0)
  }

  func testClear() {
    let fakeUpdatedTransactions: [Int] = [1, 2, 3]
    let fakeRemovedTransactions: [String] = ["Remove 1", "Remove 2", "Remove 3"]
    let fakeUpdatedDownloads: [String] = ["Download 1", "Download 2"]
    let cache = FIATransactionCache()
    cache.add(fakeUpdatedTransactions, for: TransactionCacheKey.updatedTransactions)
    cache.add(fakeRemovedTransactions, for: TransactionCacheKey.removedTransactions)
    cache.add(fakeUpdatedDownloads, for: TransactionCacheKey.updatedDownloads)

    XCTAssertEqual(
      fakeUpdatedTransactions,
      cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as! [Int])
    XCTAssertEqual(
      fakeRemovedTransactions,
      cache.getObjectsFor(TransactionCacheKey.removedTransactions) as! [String])
    XCTAssertEqual(
      fakeUpdatedDownloads, cache.getObjectsFor(TransactionCacheKey.updatedDownloads) as! [String])

    cache.clear()

    XCTAssert(cache.getObjectsFor(TransactionCacheKey.updatedTransactions).count == 0)
    XCTAssert(cache.getObjectsFor(TransactionCacheKey.removedTransactions).count == 0)
    XCTAssert(cache.getObjectsFor(TransactionCacheKey.updatedDownloads).count == 0)
  }
}
