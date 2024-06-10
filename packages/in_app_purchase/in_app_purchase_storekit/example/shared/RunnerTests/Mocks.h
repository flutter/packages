// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "MethodChannelProtocol.h"
#import "PaymentQueueHandlerProtocol.h"
#import "PaymentQueueProtocol.h"
#import "RequestHandlerProtocol.h"
#import "TransactionCacheProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestPaymentQueue : NSObject <PaymentQueue>
/// Returns a wrapper for the given SKPaymentQueue.
@property(assign, nonatomic) SKPaymentTransactionState paymentState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@property(atomic, readwrite) SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property(atomic, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(
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

@interface TestTransactionCache : NSObject <TransactionCache>
@property(nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property(nonatomic, copy, nullable) void (^clearStub)(void);
@property(nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

#pragma mark MethodChannel

@interface TestMethodChannel : NSObject <MethodChannel>
@property(nonatomic, copy, nullable) void (^invokeMethodChannelStub)(NSString *method, id arguments)
    ;
@property(nonatomic, copy, nullable) void (^invokeMethodChannelWithResultsStub)
    (NSString *method, id arguments, FlutterResult _Nullable);

@end

@interface TestPaymentQueueHandler : NSObject <SKPaymentTransactionObserver, PaymentQueueHandler>
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

@interface TestRequestHandler : NSObject <RequestHandler>
@property(nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)
    (ProductRequestCompletion);
@end
NS_ASSUME_NONNULL_END
