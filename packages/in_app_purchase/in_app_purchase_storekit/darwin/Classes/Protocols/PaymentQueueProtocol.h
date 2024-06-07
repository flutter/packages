#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PaymentQueue <NSObject>
//Remove a finished (i.e. failed or completed) transaction from the queue.  Attempting to finish a purchasing transaction will throw an exception.
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;
// Observers are not retained.  The transactions array will only be synchronized with the server while the queue has observers.  This may require that the user authenticate.
- (void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer;
// Add a payment to the server queue.  The payment is copied to add an SKPaymentTransaction to the transactions array.  The same payment can be added multiple times to create multiple transactions.
- (void)addPayment:(SKPayment *_Nonnull)payment;
// Will add completed transactions for the current user back to the queue to be re-completed.
- (void)restoreCompletedTransactions API_AVAILABLE(ios(3.0), macos(10.7), watchos(6.2),
                                                   visionos(1.0));
- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username
    API_AVAILABLE(ios(7.0), macos(10.9), watchos(6.2), visionos(1.0));
// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by your app. Only for iOS.
- (void)presentCodeRedemptionSheet API_AVAILABLE(ios(14.0), visionos(1.0))
    API_UNAVAILABLE(tvos, macos, watchos);
// If StoreKit has called your SKPaymentQueueDelegate's "paymentQueueShouldShowPriceConsent:" method and you returned NO, you can use this method to show the price consent UI at a later time that is more appropriate for your app. If there is no pending price consent, this method will do nothing.
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

NS_ASSUME_NONNULL_END
