#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIAPaymentQueueHandler.h"
#import "Mocks.h"

#pragma mark Payment Queue Implementations
/// Real implementations
@implementation DefaultPaymentQueue
- (instancetype)initWithQueue:(SKPaymentQueue*)queue {
  self = [super init];
  if (self) {
    _queue = queue;
  }
  return self;
}

#pragma mark DefaultPaymentQueue implementation

- (void)addPayment:(SKPayment * _Nonnull)payment {
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


- (id<SKPaymentQueueDelegate>) delegate API_AVAILABLE(ios(13.0), macos(10.15), watchos(6.2), visionos(1.0)) {
  return self.queue.delegate;
}

- (NSArray<SKPaymentTransaction *>*) transactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2), visionos(1.0)) {
  return self.queue.transactions;
}

- (SKStorefront *)storefront  API_AVAILABLE(ios(13.0)){
  return self.queue.storefront;
}

- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0)) API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue presentCodeRedemptionSheet];
}
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4), visionos(1.0)) API_UNAVAILABLE(tvos, macos, watchos) {
  [self.queue showPriceConsentIfNeeded];
}



@synthesize storefront;

@synthesize delegate;

@synthesize transactions;

@end

@implementation TestPaymentQueue

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {

}

- (void)addPayment:(SKPayment * _Nonnull)payment { 
//  SKPaymentTransactionStub *transaction =
//      [[SKPaymentTransactionStub alloc] initWithState:self.testState payment:payment];
//  [self.observer paymentQueue:self updatedTransactions:@[ transaction ]];

}


- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer { 
  self.observer = observer;
}


- (void)restoreCompletedTransactions { 

}


- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username { 

}

- (NSArray<SKPaymentTransaction *> * _Nonnull)getUnfinishedTransactions {
  return [NSArray array];
}

- (void)presentCodeRedemptionSheet {

}
- (void)showPriceConsentIfNeeded {
}

- (void)restoreTransactions:(nullable NSString *)applicationName {

}

- (void)startObservingPaymentQueue {

}

- (void)stopObservingPaymentQueue {

}

@synthesize delegate;

@synthesize transactions;

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

@end

@implementation TestTransactionCache
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {

}

- (void)clear {

}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  return [NSArray array];
}

@end

