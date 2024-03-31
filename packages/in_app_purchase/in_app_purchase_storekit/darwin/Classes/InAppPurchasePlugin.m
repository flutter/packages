// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAObjectTranslator.h"
#import "FIAPPaymentQueueDelegate.h"
#import "FIAPReceiptManager.h"
#import "FIAPRequestHandler.h"
#import "FIAPaymentQueueHandler.h"
#import "InAppPurchasePlugin+TestOnly.h"

@interface InAppPurchasePlugin ()

// After querying the product, the available products will be saved in the map to be used
// for purchase.
@property(strong, nonatomic, readonly) NSMutableDictionary *productsCache;

// Callback channel to dart used for when a function from the payment queue delegate is triggered.
@property(strong, nonatomic, readonly) FlutterMethodChannel *paymentQueueDelegateCallbackChannel;
@property(strong, nonatomic, readonly) NSObject<FlutterPluginRegistrar> *registrar;

@property(strong, nonatomic, readonly) FIAPReceiptManager *receiptManager;
@property(strong, nonatomic, readonly)
    FIAPPaymentQueueDelegate *paymentQueueDelegate API_AVAILABLE(ios(13))
        API_UNAVAILABLE(tvos, macos, watchos);

@end

@implementation InAppPurchasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase"
                                  binaryMessenger:[registrar messenger]];

  InAppPurchasePlugin *instance = [[InAppPurchasePlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
  SetUpInAppPurchaseAPI(registrar.messenger, instance);
}

- (instancetype)initWithReceiptManager:(FIAPReceiptManager *)receiptManager {
  self = [super init];
  _receiptManager = receiptManager;
  _requestHandlers = [NSMutableSet new];
  _productsCache = [NSMutableDictionary new];
  _handlerFactory = ^FIAPRequestHandler *(SKRequest *request) {
    return [[FIAPRequestHandler alloc] initWithRequest:request];
  };
  return self;
}

- (instancetype)initWithReceiptManager:(FIAPReceiptManager *)receiptManager
                        handlerFactory:(FIAPRequestHandler * (^)(SKRequest *))handlerFactory {
  self = [self initWithReceiptManager:receiptManager];
  _handlerFactory = [handlerFactory copy];
  return self;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [self initWithReceiptManager:[FIAPReceiptManager new]];
  _registrar = registrar;

  __weak typeof(self) weakSelf = self;
  _paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueue defaultQueue]
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        [weakSelf handleTransactionsUpdated:transactions];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        [weakSelf handleTransactionsRemoved:transactions];
      }
      restoreTransactionFailed:^(NSError *_Nonnull error) {
        [weakSelf handleTransactionRestoreFailed:error];
      }
      restoreCompletedTransactionsFinished:^{
        [weakSelf restoreCompletedTransactionsFinished];
      }
      shouldAddStorePayment:^BOOL(SKPayment *payment, SKProduct *product) {
        return [weakSelf shouldAddStorePayment:payment product:product];
      }
      updatedDownloads:^void(NSArray<SKDownload *> *_Nonnull downloads) {
        [weakSelf updatedDownloads:downloads];
      }
      transactionCache:[[FIATransactionCache alloc] init]];

  _transactionObserverCallbackChannel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase"
                                  binaryMessenger:[registrar messenger]];
  return self;
}

- (nullable NSNumber *)canMakePaymentsWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([SKPaymentQueue canMakePayments]);
}

- (nullable NSArray<SKPaymentTransactionMessage *> *)transactionsWithError:
    (FlutterError *_Nullable *_Nonnull)error {
  NSArray<SKPaymentTransaction *> *transactions =
      [self.paymentQueueHandler getUnfinishedTransactions];
  NSMutableArray *transactionMaps = [[NSMutableArray alloc] init];
  for (SKPaymentTransaction *transaction in transactions) {
    [transactionMaps addObject:[FIAObjectTranslator convertTransactionToPigeon:transaction]];
  }
  return transactionMaps;
}

- (nullable SKStorefrontMessage *)storefrontWithError:(FlutterError *_Nullable *_Nonnull)error
    API_AVAILABLE(ios(13.0), macos(10.15)) {
  SKStorefront *storefront = self.paymentQueueHandler.storefront;
  if (!storefront) {
    return nil;
  }
  return [FIAObjectTranslator convertStorefrontToPigeon:storefront];
}

- (void)startProductRequestProductIdentifiers:(NSArray<NSString *> *)productIdentifiers
                                   completion:(void (^)(SKProductsResponseMessage *_Nullable,
                                                        FlutterError *_Nullable))completion {
  SKProductsRequest *request =
      [self getProductRequestWithIdentifiers:[NSSet setWithArray:productIdentifiers]];
  FIAPRequestHandler *handler = self.handlerFactory(request);
  [self.requestHandlers addObject:handler];
  __weak typeof(self) weakSelf = self;

  [handler startProductRequestWithCompletionHandler:^(SKProductsResponse *_Nullable response,
                                                      NSError *_Nullable startProductRequestError) {
    FlutterError *error = nil;
    if (startProductRequestError != nil) {
      error = [FlutterError errorWithCode:@"storekit_getproductrequest_platform_error"
                                  message:startProductRequestError.localizedDescription
                                  details:startProductRequestError.description];
      completion(nil, error);
      return;
    }
    if (!response) {
      error = [FlutterError errorWithCode:@"storekit_platform_no_response"
                                  message:@"Failed to get SKProductResponse in startRequest "
                                          @"call. Error occured on iOS platform"
                                  details:productIdentifiers];
      completion(nil, error);
      return;
    }
    for (SKProduct *product in response.products) {
      [self.productsCache setObject:product forKey:product.productIdentifier];
    }

    completion([FIAObjectTranslator convertProductsResponseToPigeon:response], error);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

- (void)addPaymentPaymentMap:(nonnull NSDictionary *)paymentMap
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSString *productID = [paymentMap objectForKey:@"productIdentifier"];
  // When a product is already fetched, we create a payment object with
  // the product to process the payment.
  SKProduct *product = [self getProduct:productID];
  if (!product) {
    *error = [FlutterError
        errorWithCode:@"storekit_invalid_payment_object"
              message:
                  @"You have requested a payment for an invalid product. Either the "
                  @"`productIdentifier` of the payment is not valid or the product has not been "
                  @"fetched before adding the payment to the payment queue."
              details:paymentMap];
    return;
  }

  SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
  payment.applicationUsername = [paymentMap objectForKey:@"applicationUsername"];
  NSNumber *quantity = [paymentMap objectForKey:@"quantity"];
  payment.quantity = (quantity != nil) ? quantity.integerValue : 1;
  NSNumber *simulatesAskToBuyInSandbox = [paymentMap objectForKey:@"simulatesAskToBuyInSandbox"];
  payment.simulatesAskToBuyInSandbox = (id)simulatesAskToBuyInSandbox == (id)[NSNull null]
                                           ? NO
                                           : [simulatesAskToBuyInSandbox boolValue];

  if (@available(iOS 12.2, *)) {
    NSDictionary *paymentDiscountMap = [self getNonNullValueFromDictionary:paymentMap
                                                                    forKey:@"paymentDiscount"];
    NSString *errorMsg = nil;
    SKPaymentDiscount *paymentDiscount =
        [FIAObjectTranslator getSKPaymentDiscountFromMap:paymentDiscountMap withError:&errorMsg];

    if (errorMsg) {
      *error = [FlutterError
          errorWithCode:@"storekit_invalid_payment_discount_object"
                message:[NSString stringWithFormat:@"You have requested a payment and specified a "
                                                   @"payment discount with invalid properties. %@",
                                                   errorMsg]
                details:paymentMap];
      return;
    }

    payment.paymentDiscount = paymentDiscount;
  }
  if (![self.paymentQueueHandler addPayment:payment]) {
    *error = [FlutterError
        errorWithCode:@"storekit_duplicate_product_object"
              message:@"There is a pending transaction for the same product identifier. Please "
                      @"either wait for it to be finished or finish it manually using "
                      @"`completePurchase` to avoid edge cases."

              details:paymentMap];
    return;
  }
}

- (void)finishTransactionFinishMap:(nonnull NSDictionary<NSString *, NSString *> *)finishMap
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSString *transactionIdentifier = [finishMap objectForKey:@"transactionIdentifier"];
  NSString *productIdentifier = [finishMap objectForKey:@"productIdentifier"];

  NSArray<SKPaymentTransaction *> *pendingTransactions =
      [self.paymentQueueHandler getUnfinishedTransactions];

  for (SKPaymentTransaction *transaction in pendingTransactions) {
    // If the user cancels the purchase dialog we won't have a transactionIdentifier.
    // So if it is null AND a transaction in the pendingTransactions list has
    // also a null transactionIdentifier we check for equal product identifiers.
    if ([transaction.transactionIdentifier isEqualToString:transactionIdentifier] ||
        ([transactionIdentifier isEqual:[NSNull null]] &&
         transaction.transactionIdentifier == nil &&
         [transaction.payment.productIdentifier isEqualToString:productIdentifier])) {
      @try {
        [self.paymentQueueHandler finishTransaction:transaction];
      } @catch (NSException *e) {
        *error = [FlutterError errorWithCode:@"storekit_finish_transaction_exception"
                                     message:e.name
                                     details:e.description];
        return;
      }
    }
  }
}

- (void)restoreTransactionsApplicationUserName:(nullable NSString *)applicationUserName
                                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                   error {
  [self.paymentQueueHandler restoreTransactions:applicationUserName];
}

- (void)presentCodeRedemptionSheetWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
#if TARGET_OS_IOS
  [self.paymentQueueHandler presentCodeRedemptionSheet];
#endif
}

- (nullable NSString *)retrieveReceiptDataWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FlutterError *flutterError;
  NSString *receiptData = [self.receiptManager retrieveReceiptWithError:&flutterError];
  if (flutterError) {
    *error = flutterError;
    return nil;
  }
  return receiptData;
}

- (void)refreshReceiptReceiptProperties:(nullable NSDictionary *)receiptProperties
                             completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  SKReceiptRefreshRequest *request;
  if (receiptProperties) {
    // if recieptProperties is not null, this call is for testing.
    NSMutableDictionary *properties = [NSMutableDictionary new];
    properties[SKReceiptPropertyIsExpired] = receiptProperties[@"isExpired"];
    properties[SKReceiptPropertyIsRevoked] = receiptProperties[@"isRevoked"];
    properties[SKReceiptPropertyIsVolumePurchase] = receiptProperties[@"isVolumePurchase"];
    request = [self getRefreshReceiptRequest:properties];
  } else {
    request = [self getRefreshReceiptRequest:nil];
  }

  FIAPRequestHandler *handler = self.handlerFactory(request);
  [self.requestHandlers addObject:handler];
  __weak typeof(self) weakSelf = self;
  [handler startProductRequestWithCompletionHandler:^(SKProductsResponse *_Nullable response,
                                                      NSError *_Nullable error) {
    FlutterError *requestError;
    if (error) {
      requestError = [FlutterError errorWithCode:@"storekit_refreshreceiptrequest_platform_error"
                                         message:error.localizedDescription
                                         details:error.description];
      completion(requestError);
      return;
    }
    completion(nil);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

- (void)startObservingPaymentQueueWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [_paymentQueueHandler startObservingPaymentQueue];
}

- (void)stopObservingPaymentQueueWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [_paymentQueueHandler stopObservingPaymentQueue];
}

- (void)registerPaymentQueueDelegateWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
#if TARGET_OS_IOS
  if (@available(iOS 13.0, *)) {
    _paymentQueueDelegateCallbackChannel = [FlutterMethodChannel
        methodChannelWithName:@"plugins.flutter.io/in_app_purchase_payment_queue_delegate"
              binaryMessenger:[_registrar messenger]];

    _paymentQueueDelegate = [[FIAPPaymentQueueDelegate alloc]
        initWithMethodChannel:_paymentQueueDelegateCallbackChannel];
    _paymentQueueHandler.delegate = _paymentQueueDelegate;
  }
#endif
}

- (void)removePaymentQueueDelegateWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  if (@available(iOS 13.0, *)) {
    _paymentQueueHandler.delegate = nil;
  }
  _paymentQueueDelegate = nil;
  _paymentQueueDelegateCallbackChannel = nil;
}

- (void)showPriceConsentIfNeededWithError:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
#if TARGET_OS_IOS
  if (@available(iOS 13.4, *)) {
    [_paymentQueueHandler showPriceConsentIfNeeded];
  }
#endif
}

- (id)getNonNullValueFromDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
  id value = dictionary[key];
  return [value isKindOfClass:[NSNull class]] ? nil : value;
}

#pragma mark - transaction observer:

- (void)handleTransactionsUpdated:(NSArray<SKPaymentTransaction *> *)transactions {
  NSMutableArray *maps = [NSMutableArray new];
  for (SKPaymentTransaction *transaction in transactions) {
    [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]];
  }
  [self.transactionObserverCallbackChannel invokeMethod:@"updatedTransactions" arguments:maps];
}

- (void)handleTransactionsRemoved:(NSArray<SKPaymentTransaction *> *)transactions {
  NSMutableArray *maps = [NSMutableArray new];
  for (SKPaymentTransaction *transaction in transactions) {
    [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]];
  }
  [self.transactionObserverCallbackChannel invokeMethod:@"removedTransactions" arguments:maps];
}

- (void)handleTransactionRestoreFailed:(NSError *)error {
  [self.transactionObserverCallbackChannel
      invokeMethod:@"restoreCompletedTransactionsFailed"
         arguments:[FIAObjectTranslator getMapFromNSError:error]];
}

- (void)restoreCompletedTransactionsFinished {
  [self.transactionObserverCallbackChannel
      invokeMethod:@"paymentQueueRestoreCompletedTransactionsFinished"
         arguments:nil];
}

- (void)updatedDownloads:(NSArray<SKDownload *> *)downloads {
  NSLog(@"Received an updatedDownloads callback, but downloads are not supported.");
}

- (BOOL)shouldAddStorePayment:(SKPayment *)payment product:(SKProduct *)product {
  // We always return NO here. And we send the message to dart to process the payment; and we will
  // have a interception method that deciding if the payment should be processed (implemented by the
  // programmer).
  [self.productsCache setObject:product forKey:product.productIdentifier];
  [self.transactionObserverCallbackChannel
      invokeMethod:@"shouldAddStorePayment"
         arguments:@{
           @"payment" : [FIAObjectTranslator getMapFromSKPayment:payment],
           @"product" : [FIAObjectTranslator getMapFromSKProduct:product]
         }];
  return NO;
}

#pragma mark - dependency injection (for unit testing)

- (SKProductsRequest *)getProductRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
}

- (SKProduct *)getProduct:(NSString *)productID {
  return [self.productsCache objectForKey:productID];
}

- (SKReceiptRefreshRequest *)getRefreshReceiptRequest:(NSDictionary *)properties {
  return [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:properties];
}
@end
