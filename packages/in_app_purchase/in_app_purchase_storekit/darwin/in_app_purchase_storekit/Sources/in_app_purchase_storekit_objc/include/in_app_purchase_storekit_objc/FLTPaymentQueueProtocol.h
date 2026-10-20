// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <StoreKit/StoreKit.h>

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NS_ASSUME_NONNULL_BEGIN

/// A protocol that wraps SKPaymentQueue
@protocol FLTPaymentQueueProtocol <NSObject>

/// An object containing the location and unique identifier of an Apple App Store storefront.
@property(nonatomic, strong) SKStorefront *storefront;

/// A list of SKPaymentTransactions, which each represents a single transaction
@property(nonatomic, strong) NSArray<SKPaymentTransaction *> *transactions;

/// An object that provides information needed to complete transactions.
@property(nonatomic, weak, nullable) id<SKPaymentQueueDelegate> delegate;

/// Remove a finished (i.e. failed or completed) transaction from the queue.  Attempting to finish a
/// purchasing transaction will throw an exception.
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;

/// Observers are not retained.  The transactions array will only be synchronized with the server
/// while the queue has observers.  This may require that the user authenticate.
- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer;

/// Add a payment to the server queue.  The payment is copied to add an SKPaymentTransaction to the
/// transactions array.  The same payment can be added multiple times to create multiple
/// transactions.
- (void)addPayment:(SKPayment *_Nonnull)payment;

/// Will add completed transactions for the current user back to the queue to be re-completed.
- (void)restoreCompletedTransactions;

/// Will add completed transactions for the current user back to the queue to be re-completed. This
/// version requires an identifier to the user's account.
- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username;

/// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by
/// your app. Only for iOS.
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0))API_UNAVAILABLE(tvos, macos, watchos);

/// If StoreKit has called your SKPaymentQueueDelegate's "paymentQueueShouldShowPriceConsent:"
/// method and you returned NO, you can use this method to show the price consent UI at a later time
/// that is more appropriate for your app. If there is no pending price consent, this method will do
/// nothing.
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4))API_UNAVAILABLE(tvos, macos, watchos);

@end

/// The default PaymentQueue that wraps SKPaymentQueue
@interface DefaultPaymentQueue : NSObject <FLTPaymentQueueProtocol>

/// Initialize this wrapper with an SKPaymentQueue
- (instancetype)initWithQueue:(SKPaymentQueue *)queue NS_DESIGNATED_INITIALIZER;

/// The default initializer is unavailable, as it this must be initlai
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
