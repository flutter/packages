// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/in_app_purchase_storekit_objc/FLTPaymentQueueProtocol.h"

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

- (id<SKPaymentQueueDelegate>)delegate API_AVAILABLE(ios(13.0), macos(10.15), watchos(6.2)) {
  return self.queue.delegate;
}

- (NSArray<SKPaymentTransaction *> *)transactions API_AVAILABLE(ios(3.0), macos(10.7),
                                                                watchos(6.2)) {
  return self.queue.transactions;
}

- (SKStorefront *)storefront API_AVAILABLE(ios(13.0)) {
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
