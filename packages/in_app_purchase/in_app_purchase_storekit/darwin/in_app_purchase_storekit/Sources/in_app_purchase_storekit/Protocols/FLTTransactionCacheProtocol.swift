// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// A protocol that defines a cache of all transactions, both completed and in progress.
@objc public protocol FLTTransactionCacheProtocol: NSObjectProtocol {
  /// Adds objects to the transaction cache.
  ///
  /// If the cache already contains an array of objects on the specified key, the supplied
  /// array will be appended to the existing array.
  func add(_ objects: [Any], for key: TransactionCacheKey)

  /// Gets the array of objects stored at the given key.
  ///
  /// If there are no objects associated with the given key an empty array is returned.
  func getObjectsFor(_ key: TransactionCacheKey) -> [Any]

  /// Removes all objects from the transaction cache.
  func clear()
}

/// The default transaction cache that wraps FIATransactionCache
public class DefaultTransactionCache: NSObject, FLTTransactionCacheProtocol {
  /// The wrapped FIATransactionCache
  private let cache: FIATransactionCache

  /// Initialize this wrapper with an FIATransactionCache
  public init(cache: FIATransactionCache) {
    self.cache = cache
  }

  public func add(_ objects: [Any], for key: TransactionCacheKey) {
    cache.add(objects, for: key)
  }

  public func getObjectsFor(_ key: TransactionCacheKey) -> [Any] {
    return cache.getObjectsFor(key)
  }

  public func clear() {
    cache.clear()
  }
}
