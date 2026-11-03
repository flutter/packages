// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "messages.g.h"

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NS_ASSUME_NONNULL_BEGIN

@interface FIAObjectTranslator : NSObject

// Converts an instance of SKProduct into a dictionary.
+ (NSDictionary *)getMapFromSKProduct:(SKProduct *)product;

// Converts an instance of SKProductSubscriptionPeriod into a dictionary.
+ (NSDictionary *)getMapFromSKProductSubscriptionPeriod:(SKProductSubscriptionPeriod *)period;

// Converts an instance of SKProductDiscount into a dictionary.
+ (NSDictionary *)getMapFromSKProductDiscount:(SKProductDiscount *)discount;

// Converts an array of SKProductDiscount instances into an array of dictionaries.
+ (nonnull NSArray *)getMapArrayFromSKProductDiscounts:
    (nonnull NSArray<SKProductDiscount *> *)productDiscounts;

// Converts an instance of SKProductsResponse into a dictionary.
+ (NSDictionary *)getMapFromSKProductsResponse:(SKProductsResponse *)productResponse;

// Converts an instance of SKPayment into a dictionary.
+ (NSDictionary *)getMapFromSKPayment:(SKPayment *)payment;

// Converts an instance of NSLocale into a dictionary.
+ (NSDictionary *)getMapFromNSLocale:(NSLocale *)locale;

// Creates an instance of the SKMutablePayment class based on the supplied dictionary.
+ (SKMutablePayment *)getSKMutablePaymentFromMap:(NSDictionary *)map;

// Converts an instance of SKPaymentTransaction into a dictionary.
+ (NSDictionary *)getMapFromSKPaymentTransaction:(SKPaymentTransaction *)transaction;

// Converts an instance of NSError into a dictionary.
+ (NSDictionary *)getMapFromNSError:(NSError *)error;

// Converts an instance of SKStorefront into a dictionary.
+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront;

// Converts the supplied instances of SKStorefront and SKPaymentTransaction into a dictionary.
+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront
                 andSKPaymentTransaction:(SKPaymentTransaction *)transaction;

// Creates an instance of the SKPaymentDiscount class based on the supplied dictionary.
+ (nullable SKPaymentDiscount *)getSKPaymentDiscountFromMap:(NSDictionary *)map
                                                  withError:(NSString *_Nullable *_Nullable)error;

+ (nullable FIASKPaymentTransactionMessage *)convertTransactionToPigeon:
    (nullable SKPaymentTransaction *)transaction;

+ (nullable FIASKStorefrontMessage *)convertStorefrontToPigeon:(nullable SKStorefront *)storefront;

+ (nullable FIASKPaymentDiscountMessage *)convertPaymentDiscountToPigeon:
    (nullable SKPaymentDiscount *)discount;

+ (nullable FIASKPaymentMessage *)convertPaymentToPigeon:(nullable SKPayment *)payment;

+ (nullable FIASKErrorMessage *)convertSKErrorToPigeon:(nullable NSError *)error;

+ (nullable FIASKProductsResponseMessage *)convertProductsResponseToPigeon:
    (nullable SKProductsResponse *)payment;

+ (nullable FIASKProductMessage *)convertProductToPigeon:(nullable SKProduct *)product;

+ (nullable FIASKProductDiscountMessage *)convertProductDiscountToPigeon:
    (nullable SKProductDiscount *)productDiscount;

+ (nullable FIASKPriceLocaleMessage *)convertNSLocaleToPigeon:(nullable NSLocale *)locale;

+ (nullable FIASKProductSubscriptionPeriodMessage *)convertSKProductSubscriptionPeriodToPigeon:
    (nullable SKProductSubscriptionPeriod *)period;
@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
