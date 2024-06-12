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

@interface TestPaymentQueue : NSObject <FLTPaymentQueueProtocol>
/// Returns a wrapper for the given SKPaymentQueue.
@property(assign, nonatomic) SKPaymentTransactionState paymentState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@property(nonatomic, readwrite) SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property(nonatomic, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(
    ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));
@property(assign, nonatomic) SKPaymentTransactionState testState;
@property(nonatomic) SKPaymentQueue *realQueue;

@property(nonatomic, copy, nullable) void (^showPriceConsentIfNeededStub)(void);
@property(nonatomic, copy, nullable) void (^restoreTransactionsStub)(NSString *);
@property(nonatomic, copy, nullable) void (^startObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^stopObservingPaymentQueueStub)(void);
@property(nonatomic, copy, nullable) void (^presentCodeRedemptionSheetStub)(void);
@property(nonatomic, copy, nullable)
    NSArray<SKPaymentTransaction *> * (^getUnfinishedTransactionsStub)(void);

@end

#pragma mark TransactionCache

@interface TestTransactionCache : NSObject <FLTTransactionCacheProtocol>
@property(nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property(nonatomic, copy, nullable) void (^clearStub)(void);
@property(nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

#pragma mark MethodChannel

@interface TestMethodChannel : NSObject <FLTMethodChannelProtocol>
@property(nonatomic, copy, nullable) void (^invokeMethodChannelStub)(NSString *method, id arguments)
    ;
@property(nonatomic, copy, nullable) void (^invokeMethodChannelWithResultsStub)
    (NSString *method, id arguments, FlutterResult _Nullable);

@end

@interface TestPaymentQueueHandler
    : NSObject <SKPaymentTransactionObserver, FLTPaymentQueueHandlerProtocol>
@property(nonatomic) BOOL canAddPayment;
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

@interface TestRequestHandler : NSObject <FLTRequestHandlerProtocol>
@property(nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)
    (ProductRequestCompletion);
@end
NS_ASSUME_NONNULL_END
