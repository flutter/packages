// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/in_app_purchase_storekit_objc/FLTTransactionCacheProtocol.h"

@interface DefaultTransactionCache ()
/// The wrapped FIATransactionCache
@property(nonatomic, strong) FIATransactionCache *cache;
@end

@implementation DefaultTransactionCache

- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  [self.cache addObjects:objects forKey:key];
}

- (void)clear {
  [self.cache clear];
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  return [self.cache getObjectsForKey:key];
}

- (nonnull instancetype)initWithCache:(nonnull FIATransactionCache *)cache {
  self = [super init];
  if (self) {
    _cache = cache;
  }
  return self;
}
@end
