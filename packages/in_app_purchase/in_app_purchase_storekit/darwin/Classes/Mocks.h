#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

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
@property (nonatomic, copy, nullable) void (^showPriceConsentIfNeededStub)(void);
@property(assign, nonatomic) SKPaymentTransactionState testState;
@property(nonatomic) SKPaymentQueue* realQueue;
@end

#pragma mark TransactionCache

@protocol TransactionCache <NSObject>
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;
- (void)clear;
@end

@interface TestTransactionCache : NSObject <TransactionCache>
@property (nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property (nonatomic, copy, nullable) void (^clearStub)(void);
@property (nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

@interface DefaultTransactionCache : NSObject <TransactionCache>
- (instancetype)initWithCache:(FIATransactionCache*)cache;
@property FIATransactionCache* cache;
@end

#pragma mark PaymentTransaction

@protocol PaymentTransaction <NSObject>
@end

#pragma mark MethodChannel

@protocol MethodChannel <NSObject>
- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments;
@end

@interface DefaultMethodChannel : NSObject <MethodChannel>
- (instancetype)initWithChannel:(FlutterMethodChannel*)channel;
@property FlutterMethodChannel* channel;
@end

@interface TestMethodChannel : NSObject <MethodChannel>
@property (nonatomic, copy, nullable) void (^invokeMethodChannelStub)(NSString* method, id arguments);
@end

#pragma mark FIAPRequestHandler

#pragma mark SKPaymentTransactionStub

@interface FakeSKPaymentTransaction : SKPaymentTransaction
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithState:(SKPaymentTransactionState)state payment:(SKPayment *)payment;
@end

@interface FakePluginRegistrar : NSObject <FlutterPluginRegistrar>
@end

@interface FakeBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end

@interface FakePaymentQueueDelegate : NSObject <SKPaymentQueueDelegate>
@end

@protocol URLBundle <NSObject>
@property NSBundle *bundle;
- (NSURL*)appStoreURL;
@end

@interface DefaultBundle : NSObject<URLBundle>
@end

@interface TestBundle : NSObject <URLBundle>
@end

@interface FakeSKDownload : SKDownload
@end

NS_ASSUME_NONNULL_END

