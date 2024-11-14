// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.6.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "messages.g.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSArray<id> *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}

static id GetNullableObjectAtIndex(NSArray<id> *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

@implementation FIASKPaymentTransactionStateMessageBox
- (instancetype)initWithValue:(FIASKPaymentTransactionStateMessage)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

@implementation FIASKProductDiscountTypeMessageBox
- (instancetype)initWithValue:(FIASKProductDiscountTypeMessage)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

@implementation FIASKProductDiscountPaymentModeMessageBox
- (instancetype)initWithValue:(FIASKProductDiscountPaymentModeMessage)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

@implementation FIASKSubscriptionPeriodUnitMessageBox
- (instancetype)initWithValue:(FIASKSubscriptionPeriodUnitMessage)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

@interface FIASKPaymentTransactionMessage ()
+ (FIASKPaymentTransactionMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKPaymentTransactionMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKPaymentMessage ()
+ (FIASKPaymentMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKPaymentMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKErrorMessage ()
+ (FIASKErrorMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKErrorMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKPaymentDiscountMessage ()
+ (FIASKPaymentDiscountMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKPaymentDiscountMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKStorefrontMessage ()
+ (FIASKStorefrontMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKStorefrontMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKProductsResponseMessage ()
+ (FIASKProductsResponseMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKProductsResponseMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKProductMessage ()
+ (FIASKProductMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKProductMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKPriceLocaleMessage ()
+ (FIASKPriceLocaleMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKPriceLocaleMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKProductDiscountMessage ()
+ (FIASKProductDiscountMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKProductDiscountMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface FIASKProductSubscriptionPeriodMessage ()
+ (FIASKProductSubscriptionPeriodMessage *)fromList:(NSArray<id> *)list;
+ (nullable FIASKProductSubscriptionPeriodMessage *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@implementation FIASKPaymentTransactionMessage
+ (instancetype)makeWithPayment:(FIASKPaymentMessage *)payment
    transactionState:(FIASKPaymentTransactionStateMessage)transactionState
    originalTransaction:(nullable FIASKPaymentTransactionMessage *)originalTransaction
    transactionTimeStamp:(nullable NSNumber *)transactionTimeStamp
    transactionIdentifier:(nullable NSString *)transactionIdentifier
    error:(nullable FIASKErrorMessage *)error {
  FIASKPaymentTransactionMessage* pigeonResult = [[FIASKPaymentTransactionMessage alloc] init];
  pigeonResult.payment = payment;
  pigeonResult.transactionState = transactionState;
  pigeonResult.originalTransaction = originalTransaction;
  pigeonResult.transactionTimeStamp = transactionTimeStamp;
  pigeonResult.transactionIdentifier = transactionIdentifier;
  pigeonResult.error = error;
  return pigeonResult;
}
+ (FIASKPaymentTransactionMessage *)fromList:(NSArray<id> *)list {
  FIASKPaymentTransactionMessage *pigeonResult = [[FIASKPaymentTransactionMessage alloc] init];
  pigeonResult.payment = GetNullableObjectAtIndex(list, 0);
  FIASKPaymentTransactionStateMessageBox *boxedFIASKPaymentTransactionStateMessage = GetNullableObjectAtIndex(list, 1);
  pigeonResult.transactionState = boxedFIASKPaymentTransactionStateMessage.value;
  pigeonResult.originalTransaction = GetNullableObjectAtIndex(list, 2);
  pigeonResult.transactionTimeStamp = GetNullableObjectAtIndex(list, 3);
  pigeonResult.transactionIdentifier = GetNullableObjectAtIndex(list, 4);
  pigeonResult.error = GetNullableObjectAtIndex(list, 5);
  return pigeonResult;
}
+ (nullable FIASKPaymentTransactionMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKPaymentTransactionMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.payment ?: [NSNull null],
    [[FIASKPaymentTransactionStateMessageBox alloc] initWithValue:self.transactionState],
    self.originalTransaction ?: [NSNull null],
    self.transactionTimeStamp ?: [NSNull null],
    self.transactionIdentifier ?: [NSNull null],
    self.error ?: [NSNull null],
  ];
}
@end

@implementation FIASKPaymentMessage
+ (instancetype)makeWithProductIdentifier:(NSString *)productIdentifier
    applicationUsername:(nullable NSString *)applicationUsername
    requestData:(nullable NSString *)requestData
    quantity:(NSInteger )quantity
    simulatesAskToBuyInSandbox:(BOOL )simulatesAskToBuyInSandbox
    paymentDiscount:(nullable FIASKPaymentDiscountMessage *)paymentDiscount {
  FIASKPaymentMessage* pigeonResult = [[FIASKPaymentMessage alloc] init];
  pigeonResult.productIdentifier = productIdentifier;
  pigeonResult.applicationUsername = applicationUsername;
  pigeonResult.requestData = requestData;
  pigeonResult.quantity = quantity;
  pigeonResult.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox;
  pigeonResult.paymentDiscount = paymentDiscount;
  return pigeonResult;
}
+ (FIASKPaymentMessage *)fromList:(NSArray<id> *)list {
  FIASKPaymentMessage *pigeonResult = [[FIASKPaymentMessage alloc] init];
  pigeonResult.productIdentifier = GetNullableObjectAtIndex(list, 0);
  pigeonResult.applicationUsername = GetNullableObjectAtIndex(list, 1);
  pigeonResult.requestData = GetNullableObjectAtIndex(list, 2);
  pigeonResult.quantity = [GetNullableObjectAtIndex(list, 3) integerValue];
  pigeonResult.simulatesAskToBuyInSandbox = [GetNullableObjectAtIndex(list, 4) boolValue];
  pigeonResult.paymentDiscount = GetNullableObjectAtIndex(list, 5);
  return pigeonResult;
}
+ (nullable FIASKPaymentMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKPaymentMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.productIdentifier ?: [NSNull null],
    self.applicationUsername ?: [NSNull null],
    self.requestData ?: [NSNull null],
    @(self.quantity),
    @(self.simulatesAskToBuyInSandbox),
    self.paymentDiscount ?: [NSNull null],
  ];
}
@end

@implementation FIASKErrorMessage
+ (instancetype)makeWithCode:(NSInteger )code
    domain:(NSString *)domain
    userInfo:(nullable NSDictionary<NSString *, id> *)userInfo {
  FIASKErrorMessage* pigeonResult = [[FIASKErrorMessage alloc] init];
  pigeonResult.code = code;
  pigeonResult.domain = domain;
  pigeonResult.userInfo = userInfo;
  return pigeonResult;
}
+ (FIASKErrorMessage *)fromList:(NSArray<id> *)list {
  FIASKErrorMessage *pigeonResult = [[FIASKErrorMessage alloc] init];
  pigeonResult.code = [GetNullableObjectAtIndex(list, 0) integerValue];
  pigeonResult.domain = GetNullableObjectAtIndex(list, 1);
  pigeonResult.userInfo = GetNullableObjectAtIndex(list, 2);
  return pigeonResult;
}
+ (nullable FIASKErrorMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKErrorMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    @(self.code),
    self.domain ?: [NSNull null],
    self.userInfo ?: [NSNull null],
  ];
}
@end

@implementation FIASKPaymentDiscountMessage
+ (instancetype)makeWithIdentifier:(NSString *)identifier
    keyIdentifier:(NSString *)keyIdentifier
    nonce:(NSString *)nonce
    signature:(NSString *)signature
    timestamp:(NSInteger )timestamp {
  FIASKPaymentDiscountMessage* pigeonResult = [[FIASKPaymentDiscountMessage alloc] init];
  pigeonResult.identifier = identifier;
  pigeonResult.keyIdentifier = keyIdentifier;
  pigeonResult.nonce = nonce;
  pigeonResult.signature = signature;
  pigeonResult.timestamp = timestamp;
  return pigeonResult;
}
+ (FIASKPaymentDiscountMessage *)fromList:(NSArray<id> *)list {
  FIASKPaymentDiscountMessage *pigeonResult = [[FIASKPaymentDiscountMessage alloc] init];
  pigeonResult.identifier = GetNullableObjectAtIndex(list, 0);
  pigeonResult.keyIdentifier = GetNullableObjectAtIndex(list, 1);
  pigeonResult.nonce = GetNullableObjectAtIndex(list, 2);
  pigeonResult.signature = GetNullableObjectAtIndex(list, 3);
  pigeonResult.timestamp = [GetNullableObjectAtIndex(list, 4) integerValue];
  return pigeonResult;
}
+ (nullable FIASKPaymentDiscountMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKPaymentDiscountMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.identifier ?: [NSNull null],
    self.keyIdentifier ?: [NSNull null],
    self.nonce ?: [NSNull null],
    self.signature ?: [NSNull null],
    @(self.timestamp),
  ];
}
@end

@implementation FIASKStorefrontMessage
+ (instancetype)makeWithCountryCode:(NSString *)countryCode
    identifier:(NSString *)identifier {
  FIASKStorefrontMessage* pigeonResult = [[FIASKStorefrontMessage alloc] init];
  pigeonResult.countryCode = countryCode;
  pigeonResult.identifier = identifier;
  return pigeonResult;
}
+ (FIASKStorefrontMessage *)fromList:(NSArray<id> *)list {
  FIASKStorefrontMessage *pigeonResult = [[FIASKStorefrontMessage alloc] init];
  pigeonResult.countryCode = GetNullableObjectAtIndex(list, 0);
  pigeonResult.identifier = GetNullableObjectAtIndex(list, 1);
  return pigeonResult;
}
+ (nullable FIASKStorefrontMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKStorefrontMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.countryCode ?: [NSNull null],
    self.identifier ?: [NSNull null],
  ];
}
@end

@implementation FIASKProductsResponseMessage
+ (instancetype)makeWithProducts:(nullable NSArray<FIASKProductMessage *> *)products
    invalidProductIdentifiers:(nullable NSArray<NSString *> *)invalidProductIdentifiers {
  FIASKProductsResponseMessage* pigeonResult = [[FIASKProductsResponseMessage alloc] init];
  pigeonResult.products = products;
  pigeonResult.invalidProductIdentifiers = invalidProductIdentifiers;
  return pigeonResult;
}
+ (FIASKProductsResponseMessage *)fromList:(NSArray<id> *)list {
  FIASKProductsResponseMessage *pigeonResult = [[FIASKProductsResponseMessage alloc] init];
  pigeonResult.products = GetNullableObjectAtIndex(list, 0);
  pigeonResult.invalidProductIdentifiers = GetNullableObjectAtIndex(list, 1);
  return pigeonResult;
}
+ (nullable FIASKProductsResponseMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKProductsResponseMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.products ?: [NSNull null],
    self.invalidProductIdentifiers ?: [NSNull null],
  ];
}
@end

@implementation FIASKProductMessage
+ (instancetype)makeWithProductIdentifier:(NSString *)productIdentifier
    localizedTitle:(NSString *)localizedTitle
    localizedDescription:(nullable NSString *)localizedDescription
    priceLocale:(FIASKPriceLocaleMessage *)priceLocale
    subscriptionGroupIdentifier:(nullable NSString *)subscriptionGroupIdentifier
    price:(NSString *)price
    subscriptionPeriod:(nullable FIASKProductSubscriptionPeriodMessage *)subscriptionPeriod
    introductoryPrice:(nullable FIASKProductDiscountMessage *)introductoryPrice
    discounts:(nullable NSArray<FIASKProductDiscountMessage *> *)discounts {
  FIASKProductMessage* pigeonResult = [[FIASKProductMessage alloc] init];
  pigeonResult.productIdentifier = productIdentifier;
  pigeonResult.localizedTitle = localizedTitle;
  pigeonResult.localizedDescription = localizedDescription;
  pigeonResult.priceLocale = priceLocale;
  pigeonResult.subscriptionGroupIdentifier = subscriptionGroupIdentifier;
  pigeonResult.price = price;
  pigeonResult.subscriptionPeriod = subscriptionPeriod;
  pigeonResult.introductoryPrice = introductoryPrice;
  pigeonResult.discounts = discounts;
  return pigeonResult;
}
+ (FIASKProductMessage *)fromList:(NSArray<id> *)list {
  FIASKProductMessage *pigeonResult = [[FIASKProductMessage alloc] init];
  pigeonResult.productIdentifier = GetNullableObjectAtIndex(list, 0);
  pigeonResult.localizedTitle = GetNullableObjectAtIndex(list, 1);
  pigeonResult.localizedDescription = GetNullableObjectAtIndex(list, 2);
  pigeonResult.priceLocale = GetNullableObjectAtIndex(list, 3);
  pigeonResult.subscriptionGroupIdentifier = GetNullableObjectAtIndex(list, 4);
  pigeonResult.price = GetNullableObjectAtIndex(list, 5);
  pigeonResult.subscriptionPeriod = GetNullableObjectAtIndex(list, 6);
  pigeonResult.introductoryPrice = GetNullableObjectAtIndex(list, 7);
  pigeonResult.discounts = GetNullableObjectAtIndex(list, 8);
  return pigeonResult;
}
+ (nullable FIASKProductMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKProductMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.productIdentifier ?: [NSNull null],
    self.localizedTitle ?: [NSNull null],
    self.localizedDescription ?: [NSNull null],
    self.priceLocale ?: [NSNull null],
    self.subscriptionGroupIdentifier ?: [NSNull null],
    self.price ?: [NSNull null],
    self.subscriptionPeriod ?: [NSNull null],
    self.introductoryPrice ?: [NSNull null],
    self.discounts ?: [NSNull null],
  ];
}
@end

@implementation FIASKPriceLocaleMessage
+ (instancetype)makeWithCurrencySymbol:(NSString *)currencySymbol
    currencyCode:(NSString *)currencyCode
    countryCode:(NSString *)countryCode {
  FIASKPriceLocaleMessage* pigeonResult = [[FIASKPriceLocaleMessage alloc] init];
  pigeonResult.currencySymbol = currencySymbol;
  pigeonResult.currencyCode = currencyCode;
  pigeonResult.countryCode = countryCode;
  return pigeonResult;
}
+ (FIASKPriceLocaleMessage *)fromList:(NSArray<id> *)list {
  FIASKPriceLocaleMessage *pigeonResult = [[FIASKPriceLocaleMessage alloc] init];
  pigeonResult.currencySymbol = GetNullableObjectAtIndex(list, 0);
  pigeonResult.currencyCode = GetNullableObjectAtIndex(list, 1);
  pigeonResult.countryCode = GetNullableObjectAtIndex(list, 2);
  return pigeonResult;
}
+ (nullable FIASKPriceLocaleMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKPriceLocaleMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.currencySymbol ?: [NSNull null],
    self.currencyCode ?: [NSNull null],
    self.countryCode ?: [NSNull null],
  ];
}
@end

@implementation FIASKProductDiscountMessage
+ (instancetype)makeWithPrice:(NSString *)price
    priceLocale:(FIASKPriceLocaleMessage *)priceLocale
    numberOfPeriods:(NSInteger )numberOfPeriods
    paymentMode:(FIASKProductDiscountPaymentModeMessage)paymentMode
    subscriptionPeriod:(FIASKProductSubscriptionPeriodMessage *)subscriptionPeriod
    identifier:(nullable NSString *)identifier
    type:(FIASKProductDiscountTypeMessage)type {
  FIASKProductDiscountMessage* pigeonResult = [[FIASKProductDiscountMessage alloc] init];
  pigeonResult.price = price;
  pigeonResult.priceLocale = priceLocale;
  pigeonResult.numberOfPeriods = numberOfPeriods;
  pigeonResult.paymentMode = paymentMode;
  pigeonResult.subscriptionPeriod = subscriptionPeriod;
  pigeonResult.identifier = identifier;
  pigeonResult.type = type;
  return pigeonResult;
}
+ (FIASKProductDiscountMessage *)fromList:(NSArray<id> *)list {
  FIASKProductDiscountMessage *pigeonResult = [[FIASKProductDiscountMessage alloc] init];
  pigeonResult.price = GetNullableObjectAtIndex(list, 0);
  pigeonResult.priceLocale = GetNullableObjectAtIndex(list, 1);
  pigeonResult.numberOfPeriods = [GetNullableObjectAtIndex(list, 2) integerValue];
  FIASKProductDiscountPaymentModeMessageBox *boxedFIASKProductDiscountPaymentModeMessage = GetNullableObjectAtIndex(list, 3);
  pigeonResult.paymentMode = boxedFIASKProductDiscountPaymentModeMessage.value;
  pigeonResult.subscriptionPeriod = GetNullableObjectAtIndex(list, 4);
  pigeonResult.identifier = GetNullableObjectAtIndex(list, 5);
  FIASKProductDiscountTypeMessageBox *boxedFIASKProductDiscountTypeMessage = GetNullableObjectAtIndex(list, 6);
  pigeonResult.type = boxedFIASKProductDiscountTypeMessage.value;
  return pigeonResult;
}
+ (nullable FIASKProductDiscountMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKProductDiscountMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    self.price ?: [NSNull null],
    self.priceLocale ?: [NSNull null],
    @(self.numberOfPeriods),
    [[FIASKProductDiscountPaymentModeMessageBox alloc] initWithValue:self.paymentMode],
    self.subscriptionPeriod ?: [NSNull null],
    self.identifier ?: [NSNull null],
    [[FIASKProductDiscountTypeMessageBox alloc] initWithValue:self.type],
  ];
}
@end

@implementation FIASKProductSubscriptionPeriodMessage
+ (instancetype)makeWithNumberOfUnits:(NSInteger )numberOfUnits
    unit:(FIASKSubscriptionPeriodUnitMessage)unit {
  FIASKProductSubscriptionPeriodMessage* pigeonResult = [[FIASKProductSubscriptionPeriodMessage alloc] init];
  pigeonResult.numberOfUnits = numberOfUnits;
  pigeonResult.unit = unit;
  return pigeonResult;
}
+ (FIASKProductSubscriptionPeriodMessage *)fromList:(NSArray<id> *)list {
  FIASKProductSubscriptionPeriodMessage *pigeonResult = [[FIASKProductSubscriptionPeriodMessage alloc] init];
  pigeonResult.numberOfUnits = [GetNullableObjectAtIndex(list, 0) integerValue];
  FIASKSubscriptionPeriodUnitMessageBox *boxedFIASKSubscriptionPeriodUnitMessage = GetNullableObjectAtIndex(list, 1);
  pigeonResult.unit = boxedFIASKSubscriptionPeriodUnitMessage.value;
  return pigeonResult;
}
+ (nullable FIASKProductSubscriptionPeriodMessage *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [FIASKProductSubscriptionPeriodMessage fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    @(self.numberOfUnits),
    [[FIASKSubscriptionPeriodUnitMessageBox alloc] initWithValue:self.unit],
  ];
}
@end

@interface FIAMessagesPigeonCodecReader : FlutterStandardReader
@end
@implementation FIAMessagesPigeonCodecReader
- (nullable id)readValueOfType:(UInt8)type {
  switch (type) {
    case 129: {
      NSNumber *enumAsNumber = [self readValue];
      return enumAsNumber == nil ? nil : [[FIASKPaymentTransactionStateMessageBox alloc] initWithValue:[enumAsNumber integerValue]];
    }
    case 130: {
      NSNumber *enumAsNumber = [self readValue];
      return enumAsNumber == nil ? nil : [[FIASKProductDiscountTypeMessageBox alloc] initWithValue:[enumAsNumber integerValue]];
    }
    case 131: {
      NSNumber *enumAsNumber = [self readValue];
      return enumAsNumber == nil ? nil : [[FIASKProductDiscountPaymentModeMessageBox alloc] initWithValue:[enumAsNumber integerValue]];
    }
    case 132: {
      NSNumber *enumAsNumber = [self readValue];
      return enumAsNumber == nil ? nil : [[FIASKSubscriptionPeriodUnitMessageBox alloc] initWithValue:[enumAsNumber integerValue]];
    }
    case 133: 
      return [FIASKPaymentTransactionMessage fromList:[self readValue]];
    case 134: 
      return [FIASKPaymentMessage fromList:[self readValue]];
    case 135: 
      return [FIASKErrorMessage fromList:[self readValue]];
    case 136: 
      return [FIASKPaymentDiscountMessage fromList:[self readValue]];
    case 137: 
      return [FIASKStorefrontMessage fromList:[self readValue]];
    case 138: 
      return [FIASKProductsResponseMessage fromList:[self readValue]];
    case 139: 
      return [FIASKProductMessage fromList:[self readValue]];
    case 140: 
      return [FIASKPriceLocaleMessage fromList:[self readValue]];
    case 141: 
      return [FIASKProductDiscountMessage fromList:[self readValue]];
    case 142: 
      return [FIASKProductSubscriptionPeriodMessage fromList:[self readValue]];
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface FIAMessagesPigeonCodecWriter : FlutterStandardWriter
@end
@implementation FIAMessagesPigeonCodecWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[FIASKPaymentTransactionStateMessageBox class]]) {
    FIASKPaymentTransactionStateMessageBox *box = (FIASKPaymentTransactionStateMessageBox *)value;
    [self writeByte:129];
    [self writeValue:(value == nil ? [NSNull null] : [NSNumber numberWithInteger:box.value])];
  } else if ([value isKindOfClass:[FIASKProductDiscountTypeMessageBox class]]) {
    FIASKProductDiscountTypeMessageBox *box = (FIASKProductDiscountTypeMessageBox *)value;
    [self writeByte:130];
    [self writeValue:(value == nil ? [NSNull null] : [NSNumber numberWithInteger:box.value])];
  } else if ([value isKindOfClass:[FIASKProductDiscountPaymentModeMessageBox class]]) {
    FIASKProductDiscountPaymentModeMessageBox *box = (FIASKProductDiscountPaymentModeMessageBox *)value;
    [self writeByte:131];
    [self writeValue:(value == nil ? [NSNull null] : [NSNumber numberWithInteger:box.value])];
  } else if ([value isKindOfClass:[FIASKSubscriptionPeriodUnitMessageBox class]]) {
    FIASKSubscriptionPeriodUnitMessageBox *box = (FIASKSubscriptionPeriodUnitMessageBox *)value;
    [self writeByte:132];
    [self writeValue:(value == nil ? [NSNull null] : [NSNumber numberWithInteger:box.value])];
  } else if ([value isKindOfClass:[FIASKPaymentTransactionMessage class]]) {
    [self writeByte:133];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKPaymentMessage class]]) {
    [self writeByte:134];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKErrorMessage class]]) {
    [self writeByte:135];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKPaymentDiscountMessage class]]) {
    [self writeByte:136];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKStorefrontMessage class]]) {
    [self writeByte:137];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKProductsResponseMessage class]]) {
    [self writeByte:138];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKProductMessage class]]) {
    [self writeByte:139];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKPriceLocaleMessage class]]) {
    [self writeByte:140];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKProductDiscountMessage class]]) {
    [self writeByte:141];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[FIASKProductSubscriptionPeriodMessage class]]) {
    [self writeByte:142];
    [self writeValue:[value toList]];
  } else {
    [super writeValue:value];
  }
}
@end

@interface FIAMessagesPigeonCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FIAMessagesPigeonCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FIAMessagesPigeonCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FIAMessagesPigeonCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FIAGetMessagesCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    FIAMessagesPigeonCodecReaderWriter *readerWriter = [[FIAMessagesPigeonCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}
void SetUpFIAInAppPurchaseAPI(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FIAInAppPurchaseAPI> *api) {
  SetUpFIAInAppPurchaseAPIWithSuffix(binaryMessenger, api, @"");
}

void SetUpFIAInAppPurchaseAPIWithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FIAInAppPurchaseAPI> *api, NSString *messageChannelSuffix) {
  messageChannelSuffix = messageChannelSuffix.length > 0 ? [NSString stringWithFormat: @".%@", messageChannelSuffix] : @"";
  /// Returns if the current device is able to make payments
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.canMakePayments", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(canMakePaymentsWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(canMakePaymentsWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSNumber *output = [api canMakePaymentsWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.transactions", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(transactionsWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(transactionsWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSArray<FIASKPaymentTransactionMessage *> *output = [api transactionsWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.storefront", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(storefrontWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(storefrontWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        FIASKStorefrontMessage *output = [api storefrontWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.addPayment", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(addPaymentPaymentMap:error:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(addPaymentPaymentMap:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSDictionary<NSString *, id> *arg_paymentMap = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api addPaymentPaymentMap:arg_paymentMap error:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.startProductRequest", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startProductRequestProductIdentifiers:completion:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(startProductRequestProductIdentifiers:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSArray<NSString *> *arg_productIdentifiers = GetNullableObjectAtIndex(args, 0);
        [api startProductRequestProductIdentifiers:arg_productIdentifiers completion:^(FIASKProductsResponseMessage *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.finishTransaction", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(finishTransactionFinishMap:error:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(finishTransactionFinishMap:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSDictionary<NSString *, id> *arg_finishMap = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api finishTransactionFinishMap:arg_finishMap error:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.restoreTransactions", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(restoreTransactionsApplicationUserName:error:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(restoreTransactionsApplicationUserName:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSString *arg_applicationUserName = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api restoreTransactionsApplicationUserName:arg_applicationUserName error:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.presentCodeRedemptionSheet", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(presentCodeRedemptionSheetWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(presentCodeRedemptionSheetWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api presentCodeRedemptionSheetWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.retrieveReceiptData", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(retrieveReceiptDataWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(retrieveReceiptDataWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSString *output = [api retrieveReceiptDataWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.refreshReceipt", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(refreshReceiptReceiptProperties:completion:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(refreshReceiptReceiptProperties:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSDictionary<NSString *, id> *arg_receiptProperties = GetNullableObjectAtIndex(args, 0);
        [api refreshReceiptReceiptProperties:arg_receiptProperties completion:^(FlutterError *_Nullable error) {
          callback(wrapResult(nil, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.startObservingPaymentQueue", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startObservingPaymentQueueWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(startObservingPaymentQueueWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api startObservingPaymentQueueWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.stopObservingPaymentQueue", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(stopObservingPaymentQueueWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(stopObservingPaymentQueueWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api stopObservingPaymentQueueWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.registerPaymentQueueDelegate", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(registerPaymentQueueDelegateWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(registerPaymentQueueDelegateWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api registerPaymentQueueDelegateWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.removePaymentQueueDelegate", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(removePaymentQueueDelegateWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(removePaymentQueueDelegateWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api removePaymentQueueDelegateWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.showPriceConsentIfNeeded", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(showPriceConsentIfNeededWithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(showPriceConsentIfNeededWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api showPriceConsentIfNeededWithError:&error];
        callback(wrapResult(nil, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.supportsStoreKit2", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:FIAGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(supportsStoreKit2WithError:)], @"FIAInAppPurchaseAPI api (%@) doesn't respond to @selector(supportsStoreKit2WithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSNumber *output = [api supportsStoreKit2WithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
