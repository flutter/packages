// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/in_app_purchase_storekit_objc/FIAObjectTranslator.h"

#pragma mark - SKProduct Coders

@implementation FIAObjectTranslator

+ (NSDictionary *)getMapFromSKProduct:(SKProduct *)product {
  if (!product) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"localizedDescription" : product.localizedDescription ?: [NSNull null],
    @"localizedTitle" : product.localizedTitle ?: [NSNull null],
    @"productIdentifier" : product.productIdentifier ?: [NSNull null],
    @"price" : product.price.description ?: [NSNull null]

  }];
  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:product.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  [map setObject:[FIAObjectTranslator
                     getMapFromSKProductSubscriptionPeriod:product.subscriptionPeriod]
                     ?: [NSNull null]
          forKey:@"subscriptionPeriod"];
  [map setObject:[FIAObjectTranslator getMapFromSKProductDiscount:product.introductoryPrice]
                     ?: [NSNull null]
          forKey:@"introductoryPrice"];
  if (@available(iOS 12.2, *)) {
    [map setObject:[FIAObjectTranslator getMapArrayFromSKProductDiscounts:product.discounts]
            forKey:@"discounts"];
  }
  [map setObject:product.subscriptionGroupIdentifier ?: [NSNull null]
          forKey:@"subscriptionGroupIdentifier"];
  return map;
}

+ (NSDictionary *)getMapFromSKProductSubscriptionPeriod:(SKProductSubscriptionPeriod *)period {
  if (!period) {
    return nil;
  }
  return @{@"numberOfUnits" : @(period.numberOfUnits), @"unit" : @(period.unit)};
}

+ (nonnull NSArray *)getMapArrayFromSKProductDiscounts:
    (nonnull NSArray<SKProductDiscount *> *)productDiscounts {
  NSMutableArray *discountsMapArray = [[NSMutableArray alloc] init];

  for (SKProductDiscount *productDiscount in productDiscounts) {
    [discountsMapArray addObject:[FIAObjectTranslator getMapFromSKProductDiscount:productDiscount]];
  }

  return discountsMapArray;
}

+ (NSDictionary *)getMapFromSKProductDiscount:(SKProductDiscount *)discount {
  if (!discount) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : discount.price.description ?: [NSNull null],
    @"numberOfPeriods" : @(discount.numberOfPeriods),
    @"subscriptionPeriod" :
            [FIAObjectTranslator getMapFromSKProductSubscriptionPeriod:discount.subscriptionPeriod]
        ?: [NSNull null],
    @"paymentMode" : @(discount.paymentMode),
  }];
  if (@available(iOS 12.2, *)) {
    [map setObject:discount.identifier ?: [NSNull null] forKey:@"identifier"];
    [map setObject:@(discount.type) forKey:@"type"];
  }

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:discount.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  return map;
}

+ (NSDictionary *)getMapFromSKProductsResponse:(SKProductsResponse *)productResponse {
  if (!productResponse) {
    return nil;
  }
  NSMutableArray *productsMapArray = [NSMutableArray new];
  for (SKProduct *product in productResponse.products) {
    [productsMapArray addObject:[FIAObjectTranslator getMapFromSKProduct:product]];
  }
  return @{
    @"products" : productsMapArray,
    @"invalidProductIdentifiers" : productResponse.invalidProductIdentifiers ?: @[]
  };
}

+ (NSDictionary *)getMapFromSKPayment:(SKPayment *)payment {
  if (!payment) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"productIdentifier" : payment.productIdentifier ?: [NSNull null],
    @"requestData" : payment.requestData ? [[NSString alloc] initWithData:payment.requestData
                                                                 encoding:NSUTF8StringEncoding]
                                         : [NSNull null],
    @"quantity" : @(payment.quantity),
    @"applicationUsername" : payment.applicationUsername ?: [NSNull null]
  }];
  [map setObject:@(payment.simulatesAskToBuyInSandbox) forKey:@"simulatesAskToBuyInSandbox"];
  return map;
}

+ (NSDictionary *)getMapFromNSLocale:(NSLocale *)locale {
  if (!locale) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
  [map setObject:locale.currencySymbol ?: [NSNull null] forKey:@"currencySymbol"];
  [map setObject:locale.currencyCode ?: [NSNull null] forKey:@"currencyCode"];
  [map setObject:locale.countryCode ?: [NSNull null] forKey:@"countryCode"];
  return map;
}

+ (SKMutablePayment *)getSKMutablePaymentFromMap:(NSDictionary *)map {
  if (!map) {
    return nil;
  }
  SKMutablePayment *payment = [[SKMutablePayment alloc] init];
  payment.productIdentifier = map[@"productIdentifier"];
  NSString *utf8String = map[@"requestData"];
  payment.requestData = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
  payment.quantity = [map[@"quantity"] integerValue];
  payment.applicationUsername = map[@"applicationUsername"];
  payment.simulatesAskToBuyInSandbox = [map[@"simulatesAskToBuyInSandbox"] boolValue];
  return payment;
}

+ (NSDictionary *)getMapFromSKPaymentTransaction:(SKPaymentTransaction *)transaction {
  if (!transaction) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"error" : [FIAObjectTranslator getMapFromNSError:transaction.error] ?: [NSNull null],
    @"payment" : transaction.payment ? [FIAObjectTranslator getMapFromSKPayment:transaction.payment]
                                     : [NSNull null],
    @"originalTransaction" : transaction.originalTransaction
        ? [FIAObjectTranslator getMapFromSKPaymentTransaction:transaction.originalTransaction]
        : [NSNull null],
    @"transactionTimeStamp" : transaction.transactionDate
        ? @(transaction.transactionDate.timeIntervalSince1970)
        : [NSNull null],
    @"transactionIdentifier" : transaction.transactionIdentifier ?: [NSNull null],
    @"transactionState" : @(transaction.transactionState)
  }];

  return map;
}

+ (NSDictionary *)getMapFromNSError:(NSError *)error {
  if (!error) {
    return nil;
  }

  return @{
    @"code" : @(error.code),
    @"domain" : error.domain ?: @"",
    @"userInfo" : [FIAObjectTranslator encodeNSErrorUserInfo:error.userInfo]
  };
}

+ (id)encodeNSErrorUserInfo:(id)value {
  if ([value isKindOfClass:[NSError class]]) {
    return [FIAObjectTranslator getMapFromNSError:value];
  } else if ([value isKindOfClass:[NSURL class]]) {
    return [value absoluteString];
  } else if ([value isKindOfClass:[NSNumber class]]) {
    return value;
  } else if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    for (id error in value) {
      [errors addObject:[FIAObjectTranslator encodeNSErrorUserInfo:error]];
    }
    return errors;
  } else if ([value isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *errors = [[NSMutableDictionary alloc] init];
    for (id key in value) {
      errors[key] = [FIAObjectTranslator encodeNSErrorUserInfo:value[key]];
    }
    return errors;
  } else {
    return [NSString
        stringWithFormat:
            @"Unable to encode native userInfo object of type %@ to map. Please submit an issue at "
            @"https://github.com/flutter/flutter/issues/new with the title "
            @"\"[in_app_purchase_storekit] "
            @"Unable to encode userInfo of type %@\" and add reproduction steps and the error "
            @"details in "
            @"the description field.",
            [value class], [value class]];
  }
}

+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront {
  if (!storefront) {
    return nil;
  }

  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"countryCode" : storefront.countryCode,
    @"identifier" : storefront.identifier
  }];

  return map;
}

+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront
                 andSKPaymentTransaction:(SKPaymentTransaction *)transaction {
  if (!storefront || !transaction) {
    return nil;
  }

  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"storefront" : [FIAObjectTranslator getMapFromSKStorefront:storefront],
    @"transaction" : [FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]
  }];

  return map;
}

+ (SKPaymentDiscount *)getSKPaymentDiscountFromMap:(NSDictionary *)map
                                         withError:(NSString **)error {
  if (!map || map.count <= 0) {
    return nil;
  }

  NSString *identifier = map[@"identifier"];
  NSString *keyIdentifier = map[@"keyIdentifier"];
  NSString *nonce = map[@"nonce"];
  NSString *signature = map[@"signature"];
  NSNumber *timestamp = map[@"timestamp"];

  if (!identifier || ![identifier isKindOfClass:NSString.class] ||
      [identifier isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'identifier' field is mandatory.";
    }
    return nil;
  }

  if (!keyIdentifier || ![keyIdentifier isKindOfClass:NSString.class] ||
      [keyIdentifier isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'keyIdentifier' field is mandatory.";
    }
    return nil;
  }

  if (!nonce || ![nonce isKindOfClass:NSString.class] || [nonce isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'nonce' field is mandatory.";
    }
    return nil;
  }

  if (!signature || ![signature isKindOfClass:NSString.class] || [signature isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'signature' field is mandatory.";
    }
    return nil;
  }

  if (!timestamp || ![timestamp isKindOfClass:NSNumber.class] || [timestamp longLongValue] <= 0) {
    if (error) {
      *error = @"When specifying a payment discount the 'timestamp' field is mandatory.";
    }
    return nil;
  }

  SKPaymentDiscount *discount =
      [[SKPaymentDiscount alloc] initWithIdentifier:identifier
                                      keyIdentifier:keyIdentifier
                                              nonce:[[NSUUID alloc] initWithUUIDString:nonce]
                                          signature:signature
                                          timestamp:timestamp];

  return discount;
}

+ (nullable FIASKPaymentTransactionMessage *)convertTransactionToPigeon:
    (nullable SKPaymentTransaction *)transaction API_AVAILABLE(ios(12.2)) {
  if (!transaction) {
    return nil;
  }
  return [FIASKPaymentTransactionMessage
            makeWithPayment:[self convertPaymentToPigeon:transaction.payment]
           transactionState:[self convertTransactionStateToPigeon:transaction.transactionState]
        originalTransaction:transaction.originalTransaction
                                ? [self convertTransactionToPigeon:transaction.originalTransaction]
                                : nil
       transactionTimeStamp:[NSNumber numberWithDouble:[transaction.transactionDate
                                                               timeIntervalSince1970]]
      transactionIdentifier:transaction.transactionIdentifier
                      error:[self convertSKErrorToPigeon:transaction.error]];
}

+ (nullable FIASKErrorMessage *)convertSKErrorToPigeon:(nullable NSError *)error {
  if (!error) {
    return nil;
  }

  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  for (NSErrorUserInfoKey key in error.userInfo) {
    id value = error.userInfo[key];
    userInfo[key] = [FIAObjectTranslator encodeNSErrorUserInfo:value];
  }

  return [FIASKErrorMessage makeWithCode:error.code domain:error.domain userInfo:userInfo];
}

+ (FIASKPaymentTransactionStateMessage)convertTransactionStateToPigeon:
    (SKPaymentTransactionState)state {
  switch (state) {
    case SKPaymentTransactionStatePurchasing:
      return FIASKPaymentTransactionStateMessagePurchasing;
    case SKPaymentTransactionStatePurchased:
      return FIASKPaymentTransactionStateMessagePurchased;
    case SKPaymentTransactionStateFailed:
      return FIASKPaymentTransactionStateMessageFailed;
    case SKPaymentTransactionStateRestored:
      return FIASKPaymentTransactionStateMessageRestored;
    case SKPaymentTransactionStateDeferred:
      return FIASKPaymentTransactionStateMessageDeferred;
  }
}

+ (nullable FIASKPaymentMessage *)convertPaymentToPigeon:(nullable SKPayment *)payment
    API_AVAILABLE(ios(12.2)) {
  if (!payment) {
    return nil;
  }
  return [FIASKPaymentMessage
       makeWithProductIdentifier:payment.productIdentifier
             applicationUsername:payment.applicationUsername
                     requestData:[[NSString alloc] initWithData:payment.requestData
                                                       encoding:NSUTF8StringEncoding]
                        quantity:payment.quantity
      simulatesAskToBuyInSandbox:payment.simulatesAskToBuyInSandbox
                 paymentDiscount:[self convertPaymentDiscountToPigeon:payment.paymentDiscount]];
}

+ (nullable FIASKPaymentDiscountMessage *)convertPaymentDiscountToPigeon:
    (nullable SKPaymentDiscount *)discount API_AVAILABLE(ios(12.2)) {
  if (!discount) {
    return nil;
  }
  return [FIASKPaymentDiscountMessage makeWithIdentifier:discount.identifier
                                           keyIdentifier:discount.keyIdentifier
                                                   nonce:[discount.nonce UUIDString]
                                               signature:discount.signature
                                               timestamp:[discount.timestamp intValue]];
}

+ (nullable FIASKStorefrontMessage *)convertStorefrontToPigeon:(nullable SKStorefront *)storefront
    API_AVAILABLE(ios(13.0)) {
  if (!storefront) {
    return nil;
  }
  return [FIASKStorefrontMessage makeWithCountryCode:storefront.countryCode
                                          identifier:storefront.identifier];
}

+ (nullable FIASKProductSubscriptionPeriodMessage *)convertSKProductSubscriptionPeriodToPigeon:
    (nullable SKProductSubscriptionPeriod *)period API_AVAILABLE(ios(12.2)) {
  if (!period) {
    return nil;
  }

  FIASKSubscriptionPeriodUnitMessage unit;
  switch (period.unit) {
    case SKProductPeriodUnitDay:
      unit = FIASKSubscriptionPeriodUnitMessageDay;
      break;
    case SKProductPeriodUnitWeek:
      unit = FIASKSubscriptionPeriodUnitMessageWeek;
      break;
    case SKProductPeriodUnitMonth:
      unit = FIASKSubscriptionPeriodUnitMessageMonth;
      break;
    case SKProductPeriodUnitYear:
      unit = FIASKSubscriptionPeriodUnitMessageYear;
      break;
  }

  return [FIASKProductSubscriptionPeriodMessage makeWithNumberOfUnits:period.numberOfUnits
                                                                 unit:unit];
}

+ (nullable FIASKProductDiscountMessage *)convertProductDiscountToPigeon:
    (nullable SKProductDiscount *)productDiscount API_AVAILABLE(ios(12.2)) {
  if (!productDiscount) {
    return nil;
  }

  FIASKProductDiscountPaymentModeMessage paymentMode;
  switch (productDiscount.paymentMode) {
    case SKProductDiscountPaymentModeFreeTrial:
      paymentMode = FIASKProductDiscountPaymentModeMessageFreeTrial;
      break;
    case SKProductDiscountPaymentModePayAsYouGo:
      paymentMode = FIASKProductDiscountPaymentModeMessagePayAsYouGo;
      break;
    case SKProductDiscountPaymentModePayUpFront:
      paymentMode = FIASKProductDiscountPaymentModeMessagePayUpFront;
      break;
  }

  FIASKProductDiscountTypeMessage type;
  switch (productDiscount.type) {
    case SKProductDiscountTypeIntroductory:
      type = FIASKProductDiscountTypeMessageIntroductory;
      break;
    case SKProductDiscountTypeSubscription:
      type = FIASKProductDiscountTypeMessageSubscription;
      break;
  }

  return [FIASKProductDiscountMessage
           makeWithPrice:productDiscount.price.description
             priceLocale:[self convertNSLocaleToPigeon:productDiscount.priceLocale]
         numberOfPeriods:productDiscount.numberOfPeriods
             paymentMode:paymentMode
      subscriptionPeriod:[self convertSKProductSubscriptionPeriodToPigeon:productDiscount
                                                                              .subscriptionPeriod]
              identifier:productDiscount.identifier
                    type:type];
}

+ (nullable FIASKPriceLocaleMessage *)convertNSLocaleToPigeon:(nullable NSLocale *)locale
    API_AVAILABLE(ios(12.2)) {
  if (!locale) {
    return nil;
  }
  return [FIASKPriceLocaleMessage makeWithCurrencySymbol:locale.currencySymbol
                                            currencyCode:locale.currencyCode
                                             countryCode:locale.countryCode];
}

+ (nullable FIASKProductMessage *)convertProductToPigeon:(nullable SKProduct *)product
    API_AVAILABLE(ios(12.2)) {
  if (!product) {
    return nil;
  }

  NSArray<SKProductDiscount *> *skProductDiscounts = product.discounts;
  NSMutableArray<FIASKProductDiscountMessage *> *pigeonProductDiscounts =
      [NSMutableArray arrayWithCapacity:skProductDiscounts.count];

  for (SKProductDiscount *productDiscount in skProductDiscounts) {
    [pigeonProductDiscounts addObject:[self convertProductDiscountToPigeon:productDiscount]];
  };

  return [FIASKProductMessage
        makeWithProductIdentifier:product.productIdentifier
                   localizedTitle:product.localizedTitle
             localizedDescription:product.localizedDescription
                      priceLocale:[self convertNSLocaleToPigeon:product.priceLocale]
      subscriptionGroupIdentifier:product.subscriptionGroupIdentifier
                            price:product.price.description
               subscriptionPeriod:
                   [self convertSKProductSubscriptionPeriodToPigeon:product.subscriptionPeriod]
                introductoryPrice:[self convertProductDiscountToPigeon:product.introductoryPrice]
                        discounts:pigeonProductDiscounts];
}

+ (nullable FIASKProductsResponseMessage *)convertProductsResponseToPigeon:
    (nullable SKProductsResponse *)productsResponse API_AVAILABLE(ios(12.2)) {
  if (!productsResponse) {
    return nil;
  }
  NSArray<SKProduct *> *skProducts = productsResponse.products;
  NSMutableArray<FIASKProductMessage *> *pigeonProducts =
      [NSMutableArray arrayWithCapacity:skProducts.count];

  for (SKProduct *product in skProducts) {
    [pigeonProducts addObject:[self convertProductToPigeon:product]];
  };

  return [FIASKProductsResponseMessage
               makeWithProducts:pigeonProducts
      invalidProductIdentifiers:productsResponse.invalidProductIdentifiers ?: @[]];
}

@end
