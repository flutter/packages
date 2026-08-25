// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@objc public enum TransactionCacheKey: Int {
  case updatedDownloads
  case updatedTransactions
  case removedTransactions
}

public class FIATransactionCache: NSObject {
  /// A dictionary storing the objects that are cached.
  private var cache: [TransactionCacheKey: [Any]] = [:]

  /// Adds objects to the transaction cache.
  ///
  /// If the cache already contains an array of objects on the specified key, the supplied
  /// array will be appended to the existing array.
  @objc(addObjects:forKey:)
  public func add(_ objects: [Any], for key: TransactionCacheKey) {
    let cachedObjects = cache[key]
    cache[key] = cachedObjects != nil ? cachedObjects! + objects : objects
  }

  /// Gets the array of objects stored at the given key.
  ///
  /// If there are no objects associated with the given key an empty array is returned.
  @objc(getObjectsForKey:)
  public func getObjectsFor(_ key: TransactionCacheKey) -> [Any] {
    return cache[key] ?? []
  }

  /// Removes all objects from the transaction cache.
  @objc public func clear() {
    cache.removeAll()
  }
}
