// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/in_app_purchase_storekit_objc/FLTPaymentQueueProtocol.h"

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface DefaultPaymentQueue ()
/// The wrapped SKPaymentQueue
@property(nonatomic, strong) SKPaymentQueue *queue;
@end

@implementation DefaultPaymentQueue

@synthesize storefront;
@synthesize delegate;
@synthesize transactions;

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

- (id<SKPaymentQueueDelegate>)delegate {
  return self.queue.delegate;
}

- (NSArray<SKPaymentTransaction *> *)transactions {
  return self.queue.transactions;
}

- (SKStorefront *)storefront {
  return self.queue.storefront;
}

#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0))API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue presentCodeRedemptionSheet];
}
#endif

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4))API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue showPriceConsentIfNeeded];
}
#endif

@end

#pragma clang diagnostic pop
