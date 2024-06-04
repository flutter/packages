// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface PaymentQueueTest : XCTestCase

@property(strong, nonatomic) NSDictionary *periodMap;
@property(strong, nonatomic) NSDictionary *discountMap;
@property(strong, nonatomic) NSDictionary *productMap;
@property(strong, nonatomic) NSDictionary *productResponseMap;

@end

@implementation PaymentQueueTest

- (void)setUp {
  self.periodMap = @{@"numberOfUnits" : @(0), @"unit" : @(0)};
  self.discountMap = @{
    @"price" : @1.0,
    @"currencyCode" : @"USD",
    @"numberOfPeriods" : @1,
    @"subscriptionPeriod" : self.periodMap,
    @"paymentMode" : @1
  };
  self.productMap = @{
    @"price" : @1.0,
    @"currencyCode" : @"USD",
    @"productIdentifier" : @"123",
    @"localizedTitle" : @"title",
    @"localizedDescription" : @"des",
    @"subscriptionPeriod" : self.periodMap,
    @"introductoryPrice" : self.discountMap,
    @"subscriptionGroupIdentifier" : @"com.group"
  };
  self.productResponseMap =
      @{@"products" : @[ self.productMap ], @"invalidProductIdentifiers" : [NSNull null]};
}

- (void)testTransactionPurchased {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get purchased transcation."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStatePurchased;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStatePurchased);
  XCTAssertEqualObjects(tran.transactionIdentifier, @"fakeID");
}

- (void)testTransactionFailed {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get failed transcation."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStateFailed;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateFailed);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testTransactionRestored {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get restored transcation."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStateRestored;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateRestored);
  XCTAssertEqualObjects(tran.transactionIdentifier, @"fakeID");
}

- (void)testTransactionPurchasing {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get purchasing transcation."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStatePurchasing;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStatePurchasing);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testTransactionDeferred {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get deffered transcation."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStateDeferred;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateDeferred);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testFinishTransaction {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"handler.transactions should be empty."];
  TestPaymentQueue *queue = [TestPaymentQueue alloc];
  queue.testState = SKPaymentTransactionStateDeferred;
  __block FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqual(transactions.count, 1);
        SKPaymentTransaction *transaction = transactions[0];
        [handler finishTransaction:transaction];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqual(transactions.count, 1);
        [expectation fulfill];
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:[TestTransactionCache alloc]];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheIsEmpty {
  TestTransactionCache *mockCache = [[TestTransactionCache alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[TestPaymentQueue alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionsUpdated callback should not be called when cache is empty.");
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionRemoved callback should not be called when cache is empty.");
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTFail("updatedDownloads callback should not be called when cache is empty.");
          }
          transactionCache:mockCache];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvoked = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvoked = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvoked = 0;

  mockCache.getObjectsForKeyStub = ^NSArray * _Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvoked++;
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvoked++;
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvoked++;
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
    return nil;
  };

  [handler startObservingPaymentQueue];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvoked);
}

- (void)
    testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheContainsEmptyTransactionArrays {
  TestTransactionCache *mockCache = [[TestTransactionCache alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[TestPaymentQueue alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionsUpdated callback should not be called when cache is empty.");
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionRemoved callback should not be called when cache is empty.");
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTFail("updatedDownloads callback should not be called when cache is empty.");
          }
          transactionCache:mockCache];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvoked = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvoked = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvoked = 0;

  mockCache.getObjectsForKeyStub = ^NSArray * _Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvoked++;
        return @[];
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvoked++;
        return @[];
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvoked++;
        return @[];
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };

  [handler startObservingPaymentQueue];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvoked);
}

- (void)testStartObservingPaymentQueueShouldProcessTransactionsForItemsInCache {
  XCTestExpectation *updateTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsUpdated callback should be called with one transaction."];
  XCTestExpectation *removeTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsRemoved callback should be called with one transaction."];
  XCTestExpectation *updateDownloadsExpectation =
      [self expectationWithDescription:
                @"downloadsUpdated callback should be called with one transaction."];
  SKPaymentTransaction *mockTransaction = [FakeSKPaymentTransaction alloc];
  FakeSKDownload *mockDownload = [[FakeSKDownload alloc] init];
  TestTransactionCache *mockCache = [[TestTransactionCache alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[TestPaymentQueue alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
            [updateTransactionsExpectation fulfill];
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
            [removeTransactionsExpectation fulfill];
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTAssertEqualObjects(downloads, @[ mockDownload ]);
            [updateDownloadsExpectation fulfill];
          }
          transactionCache:mockCache];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvoked = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvoked = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvoked = 0;

  mockCache.getObjectsForKeyStub = ^NSArray * _Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvoked++;
        return @[ mockTransaction ];
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvoked++;
        return @[ mockDownload ];
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvoked++;
        return @[ mockTransaction ];
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };

  __block NSInteger clearInvoked = 0;
  mockCache.clearStub = ^{
    clearInvoked++;
  };

  [handler startObservingPaymentQueue];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvoked);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvoked);
  XCTAssertEqual(1, clearInvoked);
}

- (void)testTransactionsShouldBeCachedWhenNotObserving {
  TestPaymentQueue *queue = [[TestPaymentQueue alloc] init];
  TestTransactionCache *mockCache = [TestTransactionCache alloc];
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTFail("transactionsUpdated callback should not be called when cache is empty.");
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTFail("transactionRemoved callback should not be called when cache is empty.");
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
        XCTFail("updatedDownloads callback should not be called when cache is empty.");
      }
      transactionCache:mockCache];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvoked = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvoked = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvoked = 0;

  mockCache.addObjectsStub = ^(NSArray * _Nonnull objects, TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvoked++;
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvoked++;
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvoked++;
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };


  [handler addPayment:payment];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvoked);
  XCTAssertEqual(0, TransactionCacheKeyUpdatedDownloadsInvoked);
  XCTAssertEqual(0, TransactionCacheKeyRemovedTransactionsInvoked);
}

- (void)testTransactionsShouldNotBeCachedWhenObserving {
  XCTestExpectation *updateTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsUpdated callback should be called with one transaction."];
  XCTestExpectation *removeTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsRemoved callback should be called with one transaction."];
  XCTestExpectation *updateDownloadsExpectation =
      [self expectationWithDescription:
                @"downloadsUpdated callback should be called with one transaction."];
  SKPaymentTransaction *mockTransaction = [[FakeSKPaymentTransaction alloc] init];
  SKDownload *mockDownload = [[FakeSKDownload alloc] init];
  TestPaymentQueue *queue = [[TestPaymentQueue alloc] init];
  queue.testState = SKPaymentTransactionStatePurchased;
  TestTransactionCache *mockCache = [[TestTransactionCache alloc] init];
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
        [updateTransactionsExpectation fulfill];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
        [removeTransactionsExpectation fulfill];
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
        XCTAssertEqualObjects(downloads, @[ mockDownload ]);
        [updateDownloadsExpectation fulfill];
      }
      transactionCache:mockCache];

  [handler startObservingPaymentQueue];
  [handler paymentQueue:queue updatedTransactions:@[ mockTransaction ]];
  [handler paymentQueue:queue removedTransactions:@[ mockTransaction ]];
  [handler paymentQueue:queue updatedDownloads:@[ mockDownload ]];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyRemovedTransactions]);
}
@end
