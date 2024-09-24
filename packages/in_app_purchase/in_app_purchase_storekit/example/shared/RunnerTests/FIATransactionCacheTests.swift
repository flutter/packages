// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import in_app_purchase_storekit

final class FIATransactionCacheTests: XCTestCase {

  func testAddObjectsForNewKey() throws {
    let dummyArray = [1, 2, 3]
    let cache = FIATransactionCache()
    cache.add(dummyArray, for: TransactionCacheKey.updatedTransactions)

    let updatedTransactions = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as? [Int])
    XCTAssertEqual(dummyArray, updatedTransactions)
  }

  func testAddObjectsForExistingKey() throws {
    let dummyArray = [1, 2, 3]
    let cache = FIATransactionCache()
    cache.add(dummyArray, for: TransactionCacheKey.updatedTransactions)

    let firstUpdatedTransactions = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as? [Int])
    XCTAssertEqual(dummyArray, firstUpdatedTransactions)

    cache.add([4, 5, 6], for: TransactionCacheKey.updatedTransactions)

    let expected = [1, 2, 3, 4, 5, 6]
    let secondUpdatedTransactions = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as? [Int])
    XCTAssertEqual(expected, secondUpdatedTransactions)
  }

  func testGetObjectsForNonExistingKey() {
    let cache = FIATransactionCache()
    XCTAssertTrue(cache.getObjectsFor(TransactionCacheKey.updatedTransactions).isEmpty)
  }

  func testClear() throws {
    let fakeUpdatedTransactions = [1, 2, 3]
    let fakeRemovedTransactions = ["Remove 1", "Remove 2", "Remove 3"]
    let fakeUpdatedDownloads = ["Download 1", "Download 2"]
    let cache = FIATransactionCache()

    cache.add(fakeUpdatedTransactions, for: TransactionCacheKey.updatedTransactions)
    cache.add(fakeRemovedTransactions, for: TransactionCacheKey.removedTransactions)
    cache.add(fakeUpdatedDownloads, for: TransactionCacheKey.updatedDownloads)

    let updatedTransactions = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.updatedTransactions) as? [Int])
    let removedTransactions = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.removedTransactions) as? [String])
    let updatedDownloads = try XCTUnwrap(
      cache.getObjectsFor(TransactionCacheKey.updatedDownloads) as? [String])

    XCTAssertEqual(fakeUpdatedTransactions, updatedTransactions)
    XCTAssertEqual(fakeRemovedTransactions, removedTransactions)
    XCTAssertEqual(fakeUpdatedDownloads, updatedDownloads)

    cache.clear()

    XCTAssertTrue(cache.getObjectsFor(TransactionCacheKey.updatedTransactions).isEmpty)
    XCTAssertTrue(cache.getObjectsFor(TransactionCacheKey.removedTransactions).isEmpty)
    XCTAssertTrue(cache.getObjectsFor(TransactionCacheKey.updatedDownloads).isEmpty)
  }
}
