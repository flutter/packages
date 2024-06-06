// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAProtocols.h"

/// Default implementations of FIAProtocols
@implementation DefaultPaymentQueue
- (instancetype)initWithQueue:(SKPaymentQueue *)queue {
  self = [super init];
  if (self) {
    _queue = queue;
  }
  return self;
}

- (void)addPayment:(SKPayment *_Nonnull)payment {
  [self.queue addPayment:payment];
}

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {
  [self.queue finishTransaction:transaction];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  [self.queue addTransactionObserver:observer];
}

- (void)restoreCompletedTransactions {
  [self.queue restoreCompletedTransactions];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
  [self.queue restoreCompletedTransactionsWithApplicationUsername:username];
}

- (id<SKPaymentQueueDelegate>)delegate API_AVAILABLE(ios(13.0), macos(10.15), watchos(6.2),
                                                     visionos(1.0)) {
  return self.queue.delegate;
}

- (NSArray<SKPaymentTransaction *> *)transactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2),
                                                                visionos(1.0)) {
  return self.queue.transactions;
}

- (SKStorefront *)storefront API_AVAILABLE(ios(13.0)) {
  return self.queue.storefront;
}
#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue presentCodeRedemptionSheet];
}
#endif

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue showPriceConsentIfNeeded];
}
#endif

@synthesize storefront;

@synthesize delegate;

@synthesize transactions;

@end

@implementation DefaultMethodChannel
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  [self.channel invokeMethod:method arguments:arguments];
}

- (void)invokeMethod:(nonnull NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  [self.channel invokeMethod:method arguments:arguments result:callback];
}

- (instancetype)initWithChannel:(nonnull FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

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
