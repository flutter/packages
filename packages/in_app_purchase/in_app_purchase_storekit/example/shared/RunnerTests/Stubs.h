// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

///  (TODO: louiseshsu) Rewrite the stubs in this file to use protocols and merge with Mocks
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@import in_app_purchase_storekit;

NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface TestSKProductSubscriptionPeriod : SKProductSubscriptionPeriod
- (instancetype)initWithMap:(NSDictionary *)map;
@end

API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface TestSKProductDiscount : SKProductDiscount
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface TestSKProduct : SKProduct
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithProductID:(NSString *)productIdentifier;
@end

@interface TestSKProductRequest : SKProductsRequest
@property(assign, nonatomic) BOOL returnError;
- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers;
- (instancetype)initWithFailureError:(NSError *)error;
@end

@interface TestSKProductsResponse : SKProductsResponse
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface TestSKRequest : SKRequest
@end

@interface TestSKPaymentQueue : SKPaymentQueue
@property(assign, nonatomic) SKPaymentTransactionState testState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@end

@interface TestSKPaymentTransaction : SKPaymentTransaction
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithState:(SKPaymentTransactionState)state;
- (instancetype)initWithState:(SKPaymentTransactionState)state payment:(SKPayment *)payment;
@end

@interface TestSKMutablePayment : SKMutablePayment
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface TestNSError : NSError
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface TestFIAPReceiptManager : FIAPReceiptManager
// Indicates whether getReceiptData of this stub is going to return an error.
// Setting this to true will let getReceiptData give a basic NSError and return nil.
@property(assign, nonatomic) BOOL returnError;
// Indicates whether the receipt url will be nil.
@property(assign, nonatomic) BOOL returnNilURL;
@end

@interface TestSKReceiptRefreshRequest : SKReceiptRefreshRequest
- (instancetype)initWithFailureError:(NSError *)error;
@end

API_AVAILABLE(ios(13.0), macos(10.15))
@interface TestSKStorefront : SKStorefront
- (instancetype)initWithMap:(NSDictionary *)map;
@end

#if TARGET_OS_IOS
@interface TestFlutterPluginRegistrar : NSObject <FlutterPluginRegistrar>
@end
#endif

@interface TestFlutterBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end

NS_ASSUME_NONNULL_END
