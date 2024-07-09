// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FIAPaymentQueueHandler.h"
#import "RunnerTests-Swift.h"
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface InAppPurchasePluginTest : XCTestCase

@property(nonatomic, strong) FIAPReceiptManagerStub *receiptManagerStub;
@property(nonatomic, strong) InAppPurchasePlugin *plugin;

@end

@implementation InAppPurchasePluginTest

- (void)setUp {
  self.receiptManagerStub = [FIAPReceiptManagerStub new];
  self.plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];
}

- (void)tearDown {
}

- (void)testCanMakePayments {
  FlutterError *error;
  NSNumber *result = [self.plugin canMakePaymentsWithError:&error];
  XCTAssertTrue([result boolValue]);
  XCTAssertNil(error);
}

- (void)testPaymentQueueStorefront {
  if (@available(iOS 13, macOS 10.15, *)) {
    NSDictionary *storefrontMap = @{
      @"countryCode" : @"USA",
      @"identifier" : @"unique_identifier",
    };
    PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
    TransactionCacheStub *cache = [[TransactionCacheStub alloc] init];

    queueStub.storefront = [[SKStorefrontStub alloc] initWithMap:storefrontMap];

    self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                                transactionsUpdated:nil
                                                                 transactionRemoved:nil
                                                           restoreTransactionFailed:nil
                                               restoreCompletedTransactionsFinished:nil
                                                              shouldAddStorePayment:nil
                                                                   updatedDownloads:nil
                                                                   transactionCache:cache];

    FlutterError *error;
    SKStorefrontMessage *result = [self.plugin storefrontWithError:&error];

    XCTAssertEqualObjects(result.countryCode, storefrontMap[@"countryCode"]);
    XCTAssertEqualObjects(result.identifier, storefrontMap[@"identifier"]);
    XCTAssertNil(error);
  } else {
    NSLog(@"Skip testPaymentQueueStorefront for iOS lower than 13.0 or macOS lower than 10.15.");
  }
}

- (void)testPaymentQueueStorefrontReturnsNil {
  if (@available(iOS 13, macOS 10.15, *)) {
    PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
    TransactionCacheStub *cache = [[TransactionCacheStub alloc] init];

    self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                                transactionsUpdated:nil
                                                                 transactionRemoved:nil
                                                           restoreTransactionFailed:nil
                                               restoreCompletedTransactionsFinished:nil
                                                              shouldAddStorePayment:nil
                                                                   updatedDownloads:nil
                                                                   transactionCache:cache];

    FlutterError *error;
    SKStorefrontMessage *resultMap = [self.plugin storefrontWithError:&error];

    XCTAssertNil(resultMap);
    XCTAssertNil(error);
  } else {
    NSLog(@"Skip testPaymentQueueStorefront for iOS lower than 13.0 or macOS lower than 10.15.");
  }
}

- (void)testGetProductResponse {
  NSArray *argument = @[ @"123" ];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];
  [self.plugin
      startProductRequestProductIdentifiers:argument
                                 completion:^(SKProductsResponseMessage *_Nullable response,
                                              FlutterError *_Nullable startProductRequestError) {
                                   XCTAssert(
                                       [response isKindOfClass:[SKProductsResponseMessage class]]);
                                   XCTAssertEqual(response.products.count, 1);
                                   XCTAssertEqual(response.invalidProductIdentifiers.count, 0);
                                   XCTAssertEqual(response.products[0].productIdentifier, @"123");
                                   [expectation fulfill];
                                 }];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testFinishTransactionSucceeds {
  NSDictionary *args = @{
    @"transactionIdentifier" : @"567",
    @"productIdentifier" : @"unique_identifier",
  };

  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : @"567",
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
  };

  SKPaymentTransactionStub *paymentTransactionStub =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = @[ paymentTransactionStub ];

  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
  queue.transactions = array;

  TransactionCacheStub *cache = [[TransactionCacheStub alloc] init];

  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
                                                              transactionsUpdated:nil
                                                               transactionRemoved:nil
                                                         restoreTransactionFailed:nil
                                             restoreCompletedTransactionsFinished:nil
                                                            shouldAddStorePayment:nil
                                                                 updatedDownloads:nil
                                                                 transactionCache:cache];

  FlutterError *error;
  [self.plugin finishTransactionFinishMap:args error:&error];

  XCTAssertNil(error);
}

- (void)testFinishTransactionSucceedsWithNilTransaction {
  NSDictionary *args = @{
    @"transactionIdentifier" : [NSNull null],
    @"productIdentifier" : @"unique_identifier",
  };

  NSDictionary *paymentMap = @{
    @"productIdentifier" : @"123",
    @"requestData" : @"abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
    @"quantity" : @(2),
    @"applicationUsername" : @"app user name",
    @"simulatesAskToBuyInSandbox" : @(NO)
  };

  NSDictionary *transactionMap = @{
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : paymentMap,
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
  };

  SKPaymentTransactionStub *paymentTransactionStub =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];

  PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
  queueStub.transactions = @[ paymentTransactionStub ];

  TransactionCacheStub *cache = [[TransactionCacheStub alloc] init];

  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                              transactionsUpdated:nil
                                                               transactionRemoved:nil
                                                         restoreTransactionFailed:nil
                                             restoreCompletedTransactionsFinished:nil
                                                            shouldAddStorePayment:nil
                                                                 updatedDownloads:nil
                                                                 transactionCache:cache];
  ;

  FlutterError *error;
  [self.plugin finishTransactionFinishMap:args error:&error];

  XCTAssertNil(error);
}

- (void)testGetProductResponseWithRequestError {
  NSArray *argument = @[ @"123" ];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  RequestHandlerStub *handlerStub = [[RequestHandlerStub alloc] init];
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:_receiptManagerStub
              handlerFactory:^RequestHandlerStub *(SKRequest *request) {
                return handlerStub;
              }];

  NSError *error = [NSError errorWithDomain:@"errorDomain"
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  handlerStub.startProductRequestWithCompletionHandlerStub =
      ^(ProductRequestCompletion _Nonnull completion) {
        completion(nil, error);
      };

  [plugin
      startProductRequestProductIdentifiers:argument
                                 completion:^(SKProductsResponseMessage *_Nullable response,
                                              FlutterError *_Nullable startProductRequestError) {
                                   [expectation fulfill];
                                   XCTAssertNotNil(error);
                                   XCTAssertNotNil(startProductRequestError);
                                   XCTAssertEqualObjects(
                                       startProductRequestError.code,
                                       @"storekit_getproductrequest_platform_error");
                                 }];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testGetProductResponseWithNoResponse {
  NSArray *argument = @[ @"123" ];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  RequestHandlerStub *handlerStub = [[RequestHandlerStub alloc] init];
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:_receiptManagerStub
              handlerFactory:^RequestHandlerStub *(SKRequest *request) {
                return handlerStub;
              }];

  handlerStub.startProductRequestWithCompletionHandlerStub =
      ^(ProductRequestCompletion _Nonnull completion) {
        completion(nil, nil);
      };

  [plugin
      startProductRequestProductIdentifiers:argument
                                 completion:^(SKProductsResponseMessage *_Nullable response,
                                              FlutterError *_Nullable startProductRequestError) {
                                   [expectation fulfill];
                                   XCTAssertNotNil(startProductRequestError);
                                   XCTAssertEqualObjects(startProductRequestError.code,
                                                         @"storekit_platform_no_response");
                                 }];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testAddPaymentShouldReturnFlutterErrorWhenPaymentFails {
  NSDictionary *argument = @{
    @"productIdentifier" : @"123",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : @YES,
  };

  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  FlutterError *error;

  __block NSInteger addPaymentInvokeCount = 0;
  handlerStub.addPaymentStub = ^(SKPayment *payment) {
    addPaymentInvokeCount += 1;
    return NO;
  };

  [self.plugin addPaymentPaymentMap:argument error:&error];

  XCTAssertEqual(addPaymentInvokeCount, 1);
  XCTAssertEqualObjects(@"storekit_duplicate_product_object", error.code);
  XCTAssertEqualObjects(@"There is a pending transaction for the same product identifier. "
                        @"Please either wait for it to be finished or finish it manually "
                        @"using `completePurchase` to avoid edge cases.",
                        error.message);
  XCTAssertEqualObjects(argument, error.details);
}

- (void)testAddPaymentShouldReturnFlutterErrorWhenInvalidProduct {
  NSDictionary *argument = @{
    // stubbed function will return nil for an empty productIdentifier
    @"productIdentifier" : @"",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : @YES,
  };

  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];

  XCTAssertEqualObjects(@"storekit_invalid_payment_object", error.code);
  XCTAssertEqualObjects(
      @"You have requested a payment for an invalid product. Either the "
      @"`productIdentifier` of the payment is not valid or the product has not been "
      @"fetched before adding the payment to the payment queue.",
      error.message);
  XCTAssertEqualObjects(argument, error.details);
}

- (void)testAddPaymentSuccessWithoutPaymentDiscount {
  NSDictionary *argument = @{
    @"productIdentifier" : @"123",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : @YES,
  };

  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  __block NSInteger addPaymentInvokeCount = 0;
  handlerStub.addPaymentStub = ^(SKPayment *payment) {
    XCTAssert(payment != nil);
    XCTAssertEqual(payment.productIdentifier, @"123");
    XCTAssert(payment.quantity == 1);
    addPaymentInvokeCount++;
    return YES;
  };

  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];

  XCTAssertNil(error);
  XCTAssertEqual(addPaymentInvokeCount, 1);
}

- (void)testAddPaymentSuccessWithPaymentDiscount {
  NSDictionary *argument = @{
    @"productIdentifier" : @"123",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : @YES,
    @"paymentDiscount" : @{
      @"identifier" : @"test_identifier",
      @"keyIdentifier" : @"test_key_identifier",
      @"nonce" : @"4a11a9cc-3bc3-11ec-8d3d-0242ac130003",
      @"signature" : @"test_signature",
      @"timestamp" : @(1635847102),
    }
  };

  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  __block NSInteger addPaymentInvokeCount = 0;
  handlerStub.addPaymentStub = ^(SKPayment *payment) {
    if (@available(iOS 12.2, *)) {
      SKPaymentDiscount *discount = payment.paymentDiscount;
      XCTAssertEqual(discount.identifier, @"test_identifier");
      XCTAssertEqual(discount.keyIdentifier, @"test_key_identifier");
      XCTAssertEqualObjects(
          discount.nonce,
          [[NSUUID alloc] initWithUUIDString:@"4a11a9cc-3bc3-11ec-8d3d-0242ac130003"]);
      XCTAssertEqual(discount.signature, @"test_signature");
      addPaymentInvokeCount++;
      return YES;
    }
    addPaymentInvokeCount++;
    return YES;
  };

  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];
  XCTAssertEqual(addPaymentInvokeCount, 1);
  XCTAssertNil(error);
}

- (void)testAddPaymentFailureWithInvalidPaymentDiscount {
  // Support for payment discount is only available on iOS 12.2 and higher.
  if (@available(iOS 12.2, *)) {
    NSDictionary *invalidDiscount = @{
      @"productIdentifier" : @"123",
      @"quantity" : @(1),
      @"simulatesAskToBuyInSandbox" : @YES,
      @"paymentDiscount" : @{
        /// This payment discount is missing the field `identifier`, and is thus malformed
        @"keyIdentifier" : @"test_key_identifier",
        @"nonce" : @"4a11a9cc-3bc3-11ec-8d3d-0242ac130003",
        @"signature" : @"test_signature",
        @"timestamp" : @(1635847102),
      }
    };

    PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];

    __block NSInteger addPaymentCount = 0;
    handlerStub.addPaymentStub = ^BOOL(SKPayment *_Nonnull payment) {
      addPaymentCount++;
      return YES;
    };

    self.plugin.paymentQueueHandler = handlerStub;
    FlutterError *error;

    [self.plugin addPaymentPaymentMap:invalidDiscount error:&error];

    XCTAssertEqualObjects(@"storekit_invalid_payment_discount_object", error.code);
    XCTAssertEqualObjects(@"You have requested a payment and specified a "
                          @"payment discount with invalid properties. When specifying a payment "
                          @"discount the 'identifier' field is mandatory.",
                          error.message);
    XCTAssertEqualObjects(invalidDiscount, error.details);
    XCTAssertEqual(0, addPaymentCount);
  }
}

- (void)testAddPaymentWithNullSandboxArgument {
  NSDictionary *argument = @{
    @"productIdentifier" : @"123",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : [NSNull null],
  };

  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;
  FlutterError *error;

  __block NSInteger addPaymentInvokeCount = 0;
  handlerStub.addPaymentStub = ^(SKPayment *payment) {
    XCTAssertEqual(payment.simulatesAskToBuyInSandbox, false);
    addPaymentInvokeCount++;
    return YES;
  };

  [self.plugin addPaymentPaymentMap:argument error:&error];
  XCTAssertEqual(addPaymentInvokeCount, 1);
}

- (void)testRestoreTransactions {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"result successfully restore transactions"];

  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];

  __block BOOL callbackInvoked = NO;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:^() {
        callbackInvoked = YES;
        [expectation fulfill];
      }
      shouldAddStorePayment:nil
      updatedDownloads:nil
      transactionCache:cacheStub];
  [queueStub addTransactionObserver:self.plugin.paymentQueueHandler];

  FlutterError *error;
  [self.plugin restoreTransactionsApplicationUserName:nil error:&error];

  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(callbackInvoked);
}

- (void)testRetrieveReceiptDataSuccess {
  FlutterError *error;
  NSString *result = [self.plugin retrieveReceiptDataWithError:&error];
  XCTAssertNotNil(result);
  XCTAssert([result isKindOfClass:[NSString class]]);
}

- (void)testRetrieveReceiptDataNil {
  self.receiptManagerStub.returnNilURL = YES;

  FlutterError *error;
  NSString *result = [self.plugin retrieveReceiptDataWithError:&error];
  XCTAssertNil(result);
}

- (void)testRetrieveReceiptDataError {
  self.receiptManagerStub.returnError = YES;

  FlutterError *error;
  NSString *result = [self.plugin retrieveReceiptDataWithError:&error];

  XCTAssertNil(result);
  XCTAssertNotNil(error);
  XCTAssert([error.code isKindOfClass:[NSString class]]);
  NSDictionary *details = error.details;
  XCTAssertNotNil(details[@"error"]);
  NSNumber *errorCode = (NSNumber *)details[@"error"][@"code"];
  XCTAssertEqual(errorCode, [NSNumber numberWithInteger:99]);
}

- (void)testRefreshReceiptRequest {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  RequestHandlerStub *handlerStub = [[RequestHandlerStub alloc] init];
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:_receiptManagerStub
              handlerFactory:^RequestHandlerStub *(SKRequest *request) {
                return handlerStub;
              }];

  NSError *recieptError = [NSError errorWithDomain:@"errorDomain"
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  handlerStub.startProductRequestWithCompletionHandlerStub =
      ^(ProductRequestCompletion _Nonnull completion) {
        completion(nil, recieptError);
      };

  [plugin refreshReceiptReceiptProperties:nil
                               completion:^(FlutterError *_Nullable error) {
                                 [expectation fulfill];
                               }];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testRefreshReceiptRequestWithParams {
  NSDictionary *properties = @{
    @"isExpired" : @NO,
    @"isRevoked" : @NO,
    @"isVolumePurchase" : @NO,
  };

  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  RequestHandlerStub *handlerStub = [[RequestHandlerStub alloc] init];
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:_receiptManagerStub
              handlerFactory:^RequestHandlerStub *(SKRequest *request) {
                return handlerStub;
              }];

  NSError *recieptError = [NSError errorWithDomain:@"errorDomain"
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  handlerStub.startProductRequestWithCompletionHandlerStub =
      ^(ProductRequestCompletion _Nonnull completion) {
        completion(nil, recieptError);
      };

  [plugin refreshReceiptReceiptProperties:properties
                               completion:^(FlutterError *_Nullable error) {
                                 [expectation fulfill];
                               }];

  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testRefreshReceiptRequestWithError {
  NSDictionary *properties = @{
    @"isExpired" : @NO,
    @"isRevoked" : @NO,
    @"isVolumePurchase" : @NO,
  };
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  RequestHandlerStub *handlerStub = [[RequestHandlerStub alloc] init];
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:_receiptManagerStub
              handlerFactory:^RequestHandlerStub *(SKRequest *request) {
                return handlerStub;
              }];

  NSError *recieptError = [NSError errorWithDomain:@"errorDomain"
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  handlerStub.startProductRequestWithCompletionHandlerStub =
      ^(ProductRequestCompletion _Nonnull completion) {
        completion(nil, recieptError);
      };

  [plugin refreshReceiptReceiptProperties:properties
                               completion:^(FlutterError *_Nullable error) {
                                 XCTAssertNotNil(error);
                                 XCTAssertEqualObjects(
                                     error.code, @"storekit_refreshreceiptrequest_platform_error");
                                 [expectation fulfill];
                               }];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

/// presentCodeRedemptionSheetWithError:error is only available on iOS
#if TARGET_OS_IOS
- (void)testPresentCodeRedemptionSheet {
  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  __block NSInteger presentCodeRedemptionSheetCount = 0;
  handlerStub.presentCodeRedemptionSheetStub = ^{
    presentCodeRedemptionSheetCount++;
  };

  FlutterError *error;
  [self.plugin presentCodeRedemptionSheetWithError:&error];

  XCTAssertEqual(1, presentCodeRedemptionSheetCount);
}
#endif

- (void)testGetPendingTransactions {
  PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : [NSNull null],
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : [NSNull null],
  };
  queueStub.transactions = @[ [[SKPaymentTransactionStub alloc] initWithMap:transactionMap] ];
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                              transactionsUpdated:nil
                                                               transactionRemoved:nil
                                                         restoreTransactionFailed:nil
                                             restoreCompletedTransactionsFinished:nil
                                                            shouldAddStorePayment:nil
                                                                 updatedDownloads:nil
                                                                 transactionCache:cacheStub];
  FlutterError *error;
  SKPaymentTransactionStub *original =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];

  SKPaymentTransactionMessage *originalPigeon =
      [FIAObjectTranslator convertTransactionToPigeon:original];
  SKPaymentTransactionMessage *result = [self.plugin transactionsWithError:&error][0];

  XCTAssertEqualObjects([self paymentTransactionToList:result],
                        [self paymentTransactionToList:originalPigeon]);
}

- (void)testStartObservingPaymentQueue {
  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  __block NSInteger startObservingCount = 0;
  handlerStub.startObservingPaymentQueueStub = ^{
    startObservingCount++;
  };

  FlutterError *error;
  [self.plugin startObservingPaymentQueueWithError:&error];

  XCTAssertEqual(1, startObservingCount);
}

- (void)testStopObservingPaymentQueue {
  PaymentQueueHandlerStub *handlerStub = [[PaymentQueueHandlerStub alloc] init];
  self.plugin.paymentQueueHandler = handlerStub;

  __block NSInteger stopObservingCount = 0;
  handlerStub.stopObservingPaymentQueueStub = ^{
    stopObservingCount++;
  };

  FlutterError *error;
  [self.plugin stopObservingPaymentQueueWithError:&error];

  XCTAssertEqual(1, stopObservingCount);
}

#if TARGET_OS_IOS
- (void)testRegisterPaymentQueueDelegate {
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
  if (@available(iOS 13, *)) {
    self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                                transactionsUpdated:nil
                                                                 transactionRemoved:nil
                                                           restoreTransactionFailed:nil
                                               restoreCompletedTransactionsFinished:nil
                                                              shouldAddStorePayment:nil
                                                                   updatedDownloads:nil
                                                                   transactionCache:cacheStub];

    self.plugin.registrar = [[FlutterPluginRegistrarStub alloc] init];

    // Verify the delegate is nil before we register one.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);

    FlutterError *error;
    [self.plugin registerPaymentQueueDelegateWithError:&error];

    // Verify the delegate is not nil after we registered one.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);
  }
}

- (void)testRemovePaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
    PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
    self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                                transactionsUpdated:nil
                                                                 transactionRemoved:nil
                                                           restoreTransactionFailed:nil
                                               restoreCompletedTransactionsFinished:nil
                                                              shouldAddStorePayment:nil
                                                                   updatedDownloads:nil
                                                                   transactionCache:cacheStub];

    self.plugin.registrar = [[FlutterPluginRegistrarStub alloc] init];

    // Verify the delegate is nil before we register one.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);

    FlutterError *error;
    [self.plugin registerPaymentQueueDelegateWithError:&error];

    // Verify the delegate is not nil before removing it.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);

    [self.plugin removePaymentQueueDelegateWithError:&error];

    // Verify the delegate is nill after removing it.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);
  }
}
#endif

- (void)testHandleTransactionsUpdated {
  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : @"567",
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
  };

  InAppPurchasePlugin *plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];
  MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
  __block NSInteger invokeMethodCount = 0;

  channelStub.invokeMethodChannelStub = ^(NSString *_Nonnull method, id _Nonnull arguments) {
    XCTAssertEqualObjects(@"updatedTransactions", method);
    XCTAssertNotNil(arguments);
    invokeMethodCount++;
  };

  // (TODO: louisehsu) Change this to inject the channel, like requestHandler
  plugin.transactionObserverCallbackChannel = channelStub;

  SKPaymentTransactionStub *paymentTransactionStub =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = [NSArray arrayWithObjects:paymentTransactionStub, nil];
  NSMutableArray *maps = [NSMutableArray new];
  [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:paymentTransactionStub]];

  [plugin handleTransactionsUpdated:array];
  XCTAssertEqual(invokeMethodCount, 1);
}

- (void)testHandleTransactionsRemoved {
  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : @"567",
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
  };

  InAppPurchasePlugin *plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];
  SKPaymentTransactionStub *paymentTransactionStub =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = [NSArray arrayWithObjects:paymentTransactionStub, nil];
  NSMutableArray *maps = [NSMutableArray new];
  [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:paymentTransactionStub]];

  MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
  __block NSInteger invokeMethodCount = 0;

  channelStub.invokeMethodChannelStub = ^(NSString *_Nonnull method, id _Nonnull arguments) {
    XCTAssertEqualObjects(@"removedTransactions", method);
    XCTAssertEqualObjects(maps, arguments);
    invokeMethodCount++;
  };

  // (TODO: louisehsu) Change this to inject the channel, like requestHandler
  plugin.transactionObserverCallbackChannel = channelStub;

  [plugin handleTransactionsRemoved:array];
  XCTAssertEqual(invokeMethodCount, 1);
}

- (void)testHandleTransactionRestoreFailed {
  InAppPurchasePlugin *plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];
  MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
  __block NSInteger invokeMethodCount = 0;
  NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];

  channelStub.invokeMethodChannelStub = ^(NSString *_Nonnull method, id _Nonnull arguments) {
    XCTAssertEqualObjects(@"restoreCompletedTransactionsFailed", method);
    XCTAssertEqualObjects([FIAObjectTranslator getMapFromNSError:error], arguments);
    invokeMethodCount++;
  };

  // (TODO: louisehsu) Change this to inject the channel, like requestHandler
  plugin.transactionObserverCallbackChannel = channelStub;

  [plugin handleTransactionRestoreFailed:error];
  XCTAssertEqual(invokeMethodCount, 1);
}

- (void)testRestoreCompletedTransactionsFinished {
  InAppPurchasePlugin *plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];
  MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];
  __block NSInteger invokeMethodCount = 0;
  channelStub.invokeMethodChannelStub = ^(NSString *_Nonnull method, id _Nonnull arguments) {
    XCTAssertEqualObjects(@"paymentQueueRestoreCompletedTransactionsFinished", method);
    XCTAssertNil(arguments);
    invokeMethodCount++;
  };

  // (TODO: louisehsu) Change this to inject the channel, like requestHandler
  plugin.transactionObserverCallbackChannel = channelStub;

  [plugin restoreCompletedTransactionsFinished];
  XCTAssertEqual(invokeMethodCount, 1);
}

- (void)testShouldAddStorePayment {
  NSDictionary *paymentMap = @{
    @"productIdentifier" : @"123",
    @"requestData" : @"abcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefghabcdefgh",
    @"quantity" : @(2),
    @"applicationUsername" : @"app user name",
    @"simulatesAskToBuyInSandbox" : @(NO)
  };

  NSDictionary *productMap = @{
    @"price" : @"1",
    @"priceLocale" : [FIAObjectTranslator getMapFromNSLocale:NSLocale.systemLocale],
    @"productIdentifier" : @"123",
    @"localizedTitle" : @"title",
    @"localizedDescription" : @"des",
  };

  SKMutablePayment *payment = [FIAObjectTranslator getSKMutablePaymentFromMap:paymentMap];
  SKProductStub *productStub = [[SKProductStub alloc] initWithMap:productMap];

  InAppPurchasePlugin *plugin = [[InAppPurchasePluginStub alloc]
      initWithReceiptManager:self.receiptManagerStub
              handlerFactory:^DefaultRequestHandler *(SKRequest *request) {
                return [[DefaultRequestHandler alloc]
                    initWithRequestHandler:[[FIAPRequestHandler alloc] initWithRequest:request]];
              }];

  NSDictionary *args = @{
    @"payment" : [FIAObjectTranslator getMapFromSKPayment:payment],
    @"product" : [FIAObjectTranslator getMapFromSKProduct:productStub]
  };

  MethodChannelStub *channelStub = [[MethodChannelStub alloc] init];

  __block NSInteger invokeMethodCount = 0;
  channelStub.invokeMethodChannelStub = ^(NSString *_Nonnull method, id _Nonnull arguments) {
    XCTAssertEqualObjects(@"shouldAddStorePayment", method);
    XCTAssertEqualObjects(args, arguments);
    invokeMethodCount++;
  };

  // (TODO: louisehsu) Change this to inject the channel, like requestHandler
  plugin.transactionObserverCallbackChannel = channelStub;

  BOOL result = [plugin shouldAddStorePaymentWithPayment:payment product:productStub];
  XCTAssertEqual(result, NO);
  XCTAssertEqual(invokeMethodCount, 1);
}

#if TARGET_OS_IOS
- (void)testShowPriceConsentIfNeeded {
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  PaymentQueueStub *queueStub = [[PaymentQueueStub alloc] init];
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queueStub
                                                              transactionsUpdated:nil
                                                               transactionRemoved:nil
                                                         restoreTransactionFailed:nil
                                             restoreCompletedTransactionsFinished:nil
                                                            shouldAddStorePayment:nil
                                                                 updatedDownloads:nil
                                                                 transactionCache:cacheStub];

  FlutterError *error;
  __block NSInteger showPriceConsentIfNeededCount = 0;

  queueStub.showPriceConsentIfNeededStub = ^(void) {
    showPriceConsentIfNeededCount++;
  };

  [self.plugin showPriceConsentIfNeededWithError:&error];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  if (@available(iOS 13.4, *)) {
    XCTAssertEqual(showPriceConsentIfNeededCount, 1);
  } else {
    XCTAssertEqual(showPriceConsentIfNeededCount, 0);
  }
#pragma clang diagnostic pop
}
#endif

// The following methods are deserializer copied from Pigeon's output.

- (NSArray *)paymentTransactionToList:(SKPaymentTransactionMessage *)paymentTransaction {
  return @[
    (paymentTransaction.payment ? [self paymentToList:paymentTransaction.payment] : [NSNull null]),
    @(paymentTransaction.transactionState),
    (paymentTransaction.originalTransaction
         ? [self paymentTransactionToList:paymentTransaction.originalTransaction]
         : [NSNull null]),
    paymentTransaction.transactionTimeStamp ?: [NSNull null],
    paymentTransaction.transactionIdentifier ?: [NSNull null],
    (paymentTransaction.error ? [self errorToList:paymentTransaction.error] : [NSNull null]),
  ];
}

- (NSArray *)paymentToList:(SKPaymentMessage *)payment {
  return @[
    payment.productIdentifier ?: [NSNull null],
    payment.applicationUsername ?: [NSNull null],
    payment.requestData ?: [NSNull null],
    @(payment.quantity),
    @(payment.simulatesAskToBuyInSandbox),
    (payment.paymentDiscount ? [self paymentDiscountToList:payment.paymentDiscount]
                             : [NSNull null]),
  ];
}

- (NSArray *)paymentDiscountToList:(SKPaymentDiscountMessage *)discount {
  return @[
    discount.identifier ?: [NSNull null],
    discount.keyIdentifier ?: [NSNull null],
    discount.nonce ?: [NSNull null],
    discount.signature ?: [NSNull null],
    @(discount.timestamp),
  ];
}

- (NSArray *)errorToList:(SKErrorMessage *)error {
  return @[
    @(error.code),
    error.domain ?: [NSNull null],
    error.userInfo ?: [NSNull null],
  ];
}
@end
