// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Mocks.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIAPaymentQueueHandler.h"
#import "Stubs.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#pragma mark Test Implementations

@implementation TestPaymentQueue

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  [self.observer paymentQueue:self.realQueue removedTransactions:@[ transaction ]];
}

- (void)addPayment:(SKPayment *_Nonnull)payment {
  SKPaymentTransactionStub *transaction =
      [[SKPaymentTransactionStub alloc] initWithState:self.testState payment:payment];
  [self.observer paymentQueue:self.realQueue updatedTransactions:@[ transaction ]];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  self.observer = observer;
}

- (void)restoreCompletedTransactions {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
}

- (NSArray<SKPaymentTransaction *> *_Nonnull)getUnfinishedTransactions {
  return [NSArray array];
}
#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet {
}
#endif

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}
#endif

- (void)restoreTransactions:(nullable NSString *)applicationName {
}

- (void)startObservingPaymentQueue {
}

- (void)stopObservingPaymentQueue {
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = nil;
}

@synthesize transactions;

@synthesize delegate;

@end

@implementation TestMethodChannel
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  if (self.invokeMethodChannelStub) {
    self.invokeMethodChannelStub(method, arguments);
  }
}

- (void)invokeMethod:(nonnull NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  if (self.invokeMethodChannelWithResultsStub) {
    self.invokeMethodChannelWithResultsStub(method, arguments, callback);
  }
}

@end

@implementation TestTransactionCache
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  if (self.addObjectsStub) {
    self.addObjectsStub(objects, key);
  }
}

- (void)clear {
  if (self.clearStub) {
    self.clearStub();
  }
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  if (self.getObjectsForKeyStub) {
    return self.getObjectsForKeyStub(key);
  }
  return @[];
}
@end
