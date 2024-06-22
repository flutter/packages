// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIATransactionCache.h"
#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// A protocol that defines a cache of all transactions, both completed and in progress.
@protocol FLTTransactionCacheProtocol <NSObject>

/// Adds objects to the transaction cache.
///
/// If the cache already contains an array of objects on the specified key, the supplied
/// array will be appended to the existing array.
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;

/// Gets the array of objects stored at the given key.
///
/// If there are no objects associated with the given key nil is returned.
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;

/// Removes all objects from the transaction cache.
- (void)clear;
@end

/// The default method channel that wraps FIATransactionCache
@interface DefaultTransactionCache : NSObject <FLTTransactionCacheProtocol>

/// Initialize this wrapper with an FIATransactionCache
- (instancetype)initWithCache:(FIATransactionCache *)cache;
@end

NS_ASSUME_NONNULL_END
