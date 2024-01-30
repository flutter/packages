// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "FIAPaymentQueueHandler.h"
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

- (void)testInvalidMethodCall {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect result to be not implemented"];
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"invalid" arguments:NULL];
  __block id result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(result, FlutterMethodNotImplemented);
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
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect response contains 1 item"];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin startProductRequest:result:]"
                     arguments:@[ @"123" ]];
  __block id result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssert([result isKindOfClass:[NSDictionary class]]);
  NSArray *resultArray = [result objectForKey:@"products"];
  XCTAssertEqual(resultArray.count, 1);
  XCTAssertTrue([resultArray.firstObject[@"productIdentifier"] isEqualToString:@"123"]);
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
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin restoreTransactions:result:]"
                     arguments:nil];
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
  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(callbackInvoked);
}

- (void)testRetrieveReceiptDataSuccess {
  XCTestExpectation *expectation = [self expectationWithDescription:@"receipt data retrieved"];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin retrieveReceiptData:result:]"
                     arguments:nil];
  __block NSDictionary *result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNotNil(result);
  XCTAssert([result isKindOfClass:[NSString class]]);
}

- (void)testRetrieveReceiptDataNil {
  NSBundle *mockBundle = OCMPartialMock([NSBundle mainBundle]);
  OCMStub(mockBundle.appStoreReceiptURL).andReturn(nil);
  XCTestExpectation *expectation = [self expectationWithDescription:@"nil receipt data retrieved"];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin retrieveReceiptData:result:]"
                     arguments:nil];
  __block NSDictionary *result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNil(result);
}

- (void)testRetrieveReceiptDataError {
  XCTestExpectation *expectation = [self expectationWithDescription:@"receipt data retrieved"];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin retrieveReceiptData:result:]"
                     arguments:nil];
  __block NSDictionary *result;
  self.receiptManagerStub.returnError = YES;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNotNil(result);
  XCTAssert([result isKindOfClass:[FlutterError class]]);
  NSDictionary *details = ((FlutterError *)result).details;
  XCTAssertNotNil(details[@"error"]);
  NSNumber *errorCode = (NSNumber *)details[@"error"][@"code"];
  XCTAssertEqual(errorCode, [NSNumber numberWithInteger:99]);
}

- (void)testRefreshReceiptRequest {
  XCTestExpectation *expectation = [self expectationWithDescription:@"expect success"];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"-[InAppPurchasePlugin refreshReceipt:result:]"
                                        arguments:nil];
  __block BOOL result = NO;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = YES;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(result);
}

- (void)testPresentCodeRedemptionSheet {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect successfully present Code Redemption Sheet"];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin presentCodeRedemptionSheet:result:]"
                     arguments:nil];
  __block BOOL callbackInvoked = NO;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           callbackInvoked = YES;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(callbackInvoked);
}

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
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Should return success result"];
  FlutterMethodCall *startCall = [FlutterMethodCall
      methodCallWithMethodName:@"-[SKPaymentQueue startObservingTransactionQueue]"
                     arguments:nil];
  FIAPaymentQueueHandler *mockHandler = OCMClassMock([FIAPaymentQueueHandler class]);
  self.plugin.paymentQueueHandler = mockHandler;
  [self.plugin handleMethodCall:startCall
                         result:^(id _Nullable result) {
                           XCTAssertNil(result);
                           [expectation fulfill];
                         }];

  [self waitForExpectations:@[ expectation ] timeout:5];
  OCMVerify(times(1), [mockHandler startObservingPaymentQueue]);
}

- (void)testStopObservingPaymentQueue {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Should return success result"];
  FlutterMethodCall *stopCall =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue stopObservingTransactionQueue]"
                                        arguments:nil];
  FIAPaymentQueueHandler *mockHandler = OCMClassMock([FIAPaymentQueueHandler class]);
  self.plugin.paymentQueueHandler = mockHandler;
  [self.plugin handleMethodCall:stopCall
                         result:^(id _Nullable result) {
                           XCTAssertNil(result);
                           [expectation fulfill];
                         }];

  [self waitForExpectations:@[ expectation ] timeout:5];
  OCMVerify(times(1), [mockHandler stopObservingPaymentQueue]);
}

#if TARGET_OS_IOS
- (void)testRegisterPaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    FlutterMethodCall *call =
        [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue registerDelegate]"
                                          arguments:nil];

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

    [self.plugin handleMethodCall:call
                           result:^(id r){
                           }];

    // Verify the delegate is not nil after we registered one.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);
  }
}
#endif

- (void)testRemovePaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    FlutterMethodCall *call =
        [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue removeDelegate]"
                                          arguments:nil];

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

    [self.plugin handleMethodCall:call
                           result:^(id r){
                           }];

    // Verify the delegate is nill after removing it.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);
  }
}

#if TARGET_OS_IOS
- (void)testShowPriceConsentIfNeeded {
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue showPriceConsentIfNeeded]"
                                        arguments:nil];

  FIAPaymentQueueHandler *mockQueueHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  self.plugin.paymentQueueHandler = mockQueueHandler;

  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];

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
