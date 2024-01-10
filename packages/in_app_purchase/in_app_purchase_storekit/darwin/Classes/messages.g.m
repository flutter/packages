// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v14.0.1), do not edit directly.
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

static NSArray *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}

static id GetNullableObjectAtIndex(NSArray *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

@implementation PaymentTransactionStateWrapperBox
- (instancetype)initWithValue:(PaymentTransactionStateWrapper)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

@interface StoreKitPaymentTransactionWrapper ()
+ (StoreKitPaymentTransactionWrapper *)fromList:(NSArray *)list;
+ (nullable StoreKitPaymentTransactionWrapper *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@interface PaymentWrapper ()
+ (PaymentWrapper *)fromList:(NSArray *)list;
+ (nullable PaymentWrapper *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@interface ErrorWrapper ()
+ (ErrorWrapper *)fromList:(NSArray *)list;
+ (nullable ErrorWrapper *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@interface PaymentDiscountWrapper ()
+ (PaymentDiscountWrapper *)fromList:(NSArray *)list;
+ (nullable PaymentDiscountWrapper *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@interface StoreKitStorefrontWrapper ()
+ (StoreKitStorefrontWrapper *)fromList:(NSArray *)list;
+ (nullable StoreKitStorefrontWrapper *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@implementation StoreKitPaymentTransactionWrapper
+ (instancetype)makeWithPayment:(PaymentWrapper *)payment
    transactionState:(PaymentTransactionStateWrapper)transactionState
    originalTransaction:(nullable StoreKitPaymentTransactionWrapper *)originalTransaction
    transactionTimeStamp:(nullable NSNumber *)transactionTimeStamp
    transactionIdentifier:(nullable NSString *)transactionIdentifier
    error:(nullable ErrorWrapper *)error {
  StoreKitPaymentTransactionWrapper* pigeonResult = [[StoreKitPaymentTransactionWrapper alloc] init];
  pigeonResult.payment = payment;
  pigeonResult.transactionState = transactionState;
  pigeonResult.originalTransaction = originalTransaction;
  pigeonResult.transactionTimeStamp = transactionTimeStamp;
  pigeonResult.transactionIdentifier = transactionIdentifier;
  pigeonResult.error = error;
  return pigeonResult;
}
+ (StoreKitPaymentTransactionWrapper *)fromList:(NSArray *)list {
  StoreKitPaymentTransactionWrapper *pigeonResult = [[StoreKitPaymentTransactionWrapper alloc] init];
  pigeonResult.payment = [PaymentWrapper nullableFromList:(GetNullableObjectAtIndex(list, 0))];
  pigeonResult.transactionState = [GetNullableObjectAtIndex(list, 1) integerValue];
  pigeonResult.originalTransaction = [StoreKitPaymentTransactionWrapper nullableFromList:(GetNullableObjectAtIndex(list, 2))];
  pigeonResult.transactionTimeStamp = GetNullableObjectAtIndex(list, 3);
  pigeonResult.transactionIdentifier = GetNullableObjectAtIndex(list, 4);
  pigeonResult.error = [ErrorWrapper nullableFromList:(GetNullableObjectAtIndex(list, 5))];
  return pigeonResult;
}
+ (nullable StoreKitPaymentTransactionWrapper *)nullableFromList:(NSArray *)list {
  return (list) ? [StoreKitPaymentTransactionWrapper fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    (self.payment ? [self.payment toList] : [NSNull null]),
    @(self.transactionState),
    (self.originalTransaction ? [self.originalTransaction toList] : [NSNull null]),
    self.transactionTimeStamp ?: [NSNull null],
    self.transactionIdentifier ?: [NSNull null],
    (self.error ? [self.error toList] : [NSNull null]),
  ];
}
@end

@implementation PaymentWrapper
+ (instancetype)makeWithProductIdentifier:(NSString *)productIdentifier
    applicationUsername:(nullable NSString *)applicationUsername
    requestData:(nullable NSString *)requestData
    quantity:(NSInteger )quantity
    simulatesAskToBuyInSandbox:(BOOL )simulatesAskToBuyInSandbox
    paymentDiscount:(nullable PaymentDiscountWrapper *)paymentDiscount {
  PaymentWrapper* pigeonResult = [[PaymentWrapper alloc] init];
  pigeonResult.productIdentifier = productIdentifier;
  pigeonResult.applicationUsername = applicationUsername;
  pigeonResult.requestData = requestData;
  pigeonResult.quantity = quantity;
  pigeonResult.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox;
  pigeonResult.paymentDiscount = paymentDiscount;
  return pigeonResult;
}
+ (PaymentWrapper *)fromList:(NSArray *)list {
  PaymentWrapper *pigeonResult = [[PaymentWrapper alloc] init];
  pigeonResult.productIdentifier = GetNullableObjectAtIndex(list, 0);
  pigeonResult.applicationUsername = GetNullableObjectAtIndex(list, 1);
  pigeonResult.requestData = GetNullableObjectAtIndex(list, 2);
  pigeonResult.quantity = [GetNullableObjectAtIndex(list, 3) integerValue];
  pigeonResult.simulatesAskToBuyInSandbox = [GetNullableObjectAtIndex(list, 4) boolValue];
  pigeonResult.paymentDiscount = [PaymentDiscountWrapper nullableFromList:(GetNullableObjectAtIndex(list, 5))];
  return pigeonResult;
}
+ (nullable PaymentWrapper *)nullableFromList:(NSArray *)list {
  return (list) ? [PaymentWrapper fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    self.productIdentifier ?: [NSNull null],
    self.applicationUsername ?: [NSNull null],
    self.requestData ?: [NSNull null],
    @(self.quantity),
    @(self.simulatesAskToBuyInSandbox),
    (self.paymentDiscount ? [self.paymentDiscount toList] : [NSNull null]),
  ];
}
@end

@implementation ErrorWrapper
+ (instancetype)makeWithCode:(NSInteger )code
    domain:(NSString *)domain
    userInfo:(NSDictionary<NSString *, id> *)userInfo {
  ErrorWrapper* pigeonResult = [[ErrorWrapper alloc] init];
  pigeonResult.code = code;
  pigeonResult.domain = domain;
  pigeonResult.userInfo = userInfo;
  return pigeonResult;
}
+ (ErrorWrapper *)fromList:(NSArray *)list {
  ErrorWrapper *pigeonResult = [[ErrorWrapper alloc] init];
  pigeonResult.code = [GetNullableObjectAtIndex(list, 0) integerValue];
  pigeonResult.domain = GetNullableObjectAtIndex(list, 1);
  pigeonResult.userInfo = GetNullableObjectAtIndex(list, 2);
  return pigeonResult;
}
+ (nullable ErrorWrapper *)nullableFromList:(NSArray *)list {
  return (list) ? [ErrorWrapper fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    @(self.code),
    self.domain ?: [NSNull null],
    self.userInfo ?: [NSNull null],
  ];
}
@end

@implementation PaymentDiscountWrapper
+ (instancetype)makeWithIdentifier:(NSString *)identifier
    keyIdentifier:(NSString *)keyIdentifier
    nonce:(NSString *)nonce
    signature:(NSString *)signature
    timestamp:(NSInteger )timestamp {
  PaymentDiscountWrapper* pigeonResult = [[PaymentDiscountWrapper alloc] init];
  pigeonResult.identifier = identifier;
  pigeonResult.keyIdentifier = keyIdentifier;
  pigeonResult.nonce = nonce;
  pigeonResult.signature = signature;
  pigeonResult.timestamp = timestamp;
  return pigeonResult;
}
+ (PaymentDiscountWrapper *)fromList:(NSArray *)list {
  PaymentDiscountWrapper *pigeonResult = [[PaymentDiscountWrapper alloc] init];
  pigeonResult.identifier = GetNullableObjectAtIndex(list, 0);
  pigeonResult.keyIdentifier = GetNullableObjectAtIndex(list, 1);
  pigeonResult.nonce = GetNullableObjectAtIndex(list, 2);
  pigeonResult.signature = GetNullableObjectAtIndex(list, 3);
  pigeonResult.timestamp = [GetNullableObjectAtIndex(list, 4) integerValue];
  return pigeonResult;
}
+ (nullable PaymentDiscountWrapper *)nullableFromList:(NSArray *)list {
  return (list) ? [PaymentDiscountWrapper fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    self.identifier ?: [NSNull null],
    self.keyIdentifier ?: [NSNull null],
    self.nonce ?: [NSNull null],
    self.signature ?: [NSNull null],
    @(self.timestamp),
  ];
}
@end

@implementation StoreKitStorefrontWrapper
+ (instancetype)makeWithCountryCode:(NSString *)countryCode
    identifier:(NSString *)identifier {
  StoreKitStorefrontWrapper* pigeonResult = [[StoreKitStorefrontWrapper alloc] init];
  pigeonResult.countryCode = countryCode;
  pigeonResult.identifier = identifier;
  return pigeonResult;
}
+ (StoreKitStorefrontWrapper *)fromList:(NSArray *)list {
  StoreKitStorefrontWrapper *pigeonResult = [[StoreKitStorefrontWrapper alloc] init];
  pigeonResult.countryCode = GetNullableObjectAtIndex(list, 0);
  pigeonResult.identifier = GetNullableObjectAtIndex(list, 1);
  return pigeonResult;
}
+ (nullable StoreKitStorefrontWrapper *)nullableFromList:(NSArray *)list {
  return (list) ? [StoreKitStorefrontWrapper fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    self.countryCode ?: [NSNull null],
    self.identifier ?: [NSNull null],
  ];
}
@end

@interface InAppPurchaseAPICodecReader : FlutterStandardReader
@end
@implementation InAppPurchaseAPICodecReader
- (nullable id)readValueOfType:(UInt8)type {
  switch (type) {
    case 128: 
      return [ErrorWrapper fromList:[self readValue]];
    case 129: 
      return [PaymentDiscountWrapper fromList:[self readValue]];
    case 130: 
      return [PaymentWrapper fromList:[self readValue]];
    case 131: 
      return [StoreKitPaymentTransactionWrapper fromList:[self readValue]];
    case 132: 
      return [StoreKitStorefrontWrapper fromList:[self readValue]];
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface InAppPurchaseAPICodecWriter : FlutterStandardWriter
@end
@implementation InAppPurchaseAPICodecWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[ErrorWrapper class]]) {
    [self writeByte:128];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[PaymentDiscountWrapper class]]) {
    [self writeByte:129];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[PaymentWrapper class]]) {
    [self writeByte:130];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[StoreKitPaymentTransactionWrapper class]]) {
    [self writeByte:131];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[StoreKitStorefrontWrapper class]]) {
    [self writeByte:132];
    [self writeValue:[value toList]];
  } else {
    [super writeValue:value];
  }
}
@end

@interface InAppPurchaseAPICodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation InAppPurchaseAPICodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[InAppPurchaseAPICodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[InAppPurchaseAPICodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *InAppPurchaseAPIGetCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    InAppPurchaseAPICodecReaderWriter *readerWriter = [[InAppPurchaseAPICodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}

void SetUpInAppPurchaseAPI(id<FlutterBinaryMessenger> binaryMessenger, NSObject<InAppPurchaseAPI> *api) {
  /// Returns if the current device is able to make payments
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.canMakePayments"
        binaryMessenger:binaryMessenger
        codec:InAppPurchaseAPIGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(canMakePaymentsWithError:)], @"InAppPurchaseAPI api (%@) doesn't respond to @selector(canMakePaymentsWithError:)", api);
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
        initWithName:@"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.transactions"
        binaryMessenger:binaryMessenger
        codec:InAppPurchaseAPIGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(transactionsWithError:)], @"InAppPurchaseAPI api (%@) doesn't respond to @selector(transactionsWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSArray<StoreKitPaymentTransactionWrapper *> *output = [api transactionsWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchaseAPI.storefront"
        binaryMessenger:binaryMessenger
        codec:InAppPurchaseAPIGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(storefrontWithError:)], @"InAppPurchaseAPI api (%@) doesn't respond to @selector(storefrontWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        StoreKitStorefrontWrapper *output = [api storefrontWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
