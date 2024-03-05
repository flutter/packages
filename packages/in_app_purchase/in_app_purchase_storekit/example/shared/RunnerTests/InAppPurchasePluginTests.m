// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "FIAPaymentQueueHandler.h"
#import "InAppPurchasePlugin+TestOnly.h"
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface InAppPurchasePluginTest : XCTestCase

@property(strong, nonatomic) FIAPReceiptManagerStub *receiptManagerStub;
@property(strong, nonatomic) InAppPurchasePlugin *plugin;

@end

@implementation InAppPurchasePluginTest

- (void)setUp {
  self.receiptManagerStub = [FIAPReceiptManagerStub new];
  self.plugin = [[InAppPurchasePluginStub alloc] initWithReceiptManager:self.receiptManagerStub];
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
    SKPaymentQueue *mockQueue = OCMClassMock(SKPaymentQueue.class);
    NSDictionary *storefrontMap = @{
      @"countryCode" : @"USA",
      @"identifier" : @"unique_identifier",
    };

    OCMStub(mockQueue.storefront).andReturn([[SKStorefrontStub alloc] initWithMap:storefrontMap]);

    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:mockQueue
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil
                                     transactionCache:OCMClassMock(FIATransactionCache.class)];

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
    SKPaymentQueue *mockQueue = OCMClassMock(SKPaymentQueue.class);

    OCMStub(mockQueue.storefront).andReturn(nil);

    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:mockQueue
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil
                                     transactionCache:OCMClassMock(FIATransactionCache.class)];

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

  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = @[ paymentTransaction ];

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler getUnfinishedTransactions]).andReturn(array);

  self.plugin.paymentQueueHandler = mockHandler;

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

  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler getUnfinishedTransactions]).andReturn(@[ paymentTransaction ]);

  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;
  [self.plugin finishTransactionFinishMap:args error:&error];

  XCTAssertNil(error);
}

- (void)testGetProductResponseWithRequestError {
  NSArray *argument = @[ @"123" ];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];

  id mockHandler = OCMClassMock([FIAPRequestHandler class]);
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:nil
              handlerFactory:^FIAPRequestHandler *(SKRequest *request) {
                return mockHandler;
              }];

  NSError *error = [NSError errorWithDomain:@"errorDomain"
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  OCMStub([mockHandler
      startProductRequestWithCompletionHandler:([OCMArg invokeBlockWithArgs:[NSNull null], error,
                                                                            nil])]);

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

  id mockHandler = OCMClassMock([FIAPRequestHandler class]);

  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:nil
              handlerFactory:^FIAPRequestHandler *(SKRequest *request) {
                return mockHandler;
              }];

  NSError *error = [NSError errorWithDomain:@"errorDomain"
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  OCMStub([mockHandler
      startProductRequestWithCompletionHandler:([OCMArg invokeBlockWithArgs:[NSNull null],
                                                                            [NSNull null], nil])]);

  [plugin
      startProductRequestProductIdentifiers:argument
                                 completion:^(SKProductsResponseMessage *_Nullable response,
                                              FlutterError *_Nullable startProductRequestError) {
                                   [expectation fulfill];
                                   XCTAssertNotNil(error);
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

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler addPayment:[OCMArg any]]).andReturn(NO);
  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];

  OCMVerify(times(1), [mockHandler addPayment:[OCMArg any]]);
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

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler addPayment:[OCMArg any]]).andReturn(YES);
  self.plugin.paymentQueueHandler = mockHandler;
  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];

  XCTAssertNil(error);
  OCMVerify(times(1), [mockHandler addPayment:[OCMArg checkWithBlock:^BOOL(id obj) {
                                     SKPayment *payment = obj;
                                     XCTAssert(payment != nil);
                                     XCTAssertEqual(payment.productIdentifier, @"123");
                                     XCTAssert(payment.quantity == 1);
                                     return YES;
                                   }]]);
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

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler addPayment:[OCMArg any]]).andReturn(YES);
  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];
  XCTAssertNil(error);
  OCMVerify(
      times(1),
      [mockHandler
          addPayment:[OCMArg checkWithBlock:^BOOL(id obj) {
            SKPayment *payment = obj;
            if (@available(iOS 12.2, *)) {
              SKPaymentDiscount *discount = payment.paymentDiscount;

              return [discount.identifier isEqual:@"test_identifier"] &&
                     [discount.keyIdentifier isEqual:@"test_key_identifier"] &&
                     [discount.nonce
                         isEqual:[[NSUUID alloc]
                                     initWithUUIDString:@"4a11a9cc-3bc3-11ec-8d3d-0242ac130003"]] &&
                     [discount.signature isEqual:@"test_signature"] &&
                     [discount.timestamp isEqual:@(1635847102)];
            }

            return YES;
          }]]);
}

- (void)testAddPaymentFailureWithInvalidPaymentDiscount {
  // Support for payment discount is only available on iOS 12.2 and higher.
  if (@available(iOS 12.2, *)) {
    NSDictionary *argument = @{
      @"productIdentifier" : @"123",
      @"quantity" : @(1),
      @"simulatesAskToBuyInSandbox" : @YES,
      @"paymentDiscount" : @{
        @"keyIdentifier" : @"test_key_identifier",
        @"nonce" : @"4a11a9cc-3bc3-11ec-8d3d-0242ac130003",
        @"signature" : @"test_signature",
        @"timestamp" : @(1635847102),
      }
    };

    FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
    id translator = OCMClassMock(FIAObjectTranslator.class);

    NSString *errorMsg = @"Some error occurred";
    OCMStub(ClassMethod([translator
                getSKPaymentDiscountFromMap:[OCMArg any]
                                  withError:(NSString __autoreleasing **)[OCMArg setTo:errorMsg]]))
        .andReturn(nil);
    self.plugin.paymentQueueHandler = mockHandler;
    FlutterError *error;

    [self.plugin addPaymentPaymentMap:argument error:&error];

    XCTAssertEqualObjects(@"storekit_invalid_payment_discount_object", error.code);
    XCTAssertEqualObjects(@"You have requested a payment and specified a "
                          @"payment discount with invalid properties. Some error occurred",
                          error.message);
    XCTAssertEqualObjects(argument, error.details);
    OCMVerify(never(), [mockHandler addPayment:[OCMArg any]]);
  }
}

- (void)testAddPaymentWithNullSandboxArgument {
  NSDictionary *argument = @{
    @"productIdentifier" : @"123",
    @"quantity" : @(1),
    @"simulatesAskToBuyInSandbox" : [NSNull null],
  };

  FIAPaymentQueueHandler *mockHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  OCMStub([mockHandler addPayment:[OCMArg any]]).andReturn(YES);
  self.plugin.paymentQueueHandler = mockHandler;
  FlutterError *error;

  [self.plugin addPaymentPaymentMap:argument error:&error];
  OCMVerify(times(1), [mockHandler addPayment:[OCMArg checkWithBlock:^BOOL(id obj) {
                                     SKPayment *payment = obj;
                                     return !payment.simulatesAskToBuyInSandbox;
                                   }]]);
}

- (void)testRestoreTransactions {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"result successfully restore transactions"];

  SKPaymentQueueStub *queue = [SKPaymentQueueStub new];
  queue.testState = SKPaymentTransactionStatePurchased;

  __block BOOL callbackInvoked = NO;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
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
      transactionCache:OCMClassMock(FIATransactionCache.class)];
  [queue addTransactionObserver:self.plugin.paymentQueueHandler];

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
  NSBundle *mockBundle = OCMPartialMock([NSBundle mainBundle]);
  OCMStub(mockBundle.appStoreReceiptURL).andReturn(nil);
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
  NSDictionary *details = error.details;
  XCTAssertNotNil(details[@"error"]);
  NSNumber *errorCode = (NSNumber *)details[@"error"][@"code"];
  XCTAssertEqual(errorCode, [NSNumber numberWithInteger:99]);
}

- (void)testRefreshReceiptRequest {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"completion handler successfully called"];
  [self.plugin refreshReceiptReceiptProperties:nil
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
  [self.plugin refreshReceiptReceiptProperties:properties
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

  id mockHandler = OCMClassMock([FIAPRequestHandler class]);
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc]
      initWithReceiptManager:nil
              handlerFactory:^FIAPRequestHandler *(SKRequest *request) {
                return mockHandler;
              }];

  NSError *recieptError = [NSError errorWithDomain:@"errorDomain"
                                              code:0
                                          userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  OCMStub([mockHandler
      startProductRequestWithCompletionHandler:([OCMArg invokeBlockWithArgs:[NSNull null],
                                                                            recieptError, nil])]);

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
  FIAPaymentQueueHandler *mockHandler = OCMClassMock([FIAPaymentQueueHandler class]);
  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;
  [self.plugin presentCodeRedemptionSheetWithError:&error];

  OCMVerify(times(1), [mockHandler presentCodeRedemptionSheet]);
}
#endif

- (void)testGetPendingTransactions {
  SKPaymentQueue *mockQueue = OCMClassMock(SKPaymentQueue.class);
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
  OCMStub(mockQueue.transactions).andReturn(@[ [[SKPaymentTransactionStub alloc]
      initWithMap:transactionMap] ]);

  self.plugin.paymentQueueHandler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:mockQueue
                                transactionsUpdated:nil
                                 transactionRemoved:nil
                           restoreTransactionFailed:nil
               restoreCompletedTransactionsFinished:nil
                              shouldAddStorePayment:nil
                                   updatedDownloads:nil
                                   transactionCache:OCMClassMock(FIATransactionCache.class)];
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
  FIAPaymentQueueHandler *mockHandler = OCMClassMock([FIAPaymentQueueHandler class]);
  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;
  [self.plugin startObservingPaymentQueueWithError:&error];

  OCMVerify(times(1), [mockHandler startObservingPaymentQueue]);
}

- (void)testStopObservingPaymentQueue {
  FIAPaymentQueueHandler *mockHandler = OCMClassMock([FIAPaymentQueueHandler class]);
  self.plugin.paymentQueueHandler = mockHandler;

  FlutterError *error;
  [self.plugin stopObservingPaymentQueueWithError:&error];

  OCMVerify(times(1), [mockHandler stopObservingPaymentQueue]);
}

#if TARGET_OS_IOS
- (void)testRegisterPaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueueStub new]
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil
                                     transactionCache:OCMClassMock(FIATransactionCache.class)];

    // Verify the delegate is nil before we register one.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);

    FlutterError *error;
    [self.plugin registerPaymentQueueDelegateWithError:&error];

    // Verify the delegate is not nil after we registered one.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);
  }
}
#endif

- (void)testRemovePaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueueStub new]
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil
                                     transactionCache:OCMClassMock(FIATransactionCache.class)];
    self.plugin.paymentQueueHandler.delegate = OCMProtocolMock(@protocol(SKPaymentQueueDelegate));

    // Verify the delegate is not nil before removing it.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);

    FlutterError *error;
    [self.plugin removePaymentQueueDelegateWithError:&error];

    // Verify the delegate is nill after removing it.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);
  }
}

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

  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc] initWithReceiptManager:nil];
  FlutterMethodChannel *mockChannel = OCMClassMock([FlutterMethodChannel class]);
  plugin.transactionObserverCallbackChannel = mockChannel;
  OCMStub([mockChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]]);

  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = [NSArray arrayWithObjects:paymentTransaction, nil];
  NSMutableArray *maps = [NSMutableArray new];
  [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:paymentTransaction]];

  [plugin handleTransactionsUpdated:array];
  OCMVerify(times(1), [mockChannel invokeMethod:@"updatedTransactions" arguments:[OCMArg any]]);
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

  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc] initWithReceiptManager:nil];
  FlutterMethodChannel *mockChannel = OCMClassMock([FlutterMethodChannel class]);
  plugin.transactionObserverCallbackChannel = mockChannel;
  OCMStub([mockChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]]);

  SKPaymentTransactionStub *paymentTransaction =
      [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];
  NSArray *array = [NSArray arrayWithObjects:paymentTransaction, nil];
  NSMutableArray *maps = [NSMutableArray new];
  [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:paymentTransaction]];

  [plugin handleTransactionsRemoved:array];
  OCMVerify(times(1), [mockChannel invokeMethod:@"removedTransactions" arguments:maps]);
}

- (void)testHandleTransactionRestoreFailed {
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc] initWithReceiptManager:nil];
  FlutterMethodChannel *mockChannel = OCMClassMock([FlutterMethodChannel class]);
  plugin.transactionObserverCallbackChannel = mockChannel;
  OCMStub([mockChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]]);

  NSError *error;
  [plugin handleTransactionRestoreFailed:error];
  OCMVerify(times(1), [mockChannel invokeMethod:@"restoreCompletedTransactionsFailed"
                                      arguments:[FIAObjectTranslator getMapFromNSError:error]]);
}

- (void)testRestoreCompletedTransactionsFinished {
  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc] initWithReceiptManager:nil];
  FlutterMethodChannel *mockChannel = OCMClassMock([FlutterMethodChannel class]);
  plugin.transactionObserverCallbackChannel = mockChannel;
  OCMStub([mockChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]]);

  [plugin restoreCompletedTransactionsFinished];
  OCMVerify(times(1), [mockChannel invokeMethod:@"paymentQueueRestoreCompletedTransactionsFinished"
                                      arguments:nil]);
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
  SKProductStub *product = [[SKProductStub alloc] initWithMap:productMap];

  InAppPurchasePlugin *plugin = [[InAppPurchasePlugin alloc] initWithReceiptManager:nil];
  FlutterMethodChannel *mockChannel = OCMClassMock([FlutterMethodChannel class]);
  plugin.transactionObserverCallbackChannel = mockChannel;
  OCMStub([mockChannel invokeMethod:[OCMArg any] arguments:[OCMArg any]]);

  NSDictionary *args = @{
    @"payment" : [FIAObjectTranslator getMapFromSKPayment:payment],
    @"product" : [FIAObjectTranslator getMapFromSKProduct:product]
  };

  BOOL result = [plugin shouldAddStorePayment:payment product:product];
  XCTAssertEqual(result, NO);
  OCMVerify(times(1), [mockChannel invokeMethod:@"shouldAddStorePayment" arguments:args]);
}

#if TARGET_OS_IOS
- (void)testShowPriceConsentIfNeeded {
  FIAPaymentQueueHandler *mockQueueHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  self.plugin.paymentQueueHandler = mockQueueHandler;

  FlutterError *error;
  [self.plugin showPriceConsentIfNeededWithError:&error];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  if (@available(iOS 13.4, *)) {
    OCMVerify(times(1), [mockQueueHandler showPriceConsentIfNeeded]);
  } else {
    OCMVerify(never(), [mockQueueHandler showPriceConsentIfNeeded]);
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
