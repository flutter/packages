// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.4.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FIASKPaymentTransactionStateMessage) {
  /// Indicates the transaction is being processed in App Store.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state. Never complete a transaction that
  /// is still in a purchasing state.
  FIASKPaymentTransactionStateMessagePurchasing = 0,
  /// The user's payment has been succesfully processed.
  ///
  /// You should provide the user the content that they purchased.
  FIASKPaymentTransactionStateMessagePurchased = 1,
  /// The transaction failed.
  ///
  /// Check the [PaymentTransactionWrapper.error] property from
  /// [PaymentTransactionWrapper] for details.
  FIASKPaymentTransactionStateMessageFailed = 2,
  /// This transaction is restoring content previously purchased by the user.
  ///
  /// The previous transaction information can be obtained in
  /// [PaymentTransactionWrapper.originalTransaction] from
  /// [PaymentTransactionWrapper].
  FIASKPaymentTransactionStateMessageRestored = 3,
  /// The transaction is in the queue but pending external action. Wait for
  /// another callback to get the final state.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state.
  FIASKPaymentTransactionStateMessageDeferred = 4,
  /// Indicates the transaction is in an unspecified state.
  FIASKPaymentTransactionStateMessageUnspecified = 5,
};

/// Wrapper for FIASKPaymentTransactionStateMessage to allow for nullability.
@interface FIASKPaymentTransactionStateMessageBox : NSObject
@property(nonatomic, assign) FIASKPaymentTransactionStateMessage value;
- (instancetype)initWithValue:(FIASKPaymentTransactionStateMessage)value;
@end

typedef NS_ENUM(NSUInteger, FIASKProductDiscountTypeMessage) {
  /// A constant indicating the discount type is an introductory offer.
  FIASKProductDiscountTypeMessageIntroductory = 0,
  /// A constant indicating the discount type is a promotional offer.
  FIASKProductDiscountTypeMessageSubscription = 1,
};

/// Wrapper for FIASKProductDiscountTypeMessage to allow for nullability.
@interface FIASKProductDiscountTypeMessageBox : NSObject
@property(nonatomic, assign) FIASKProductDiscountTypeMessage value;
- (instancetype)initWithValue:(FIASKProductDiscountTypeMessage)value;
@end

typedef NS_ENUM(NSUInteger, FIASKProductDiscountPaymentModeMessage) {
  /// Allows user to pay the discounted price at each payment period.
  FIASKProductDiscountPaymentModeMessagePayAsYouGo = 0,
  /// Allows user to pay the discounted price upfront and receive the product for the rest of time
  /// that was paid for.
  FIASKProductDiscountPaymentModeMessagePayUpFront = 1,
  /// User pays nothing during the discounted period.
  FIASKProductDiscountPaymentModeMessageFreeTrial = 2,
  /// Unspecified mode.
  FIASKProductDiscountPaymentModeMessageUnspecified = 3,
};

/// Wrapper for FIASKProductDiscountPaymentModeMessage to allow for nullability.
@interface FIASKProductDiscountPaymentModeMessageBox : NSObject
@property(nonatomic, assign) FIASKProductDiscountPaymentModeMessage value;
- (instancetype)initWithValue:(FIASKProductDiscountPaymentModeMessage)value;
@end

typedef NS_ENUM(NSUInteger, FIASKSubscriptionPeriodUnitMessage) {
  FIASKSubscriptionPeriodUnitMessageDay = 0,
  FIASKSubscriptionPeriodUnitMessageWeek = 1,
  FIASKSubscriptionPeriodUnitMessageMonth = 2,
  FIASKSubscriptionPeriodUnitMessageYear = 3,
};

/// Wrapper for FIASKSubscriptionPeriodUnitMessage to allow for nullability.
@interface FIASKSubscriptionPeriodUnitMessageBox : NSObject
@property(nonatomic, assign) FIASKSubscriptionPeriodUnitMessage value;
- (instancetype)initWithValue:(FIASKSubscriptionPeriodUnitMessage)value;
@end

@class FIASKPaymentTransactionMessage;
@class FIASKPaymentMessage;
@class FIASKErrorMessage;
@class FIASKPaymentDiscountMessage;
@class FIASKStorefrontMessage;
@class FIASKProductsResponseMessage;
@class FIASKProductMessage;
@class FIASKPriceLocaleMessage;
@class FIASKProductDiscountMessage;
@class FIASKProductSubscriptionPeriodMessage;

@interface FIASKPaymentTransactionMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithPayment:(FIASKPaymentMessage *)payment
               transactionState:(FIASKPaymentTransactionStateMessage)transactionState
            originalTransaction:(nullable FIASKPaymentTransactionMessage *)originalTransaction
           transactionTimeStamp:(nullable NSNumber *)transactionTimeStamp
          transactionIdentifier:(nullable NSString *)transactionIdentifier
                          error:(nullable FIASKErrorMessage *)error;
@property(nonatomic, strong) FIASKPaymentMessage *payment;
@property(nonatomic, assign) FIASKPaymentTransactionStateMessage transactionState;
@property(nonatomic, strong, nullable) FIASKPaymentTransactionMessage *originalTransaction;
@property(nonatomic, strong, nullable) NSNumber *transactionTimeStamp;
@property(nonatomic, copy, nullable) NSString *transactionIdentifier;
@property(nonatomic, strong, nullable) FIASKErrorMessage *error;
@end

@interface FIASKPaymentMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithProductIdentifier:(NSString *)productIdentifier
                      applicationUsername:(nullable NSString *)applicationUsername
                              requestData:(nullable NSString *)requestData
                                 quantity:(NSInteger)quantity
               simulatesAskToBuyInSandbox:(BOOL)simulatesAskToBuyInSandbox
                          paymentDiscount:(nullable FIASKPaymentDiscountMessage *)paymentDiscount;
@property(nonatomic, copy) NSString *productIdentifier;
@property(nonatomic, copy, nullable) NSString *applicationUsername;
@property(nonatomic, copy, nullable) NSString *requestData;
@property(nonatomic, assign) NSInteger quantity;
@property(nonatomic, assign) BOOL simulatesAskToBuyInSandbox;
@property(nonatomic, strong, nullable) FIASKPaymentDiscountMessage *paymentDiscount;
@end

@interface FIASKErrorMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithCode:(NSInteger)code
                      domain:(NSString *)domain
                    userInfo:(nullable NSDictionary<NSString *, id> *)userInfo;
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *domain;
@property(nonatomic, copy, nullable) NSDictionary<NSString *, id> *userInfo;
@end

@interface FIASKPaymentDiscountMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithIdentifier:(NSString *)identifier
                     keyIdentifier:(NSString *)keyIdentifier
                             nonce:(NSString *)nonce
                         signature:(NSString *)signature
                         timestamp:(NSInteger)timestamp;
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *keyIdentifier;
@property(nonatomic, copy) NSString *nonce;
@property(nonatomic, copy) NSString *signature;
@property(nonatomic, assign) NSInteger timestamp;
@end

@interface FIASKStorefrontMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithCountryCode:(NSString *)countryCode identifier:(NSString *)identifier;
@property(nonatomic, copy) NSString *countryCode;
@property(nonatomic, copy) NSString *identifier;
@end

@interface FIASKProductsResponseMessage : NSObject
+ (instancetype)makeWithProducts:(nullable NSArray<FIASKProductMessage *> *)products
       invalidProductIdentifiers:(nullable NSArray<NSString *> *)invalidProductIdentifiers;
@property(nonatomic, copy, nullable) NSArray<FIASKProductMessage *> *products;
@property(nonatomic, copy, nullable) NSArray<NSString *> *invalidProductIdentifiers;
@end

@interface FIASKProductMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)
      makeWithProductIdentifier:(NSString *)productIdentifier
                 localizedTitle:(NSString *)localizedTitle
           localizedDescription:(nullable NSString *)localizedDescription
                    priceLocale:(FIASKPriceLocaleMessage *)priceLocale
    subscriptionGroupIdentifier:(nullable NSString *)subscriptionGroupIdentifier
                          price:(NSString *)price
             subscriptionPeriod:(nullable FIASKProductSubscriptionPeriodMessage *)subscriptionPeriod
              introductoryPrice:(nullable FIASKProductDiscountMessage *)introductoryPrice
                      discounts:(nullable NSArray<FIASKProductDiscountMessage *> *)discounts;
@property(nonatomic, copy) NSString *productIdentifier;
@property(nonatomic, copy) NSString *localizedTitle;
@property(nonatomic, copy, nullable) NSString *localizedDescription;
@property(nonatomic, strong) FIASKPriceLocaleMessage *priceLocale;
@property(nonatomic, copy, nullable) NSString *subscriptionGroupIdentifier;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, strong, nullable) FIASKProductSubscriptionPeriodMessage *subscriptionPeriod;
@property(nonatomic, strong, nullable) FIASKProductDiscountMessage *introductoryPrice;
@property(nonatomic, copy, nullable) NSArray<FIASKProductDiscountMessage *> *discounts;
@end

@interface FIASKPriceLocaleMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithCurrencySymbol:(NSString *)currencySymbol
                          currencyCode:(NSString *)currencyCode
                           countryCode:(NSString *)countryCode;
/// The currency symbol for the locale, e.g. $ for US locale.
@property(nonatomic, copy) NSString *currencySymbol;
/// The currency code for the locale, e.g. USD for US locale.
@property(nonatomic, copy) NSString *currencyCode;
/// The country code for the locale, e.g. US for US locale.
@property(nonatomic, copy) NSString *countryCode;
@end

@interface FIASKProductDiscountMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithPrice:(NSString *)price
                  priceLocale:(FIASKPriceLocaleMessage *)priceLocale
              numberOfPeriods:(NSInteger)numberOfPeriods
                  paymentMode:(FIASKProductDiscountPaymentModeMessage)paymentMode
           subscriptionPeriod:(FIASKProductSubscriptionPeriodMessage *)subscriptionPeriod
                   identifier:(nullable NSString *)identifier
                         type:(FIASKProductDiscountTypeMessage)type;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, strong) FIASKPriceLocaleMessage *priceLocale;
@property(nonatomic, assign) NSInteger numberOfPeriods;
@property(nonatomic, assign) FIASKProductDiscountPaymentModeMessage paymentMode;
@property(nonatomic, strong) FIASKProductSubscriptionPeriodMessage *subscriptionPeriod;
@property(nonatomic, copy, nullable) NSString *identifier;
@property(nonatomic, assign) FIASKProductDiscountTypeMessage type;
@end

@interface FIASKProductSubscriptionPeriodMessage : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithNumberOfUnits:(NSInteger)numberOfUnits
                                 unit:(FIASKSubscriptionPeriodUnitMessage)unit;
@property(nonatomic, assign) NSInteger numberOfUnits;
@property(nonatomic, assign) FIASKSubscriptionPeriodUnitMessage unit;
@end

/// The codec used by all APIs.
NSObject<FlutterMessageCodec> *FIAGetMessagesCodec(void);

@protocol FIAInAppPurchaseAPI
/// Returns if the current device is able to make payments
///
/// @return `nil` only when `error != nil`.
- (nullable NSNumber *)canMakePaymentsWithError:(FlutterError *_Nullable *_Nonnull)error;
/// @return `nil` only when `error != nil`.
- (nullable NSArray<FIASKPaymentTransactionMessage *> *)transactionsWithError:
    (FlutterError *_Nullable *_Nonnull)error;
/// @return `nil` only when `error != nil`.
- (nullable FIASKStorefrontMessage *)storefrontWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)addPaymentPaymentMap:(NSDictionary<NSString *, id> *)paymentMap
                       error:(FlutterError *_Nullable *_Nonnull)error;
- (void)startProductRequestProductIdentifiers:(NSArray<NSString *> *)productIdentifiers
                                   completion:(void (^)(FIASKProductsResponseMessage *_Nullable,
                                                        FlutterError *_Nullable))completion;
- (void)finishTransactionFinishMap:(NSDictionary<NSString *, id> *)finishMap
                             error:(FlutterError *_Nullable *_Nonnull)error;
- (void)restoreTransactionsApplicationUserName:(nullable NSString *)applicationUserName
                                         error:(FlutterError *_Nullable *_Nonnull)error;
- (void)presentCodeRedemptionSheetWithError:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSString *)retrieveReceiptDataWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)refreshReceiptReceiptProperties:(nullable NSDictionary<NSString *, id> *)receiptProperties
                             completion:(void (^)(FlutterError *_Nullable))completion;
- (void)startObservingPaymentQueueWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)stopObservingPaymentQueueWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)registerPaymentQueueDelegateWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)removePaymentQueueDelegateWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)showPriceConsentIfNeededWithError:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void SetUpFIAInAppPurchaseAPI(id<FlutterBinaryMessenger> binaryMessenger,
                                     NSObject<FIAInAppPurchaseAPI> *_Nullable api);

extern void SetUpFIAInAppPurchaseAPIWithSuffix(id<FlutterBinaryMessenger> binaryMessenger,
                                               NSObject<FIAInAppPurchaseAPI> *_Nullable api,
                                               NSString *messageChannelSuffix);

NS_ASSUME_NONNULL_END
