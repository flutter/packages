// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "FLTMethodChannelProtocol.h"
#import "FLTPaymentQueueHandlerProtocol.h"
#import "FLTPaymentQueueProtocol.h"
#import "FLTRequestHandlerProtocol.h"
#import "FLTTransactionCacheProtocol.h"

@import in_app_purchase_storekit;

NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface SKProductSubscriptionPeriodStub : SKProductSubscriptionPeriod
- (instancetype)initWithMap:(NSDictionary *)map;
@end

API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface SKProductDiscountStub : SKProductDiscount
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface SKProductStub : SKProduct
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithProductID:(NSString *)productIdentifier;
@end

@interface SKProductRequestStub : SKProductsRequest
@property(nonatomic, assign) BOOL returnError;
- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers;
- (instancetype)initWithFailureError:(NSError *)error;
@end

@interface SKProductsResponseStub : SKProductsResponse
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface SKPaymentQueueStub : SKPaymentQueue
@property(nonatomic, assign) SKPaymentTransactionState testState;
@property(nonatomic, strong, nullable) id<SKPaymentTransactionObserver> observer;
@end

@interface SKPaymentTransactionStub : SKPaymentTransaction
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithState:(SKPaymentTransactionState)state;
- (instancetype)initWithState:(SKPaymentTransactionState)state payment:(SKPayment *)payment;
@end

@interface SKMutablePaymentStub : SKMutablePayment
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface NSErrorStub : NSError
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface FIAPReceiptManagerStub : FIAPReceiptManager
// Indicates whether getReceiptData of this stub is going to return an error.
// Setting this to true will let getReceiptData give a basic NSError and return nil.
@property(nonatomic, assign) BOOL returnError;
// Indicates whether the receipt url will be nil.
@property(nonatomic, assign) BOOL returnNilURL;
@end

@interface SKReceiptRefreshRequestStub : SKReceiptRefreshRequest
- (instancetype)initWithFailureError:(NSError *)error;
@end

API_AVAILABLE(ios(13.0), macos(10.15))
@interface SKStorefrontStub : SKStorefront
- (instancetype)initWithMap:(NSDictionary *)map;
@end

// An interface representing a stubbed DefaultPaymentQueue
@interface PaymentQueueStub : NSObject <FLTPaymentQueueProtocol>

// FLTPaymentQueueProtocol properties
@property(nonatomic, assign) SKPaymentTransactionState paymentState;
@property(nonatomic, strong, nullable) id<SKPaymentTransactionObserver> observer;
@property(nonatomic, strong, readwrite) SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property(nonatomic, strong, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(
    ios(3.0), macos(10.7), watchos(6.2));

// Test Properties
@property(nonatomic, assign)
    SKPaymentTransactionState testState;  // Set this property to set a test Transaction state, then
                                          // call addPayment to add it to the queue.
@property(nonatomic, strong, nonnull)
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

// An interface representing a stubbed DefaultTransactionCache
@interface TransactionCacheStub : NSObject <FLTTransactionCacheProtocol>

// Stubs
@property(nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property(nonatomic, copy, nullable) void (^clearStub)(void);
@property(nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

// An interface representing a stubbed DefaultMethodChannel
@interface MethodChannelStub : NSObject <FLTMethodChannelProtocol>

// Stubs
@property(nonatomic, copy, nullable) void (^invokeMethodChannelStub)
    (NSString *method, id _Nullable arguments);
@property(nonatomic, copy, nullable) void (^invokeMethodChannelWithResultsStub)
    (NSString *method, id _Nullable arguments, FlutterResult _Nullable);

@end

// An interface representing a stubbed DefaultPaymentQueueHandler
@interface PaymentQueueHandlerStub
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
@interface RequestHandlerStub : NSObject <FLTRequestHandlerProtocol>

// Stubs
@property(nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)
    (ProductRequestCompletion);

@end

#if TARGET_OS_IOS
@interface FlutterPluginRegistrarStub : NSObject <FlutterPluginRegistrar>

// Stubs
@property(nonatomic, copy, nullable) void (^addApplicationDelegateStub)(NSObject<FlutterPlugin> *);
@property(nonatomic, copy, nullable) void (^addMethodCallDelegateStub)
    (NSObject<FlutterPlugin> *, FlutterMethodChannel *);
@property(nonatomic, copy, nullable) NSString * (^lookupKeyForAssetStub)(NSString *);
@property(nonatomic, copy, nullable) NSString * (^lookupKeyForAssetFromPackageStub)
    (NSString *, NSString *);
@property(nonatomic, copy, nullable) NSObject<FlutterBinaryMessenger> * (^messengerStub)(void);
@property(nonatomic, copy, nullable) void (^publishStub)(NSObject *);
@property(nonatomic, copy, nullable) void (^registerViewFactoryStub)
    (NSObject<FlutterPlatformViewFactory> *, NSString *);
@property(nonatomic, copy, nullable) NSObject<FlutterTextureRegistry> * (^texturesStub)(void);
@property(nonatomic, copy, nullable)
    void (^registerViewFactoryWithGestureRecognizersBlockingPolicyStub)
        (NSObject<FlutterPlatformViewFactory> *, NSString *,
         FlutterPlatformViewGestureRecognizersBlockingPolicy);
@end
#endif

@interface FlutterBinaryMessengerStub : NSObject <FlutterBinaryMessenger>

// Stubs
@property(nonatomic, copy, nullable) void (^cleanUpConnectionStub)(FlutterBinaryMessengerConnection)
    ;
@property(nonatomic, copy, nullable) void (^sendOnChannelMessageStub)(NSString *, NSData *);
@property(nonatomic, copy, nullable) void (^sendOnChannelMessageBinaryReplyStub)
    (NSString *, NSData *, FlutterBinaryReply);
@property(nonatomic, copy, nullable)
    FlutterBinaryMessengerConnection (^setMessageHandlerOnChannelBinaryMessageHandlerStub)
        (NSString *, FlutterBinaryMessageHandler);
@end

NS_ASSUME_NONNULL_END
