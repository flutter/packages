#import "Mocks.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIAPaymentQueueHandler.h"

#pragma mark Payment Queue Implementations
/// Real implementations
@implementation DefaultPaymentQueue
- (instancetype)initWithQueue:(SKPaymentQueue *)queue {
  self = [super init];
  if (self) {
    _queue = queue;
  }
  return self;
}

#pragma mark DefaultPaymentQueue implementation

- (void)addPayment:(SKPayment *_Nonnull)payment {
  [self.queue addPayment:payment];
}

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {
  [self.queue finishTransaction:transaction];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  [self.queue addTransactionObserver:observer];
}

- (void)restoreCompletedTransactions {
  [self.queue restoreCompletedTransactions];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
  [self.queue restoreCompletedTransactionsWithApplicationUsername:username];
}

- (id<SKPaymentQueueDelegate>)delegate API_AVAILABLE(ios(13.0), macos(10.15), watchos(6.2),
                                                     visionos(1.0)) {
  return self.queue.delegate;
}

- (NSArray<SKPaymentTransaction *> *)transactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2),
                                                                visionos(1.0)) {
  return self.queue.transactions;
}

- (SKStorefront *)storefront API_AVAILABLE(ios(13.0)) {
  return self.queue.storefront;
}

- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue presentCodeRedemptionSheet];
}
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue showPriceConsentIfNeeded];
}

@synthesize storefront;

@synthesize delegate;

@synthesize transactions;

@end

@implementation TestPaymentQueue

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  [self.observer paymentQueue:self.realQueue removedTransactions:@[ transaction ]];
}

- (void)addPayment:(SKPayment *_Nonnull)payment {
  FakeSKPaymentTransaction *transaction =
      [[FakeSKPaymentTransaction alloc] initWithState:self.testState payment:payment];
  [self.observer paymentQueue:self.realQueue updatedTransactions:@[ transaction ]];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  self.observer = observer;
}

- (void)restoreCompletedTransactions {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
}

- (NSArray<SKPaymentTransaction *> *_Nonnull)getUnfinishedTransactions {
  return [NSArray array];
}

- (void)presentCodeRedemptionSheet {
}
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}

- (void)restoreTransactions:(nullable NSString *)applicationName {
}

- (void)startObservingPaymentQueue {
}

- (void)stopObservingPaymentQueue {
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = nil;
}

@synthesize transactions;

@synthesize delegate;

@end

#pragma mark TransactionCache implemetations
@implementation DefaultTransactionCache
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  [self.cache addObjects:objects forKey:key];
}

- (void)clear {
  [self.cache clear];
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  return [self.cache getObjectsForKey:key];
}

- (nonnull instancetype)initWithCache:(nonnull FIATransactionCache *)cache {
  self = [super init];
  if (self) {
    _cache = cache;
  }
  return self;
}

@end

@implementation TestTransactionCache
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

#pragma mark MethodChannel implemetations
@implementation DefaultMethodChannel
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  [self.channel invokeMethod:method arguments:arguments];
}

- (instancetype)initWithChannel:(nonnull FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

@end

@implementation TestMethodChannel
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  if (self.invokeMethodChannelStub) {
    self.invokeMethodChannelStub(method, arguments);
  }
}

@end

@implementation FakeSKPaymentTransaction {
  SKPayment *_payment;
}

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"transactionIdentifier"] forKey:@"transactionIdentifier"];
    [self setValue:map[@"transactionState"] forKey:@"transactionState"];
    if (![map[@"originalTransaction"] isKindOfClass:[NSNull class]] &&
        map[@"originalTransaction"]) {
      [self setValue:[[FakeSKPaymentTransaction alloc] initWithMap:map[@"originalTransaction"]]
              forKey:@"originalTransaction"];
    }
    [self setValue:[NSDate dateWithTimeIntervalSince1970:[map[@"transactionTimeStamp"] doubleValue]]
            forKey:@"transactionDate"];
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

@implementation FakePluginRegistrar

- (void)addApplicationDelegate:(nonnull NSObject<FlutterPlugin> *)delegate {
}

- (void)addMethodCallDelegate:(nonnull NSObject<FlutterPlugin> *)delegate
                      channel:(nonnull FlutterMethodChannel *)channel {
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset {
  return nil;
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset
                            fromPackage:(nonnull NSString *)package {
  return nil;
}

- (nonnull NSObject<FlutterBinaryMessenger> *)messenger {
  return [FakeBinaryMessenger alloc];
}

- (void)publish:(nonnull NSObject *)value {
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                     withId:(nonnull NSString *)factoryId {
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                              withId:(nonnull NSString *)factoryId
    gestureRecognizersBlockingPolicy:
        (FlutterPlatformViewGestureRecognizersBlockingPolicy)gestureRecognizersBlockingPolicy {
}

- (nonnull NSObject<FlutterTextureRegistry> *)textures {
  return nil;
}

@end

@implementation FakeBinaryMessenger
- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return 0;
}

@end

@implementation FakePaymentQueueDelegate
@end

@implementation FakeSKDownload
@end
