#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PaymentQueue <NSObject>
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;
- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer;
- (void)addPayment:(SKPayment *_Nonnull)payment;
- (void)restoreCompletedTransactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2),
                                                   visionos(1.0));
- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username
    API_AVAILABLE(ios(7.0), macos(10.9), watchos(6.2), visionos(1.0));
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos);
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos);
@property SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(ios(3.0), macos(10.7),
                                                                      watchos(6.2), visionos(1.0));
@property(NS_NONATOMIC_IOSONLY, weak, nullable) id<SKPaymentQueueDelegate> delegate API_AVAILABLE(
    ios(13.0), macos(10.15), watchos(6.2), visionos(1.0));
@end

@interface DefaultPaymentQueue : NSObject <PaymentQueue>
/// Returns a wrapper for the given SKPaymentQueue.
- (instancetype)initWithQueue:(SKPaymentQueue *)queue NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The wrapped queue context.
@property(nonatomic) SKPaymentQueue *queue;
@end

@protocol TransactionCache <NSObject>
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;
- (void)clear;
@end

@interface DefaultTransactionCache : NSObject <TransactionCache>
- (instancetype)initWithCache:(FIATransactionCache *)cache;
@property FIATransactionCache *cache;
@end

@protocol MethodChannel <NSObject>
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;
- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;
@end

@interface DefaultMethodChannel : NSObject <MethodChannel>
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
@property FlutterMethodChannel *channel;
@end

@protocol URLBundle <NSObject>
@property NSBundle *bundle;
- (NSURL *)appStoreURL;
@end

@interface DefaultBundle : NSObject <URLBundle>
@end

NS_ASSUME_NONNULL_END
