// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "FLTMethodChannelProtocol.h"
#import "FLTPaymentQueueHandlerProtocol.h"
#import "FLTPaymentQueueProtocol.h"
#import "FLTRequestHandlerProtocol.h"
#import "FLTTransactionCacheProtocol.h"

NS_ASSUME_NONNULL_BEGIN

// An interface representing a stubbed DefaultPaymentQueue
@interface TestPaymentQueue : NSObject <FLTPaymentQueueProtocol>
// FLTPaymentQueueProtocol properties
@property(assign, nonatomic) SKPaymentTransactionState paymentState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@property(strong, nonatomic, readwrite) SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property(strong, nonatomic, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(
    ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));

// Test Properties
@property(assign, nonatomic)
    SKPaymentTransactionState testState;  // Set this property to set a test Transaction state, then
                                          // call addPayment to add it to the queue.
@property(strong, nonatomic, nonnull)
    SKPaymentQueue *realQueue;  // This is a reference to the real SKPaymentQueue

// Stubs
@property(nonatomic, copy, nullable) void (^showPriceConsentIfNeededStub)(void);
@property(nonatomic, copy, nullable) void (^restoreTransactionsStub)(NSString *);
@property(nonatomic, copy, nullable) void (^startObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^stopObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^presentCodeRedemptionSheetStub)(void);
@property(nonatomic, copy, nullable)
    NSArray<SKPaymentTransaction *> * (^getUnfinishedTransactionsStub)(void);

@end

#pragma mark TransactionCache

// An interface representing a stubbed DefaultTransactionCache
@interface TestTransactionCache : NSObject <FLTTransactionCacheProtocol>

// Stubs
@property(nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property(nonatomic, copy, nullable) void (^clearStub)(void);
@property(nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

#pragma mark MethodChannel

// An interface representing a stubbed DefaultMethodChannel
@interface TestMethodChannel : NSObject <FLTMethodChannelProtocol>

// Stubs
@property(nonatomic, copy, nullable) void (^invokeMethodChannelStub)(NSString *method, id arguments)
    ;
@property(nonatomic, copy, nullable) void (^invokeMethodChannelWithResultsStub)
    (NSString *method, id arguments, FlutterResult _Nullable);

@end

// An interface representing a stubbed DefaultPaymentQueueHandler
@interface TestPaymentQueueHandler
    : NSObject <SKPaymentTransactionObserver, FLTPaymentQueueHandlerProtocol>

// Stubs
@property(nonatomic, copy, nullable) BOOL (^addPaymentStub)(SKPayment *payment);
@property(nonatomic, copy, nullable) void (^showPriceConsentIfNeededStub)(void);
@property(nonatomic, copy, nullable) void (^stopObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^startObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^presentCodeRedemptionSheetStub)(void);
@property(nonatomic, copy, nullable) void (^restoreTransactions)(NSString *);
@property(nonatomic, copy, nullable)
    NSArray<SKPaymentTransaction *> * (^getUnfinishedTransactionsStub)(void);
@property(nonatomic, copy, nullable) void (^finishTransactionStub)(SKPaymentTransaction *);
@property(nonatomic, copy, nullable) void (^paymentQueueUpdatedTransactionsStub)
    (SKPaymentQueue *, NSArray<SKPaymentTransaction *> *);

@end

// An interface representing a stubbed DefaultRequestHandler
@interface TestRequestHandler : NSObject <FLTRequestHandlerProtocol>

// Stubs
@property(nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)
    (ProductRequestCompletion);

@end
NS_ASSUME_NONNULL_END
