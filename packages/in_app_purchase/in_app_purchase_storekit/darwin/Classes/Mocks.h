/// The payment queue protocol
NS_ASSUME_NONNULL_BEGIN

#pragma mark Payment Queue Interfaces

@protocol PaymentQueue <NSObject>
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;
- (void)addTransactionObserver:(id <SKPaymentTransactionObserver>)observer;
- (void)addPayment:(SKPayment *_Nonnull)payment;
- (void)restoreCompletedTransactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));
- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username API_AVAILABLE(ios(7.0), macos(10.9), watchos(6.2), visionos(1.0));
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0)) API_UNAVAILABLE(tvos, macos, watchos);
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4), visionos(1.0)) API_UNAVAILABLE(tvos, macos, watchos);
@property SKStorefront* storefront API_AVAILABLE(ios(13.0));
@property NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));
@property (NS_NONATOMIC_IOSONLY, weak, nullable) id<SKPaymentQueueDelegate> delegate API_AVAILABLE(ios(13.0), macos(10.15), watchos(6.2), visionos(1.0));
@end

/// The "real" payment queue interface
//API_AVAILABLE(ios(13.0))
@interface DefaultPaymentQueue : NSObject <PaymentQueue>
/// Returns a wrapper for the given SKPaymentQueue.
- (instancetype)initWithQueue:(SKPaymentQueue*)queue NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The wrapped queue context.
@property(nonatomic) SKPaymentQueue* queue;
@end

@interface TestPaymentQueue : NSObject <PaymentQueue>
/// Returns a wrapper for the given SKPaymentQueue.
@property(assign, nonatomic) SKPaymentTransactionState paymentState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@property(atomic, readwrite) SKStorefront* storefront API_AVAILABLE(ios(13.0));
@property(atomic, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));
@end

#pragma mark TransactionCache

@protocol TransactionCache <NSObject>
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;
- (void)clear;
@end

@interface TestTransactionCache : NSObject <TransactionCache>
@end

@interface DefaultTransactionCache : NSObject <TransactionCache>
@property FIATransactionCache* cache;
@end

#pragma mark PaymentTransaction

@protocol PaymentTransaction <NSObject>
@end

NS_ASSUME_NONNULL_END
