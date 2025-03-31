// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Stubs.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

@implementation SKProductSubscriptionPeriodStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"numberOfUnits"] ?: @(0) forKey:@"numberOfUnits"];
    [self setValue:map[@"unit"] ?: @(0) forKey:@"unit"];
  }
  return self;
}

@end

@implementation SKProductDiscountStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:[[NSDecimalNumber alloc] initWithString:map[@"price"]] ?: [NSNull null]
            forKey:@"price"];
    NSLocale *locale = NSLocale.systemLocale;
    [self setValue:locale ?: [NSNull null] forKey:@"priceLocale"];
    [self setValue:map[@"numberOfPeriods"] ?: @(0) forKey:@"numberOfPeriods"];
    SKProductSubscriptionPeriodStub *subscriptionPeriodSub =
        [[SKProductSubscriptionPeriodStub alloc] initWithMap:map[@"subscriptionPeriod"]];
    [self setValue:subscriptionPeriodSub forKey:@"subscriptionPeriod"];
    [self setValue:map[@"paymentMode"] ?: @(0) forKey:@"paymentMode"];
    if (@available(iOS 12.2, *)) {
      [self setValue:map[@"identifier"] ?: [NSNull null] forKey:@"identifier"];
      [self setValue:map[@"type"] ?: @(0) forKey:@"type"];
    }
  }
  return self;
}

@end

@implementation SKProductStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"productIdentifier"] ?: [NSNull null] forKey:@"productIdentifier"];
    [self setValue:map[@"localizedDescription"] ?: [NSNull null] forKey:@"localizedDescription"];
    [self setValue:map[@"localizedTitle"] ?: [NSNull null] forKey:@"localizedTitle"];
    [self setValue:map[@"downloadable"] ?: @NO forKey:@"downloadable"];
    [self setValue:[[NSDecimalNumber alloc] initWithString:map[@"price"]] ?: [NSNull null]
            forKey:@"price"];
    NSLocale *locale = NSLocale.systemLocale;
    [self setValue:locale ?: [NSNull null] forKey:@"priceLocale"];
    [self setValue:map[@"downloadContentLengths"] ?: @(0) forKey:@"downloadContentLengths"];
    SKProductSubscriptionPeriodStub *period =
        [[SKProductSubscriptionPeriodStub alloc] initWithMap:map[@"subscriptionPeriod"]];
    [self setValue:period ?: [NSNull null] forKey:@"subscriptionPeriod"];
    SKProductDiscountStub *discount =
        [[SKProductDiscountStub alloc] initWithMap:map[@"introductoryPrice"]];
    [self setValue:discount ?: [NSNull null] forKey:@"introductoryPrice"];
    [self setValue:map[@"subscriptionGroupIdentifier"] ?: [NSNull null]
            forKey:@"subscriptionGroupIdentifier"];
    if (@available(iOS 12.2, *)) {
      NSMutableArray *discounts = [[NSMutableArray alloc] init];
      for (NSDictionary *discountMap in map[@"discounts"]) {
        [discounts addObject:[[SKProductDiscountStub alloc] initWithMap:discountMap]];
      }

      [self setValue:discounts forKey:@"discounts"];
    }
  }
  return self;
}

- (instancetype)initWithProductID:(NSString *)productIdentifier {
  self = [super init];
  if (self) {
    [self setValue:productIdentifier forKey:@"productIdentifier"];
  }
  return self;
}

@end

@interface SKProductRequestStub ()

@property(nonatomic, strong) NSSet *identifers;
@property(nonatomic, strong) NSError *error;

@end

@implementation SKProductRequestStub

- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers {
  self = [super initWithProductIdentifiers:productIdentifiers];
  self.identifers = productIdentifiers;
  return self;
}

- (instancetype)initWithFailureError:(NSError *)error {
  self = [super init];
  self.error = error;
  return self;
}

- (void)start {
  NSMutableArray *productArray = [NSMutableArray new];
  for (NSString *identifier in self.identifers) {
    [productArray addObject:@{@"productIdentifier" : identifier}];
  }
  SKProductsResponseStub *response;
  if (self.returnError) {
    response = nil;
  } else {
    response = [[SKProductsResponseStub alloc] initWithMap:@{@"products" : productArray}];
  }

  if (self.error) {
    [self.delegate request:self didFailWithError:self.error];
  } else {
    [self.delegate productsRequest:self didReceiveResponse:response];
  }
}

@end

@implementation SKProductsResponseStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    NSMutableArray *products = [NSMutableArray new];
    for (NSDictionary *productMap in map[@"products"]) {
      SKProductStub *product = [[SKProductStub alloc] initWithMap:productMap];
      [products addObject:product];
    }
    [self setValue:products forKey:@"products"];
  }
  return self;
}

@end

@interface SKPaymentQueueStub ()

@end

@implementation SKPaymentQueueStub

- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = observer;
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = nil;
}

- (void)addPayment:(SKPayment *)payment {
  SKPaymentTransactionStub *transaction =
      [[SKPaymentTransactionStub alloc] initWithState:self.testState payment:payment];
  [self.observer paymentQueue:self updatedTransactions:@[ transaction ]];
}

- (void)restoreCompletedTransactions {
  if ([self.observer
          respondsToSelector:@selector(paymentQueueRestoreCompletedTransactionsFinished:)]) {
    [self.observer paymentQueueRestoreCompletedTransactionsFinished:self];
  }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  if ([self.observer respondsToSelector:@selector(paymentQueue:removedTransactions:)]) {
    [self.observer paymentQueue:self removedTransactions:@[ transaction ]];
  }
}

@end

@implementation SKPaymentTransactionStub {
  SKPayment *_payment;
}

- (instancetype)initWithID:(NSString *)identifier {
  self = [super init];
  if (self) {
    [self setValue:identifier forKey:@"transactionIdentifier"];
  }
  return self;
}

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"transactionIdentifier"] forKey:@"transactionIdentifier"];
    [self setValue:map[@"transactionState"] forKey:@"transactionState"];
    if (![map[@"originalTransaction"] isKindOfClass:[NSNull class]] &&
        map[@"originalTransaction"]) {
      [self setValue:[[SKPaymentTransactionStub alloc] initWithMap:map[@"originalTransaction"]]
              forKey:@"originalTransaction"];
    }
    [self setValue:map[@"error"] ? [[NSErrorStub alloc] initWithMap:map[@"error"]] : [NSNull null]
            forKey:@"error"];
    [self setValue:[NSDate dateWithTimeIntervalSince1970:[map[@"transactionTimeStamp"] doubleValue]]
            forKey:@"transactionDate"];
  }
  return self;
}

- (instancetype)initWithState:(SKPaymentTransactionState)state {
  self = [super init];
  if (self) {
    // Only purchased and restored transactions have transactionIdentifier:
    // https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc
    if (state == SKPaymentTransactionStatePurchased || state == SKPaymentTransactionStateRestored) {
      [self setValue:@"fakeID" forKey:@"transactionIdentifier"];
    }
    [self setValue:@(state) forKey:@"transactionState"];
  }
  return self;
}

- (instancetype)initWithState:(SKPaymentTransactionState)state payment:(SKPayment *)payment {
  self = [super init];
  if (self) {
    // Only purchased and restored transactions have transactionIdentifier:
    // https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc
    if (state == SKPaymentTransactionStatePurchased || state == SKPaymentTransactionStateRestored) {
      [self setValue:@"fakeID" forKey:@"transactionIdentifier"];
    }
    [self setValue:@(state) forKey:@"transactionState"];
    _payment = payment;
  }
  return self;
}

- (SKPayment *)payment {
  return _payment;
}

@end

@implementation NSErrorStub

- (instancetype)initWithMap:(NSDictionary *)map {
  return [self initWithDomain:[map objectForKey:@"domain"]
                         code:[[map objectForKey:@"code"] integerValue]
                     userInfo:[map objectForKey:@"userInfo"]];
}

@end

@implementation FIAPReceiptManagerStub : FIAPReceiptManager

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  if (self.returnError) {
    *error = [NSError errorWithDomain:@"test"
                                 code:1
                             userInfo:@{
                               @"name" : @"test",
                               @"houseNr" : @5,
                               @"error" : [[NSError alloc] initWithDomain:@"internalTestDomain"
                                                                     code:99
                                                                 userInfo:nil]
                             }];
    return nil;
  }
  NSString *originalString = [NSString stringWithFormat:@"test"];
  return [[NSData alloc] initWithBase64EncodedString:originalString options:kNilOptions];
}

- (NSURL *)receiptURL {
  if (self.returnNilURL) {
    return nil;
  } else {
    return [[NSBundle mainBundle] appStoreReceiptURL];
  }
}

@end

@implementation SKReceiptRefreshRequestStub {
  NSError *_error;
}

- (instancetype)initWithReceiptProperties:(NSDictionary<NSString *, id> *)properties {
  self = [super initWithReceiptProperties:properties];
  return self;
}

- (instancetype)initWithFailureError:(NSError *)error {
  self = [super init];
  _error = error;
  return self;
}

- (void)start {
  if (_error) {
    [self.delegate request:self didFailWithError:_error];
  } else {
    [self.delegate requestDidFinish:self];
  }
}

@end

@implementation SKStorefrontStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    // Set stub values
    [self setValue:map[@"countryCode"] forKey:@"countryCode"];
    [self setValue:map[@"identifier"] forKey:@"identifier"];
  }
  return self;
}
@end

@implementation PaymentQueueStub

@synthesize transactions;
@synthesize delegate;

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  [self.observer paymentQueue:self.realQueue removedTransactions:@[ transaction ]];
}

- (void)addPayment:(SKPayment *_Nonnull)payment {
  SKPaymentTransactionStub *transaction =
      [[SKPaymentTransactionStub alloc] initWithState:self.testState payment:payment];
  [self.observer paymentQueue:self.realQueue updatedTransactions:@[ transaction ]];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  self.observer = observer;
}

- (void)restoreCompletedTransactions {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (NSArray<SKPaymentTransaction *> *_Nonnull)getUnfinishedTransactions {
  if (self.getUnfinishedTransactionsStub) {
    return self.getUnfinishedTransactionsStub();
  } else {
    return @[];
  }
}

#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet {
  if (self.presentCodeRedemptionSheetStub) {
    self.presentCodeRedemptionSheetStub();
  }
}
#endif

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}
#endif

- (void)restoreTransactions:(nullable NSString *)applicationName {
  if (self.restoreTransactionsStub) {
    self.restoreTransactionsStub(applicationName);
  }
}

- (void)startObservingPaymentQueue {
  if (self.startObservingPaymentQueueStub) {
    self.startObservingPaymentQueueStub();
  }
}

- (void)stopObservingPaymentQueue {
  if (self.stopObservingPaymentQueueStub) {
    self.stopObservingPaymentQueueStub();
  }
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = nil;
}
@end

@implementation MethodChannelStub
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  if (self.invokeMethodChannelStub) {
    self.invokeMethodChannelStub(method, arguments);
  }
}

- (void)invokeMethod:(nonnull NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  if (self.invokeMethodChannelWithResultsStub) {
    self.invokeMethodChannelWithResultsStub(method, arguments, callback);
  }
}

@end

@implementation TransactionCacheStub
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  if (self.addObjectsStub) {
    self.addObjectsStub(objects, key);
  }
}

- (void)clear {
  if (self.clearStub) {
    self.clearStub();
  }
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  if (self.getObjectsForKeyStub) {
    return self.getObjectsForKeyStub(key);
  }
  return @[];
}
@end

@implementation PaymentQueueHandlerStub

@synthesize storefront;
@synthesize delegate;

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue
    updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
  if (self.paymentQueueUpdatedTransactionsStub) {
    self.paymentQueueUpdatedTransactionsStub(queue, transactions);
  }
}

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}
#endif

- (BOOL)addPayment:(nonnull SKPayment *)payment {
  if (self.addPaymentStub) {
    return self.addPaymentStub(payment);
  } else {
    return NO;
  }
}

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {
  if (self.finishTransactionStub) {
    self.finishTransactionStub(transaction);
  }
}

- (nonnull NSArray<SKPaymentTransaction *> *)getUnfinishedTransactions {
  if (self.getUnfinishedTransactionsStub) {
    return self.getUnfinishedTransactionsStub();
  } else {
    return @[];
  }
}

- (nonnull instancetype)initWithQueue:(nonnull id<FLTPaymentQueueProtocol>)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads
                        transactionCache:(nonnull id<FLTTransactionCacheProtocol>)transactionCache {
  return [[PaymentQueueHandlerStub alloc] init];
}

#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet {
  if (self.presentCodeRedemptionSheetStub) {
    self.presentCodeRedemptionSheetStub();
  }
}
#endif

- (void)restoreTransactions:(nullable NSString *)applicationName {
  if (self.restoreTransactions) {
    self.restoreTransactions(applicationName);
  }
}

- (void)startObservingPaymentQueue {
  if (self.startObservingPaymentQueueStub) {
    self.startObservingPaymentQueueStub();
  }
}

- (void)stopObservingPaymentQueue {
  if (self.stopObservingPaymentQueueStub) {
    self.stopObservingPaymentQueueStub();
  }
}

- (nonnull instancetype)initWithQueue:(nonnull id<FLTPaymentQueueProtocol>)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads {
  return [[PaymentQueueHandlerStub alloc] init];
}

@end

@implementation RequestHandlerStub

- (void)startProductRequestWithCompletionHandler:(nonnull ProductRequestCompletion)completion {
  if (self.startProductRequestWithCompletionHandlerStub) {
    self.startProductRequestWithCompletionHandlerStub(completion);
  }
}
@end

/// This mock is only used in iOS tests
#if TARGET_OS_IOS

// This FlutterPluginRegistrar is a protocol, so to make a stub it has to be implemented.
@implementation FlutterPluginRegistrarStub

- (void)addApplicationDelegate:(nonnull NSObject<FlutterPlugin> *)delegate {
  if (self.addApplicationDelegateStub) {
    self.addApplicationDelegateStub(delegate);
  }
}

- (void)addMethodCallDelegate:(nonnull NSObject<FlutterPlugin> *)delegate
                      channel:(nonnull FlutterMethodChannel *)channel {
  if (self.addMethodCallDelegateStub) {
    self.addMethodCallDelegateStub(delegate, channel);
  }
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset {
  if (self.lookupKeyForAssetStub) {
    return self.lookupKeyForAssetStub(asset);
  }
  return nil;
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset
                            fromPackage:(nonnull NSString *)package {
  if (self.lookupKeyForAssetFromPackageStub) {
    return self.lookupKeyForAssetFromPackageStub(asset, package);
  }
  return nil;
}

- (nonnull NSObject<FlutterBinaryMessenger> *)messenger {
  if (self.messengerStub) {
    return self.messengerStub();
  }
  return [[FlutterBinaryMessengerStub alloc] init];  // Or default behavior
}

- (void)publish:(nonnull NSObject *)value {
  if (self.publishStub) {
    self.publishStub(value);
  }
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                     withId:(nonnull NSString *)factoryId {
  if (self.registerViewFactoryStub) {
    self.registerViewFactoryStub(factory, factoryId);
  }
}

- (nonnull NSObject<FlutterTextureRegistry> *)textures {
  if (self.texturesStub) {
    return self.texturesStub();
  }
  return nil;
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                              withId:(nonnull NSString *)factoryId
    gestureRecognizersBlockingPolicy:
        (FlutterPlatformViewGestureRecognizersBlockingPolicy)gestureRecognizersBlockingPolicy {
  if (self.registerViewFactoryWithGestureRecognizersBlockingPolicyStub) {
    self.registerViewFactoryWithGestureRecognizersBlockingPolicyStub(
        factory, factoryId, gestureRecognizersBlockingPolicy);
  }
}

@end

// This FlutterBinaryMessenger is a protocol, so to make a stub it has to be implemented.
@implementation FlutterBinaryMessengerStub
- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
  if (self.cleanUpConnectionStub) {
    self.cleanUpConnectionStub(connection);
  }
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
  if (self.sendOnChannelMessageStub) {
    self.sendOnChannelMessageStub(channel, message);
  }
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
  if (self.sendOnChannelMessageBinaryReplyStub) {
    self.sendOnChannelMessageBinaryReplyStub(channel, message, callback);
  }
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  if (self.setMessageHandlerOnChannelBinaryMessageHandlerStub) {
    return self.setMessageHandlerOnChannelBinaryMessageHandlerStub(channel, handler);
  }
  return 0;
}
@end

#endif
