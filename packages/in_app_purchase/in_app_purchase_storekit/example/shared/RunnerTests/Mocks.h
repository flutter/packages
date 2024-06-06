#import <StoreKit/StoreKit.h>
#import "FIAProtocols.h"
#import "FIATransactionCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestPaymentQueue : NSObject <PaymentQueue>
/// Returns a wrapper for the given SKPaymentQueue.
@property(assign, nonatomic) SKPaymentTransactionState paymentState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@property(atomic, readwrite) SKStorefront *storefront API_AVAILABLE(ios(13.0));
@property(atomic, readwrite) NSArray<SKPaymentTransaction *> *transactions API_AVAILABLE(
    ios(3.0), macos(10.7), watchos(6.2), visionos(1.0));
@property(assign, nonatomic) SKPaymentTransactionState testState;
@property(nonatomic) SKPaymentQueue *realQueue;

@property(nonatomic, copy, nullable) void (^showPriceConsentIfNeededStub)(void);
@end

#pragma mark TransactionCache

@interface TestTransactionCache : NSObject <TransactionCache>
@property(nonatomic, copy, nullable) NSArray * (^getObjectsForKeyStub)(TransactionCacheKey key);
@property(nonatomic, copy, nullable) void (^clearStub)(void);
@property(nonatomic, copy, nullable) void (^addObjectsStub)(NSArray *, TransactionCacheKey);

@end

#pragma mark MethodChannel

@interface TestMethodChannel : NSObject <MethodChannel>
@property(nonatomic, copy, nullable) void (^invokeMethodChannelStub)(NSString *method, id arguments)
    ;
@property(nonatomic, copy, nullable) void (^invokeMethodChannelWithResultsStub)
    (NSString *method, id arguments, FlutterResult _Nullable);

@end

@interface TestBundle : NSObject <URLBundle>
@end

#pragma mark Stubs
NS_ASSUME_NONNULL_END
