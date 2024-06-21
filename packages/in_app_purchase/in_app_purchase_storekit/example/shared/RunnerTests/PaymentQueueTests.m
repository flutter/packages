// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface PaymentQueueTest : XCTestCase

@property(nonatomic, strong) NSDictionary *periodMap;
@property(nonatomic, strong) NSDictionary *discountMap;
@property(nonatomic, strong) NSDictionary *productMap;
@property(nonatomic, strong) NSDictionary *productResponseMap;

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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];
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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];

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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];

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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];

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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];
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
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
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
      transactionCache:[[TransactionCacheStub alloc] init]];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheIsEmpty {
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[PaymentQueueStub alloc] init]
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
          transactionCache:cacheStub];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvokedCount = 0;

  cacheStub.getObjectsForKeyStub = ^NSArray *_Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvokedCount++;
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvokedCount++;
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvokedCount++;
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
    return nil;
  };

  [handler startObservingPaymentQueue];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvokedCount);
}

- (void)
    testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheContainsEmptyTransactionArrays {
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[PaymentQueueStub alloc] init]
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
          transactionCache:cacheStub];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvokedCount = 0;

  cacheStub.getObjectsForKeyStub = ^NSArray *_Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvokedCount++;
        return @[];
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvokedCount++;
        return @[];
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvokedCount++;
        return @[];
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };

  [handler startObservingPaymentQueue];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvokedCount);
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
  SKPaymentTransaction *transactionStub = [[SKPaymentTransactionStub alloc] init];
  SKDownload *downloadStub = [[SKDownload alloc] init];
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[PaymentQueueStub alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ transactionStub ]);
            [updateTransactionsExpectation fulfill];
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ transactionStub ]);
            [removeTransactionsExpectation fulfill];
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTAssertEqualObjects(downloads, @[ downloadStub ]);
            [updateDownloadsExpectation fulfill];
          }
          transactionCache:cacheStub];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvokedCount = 0;

  cacheStub.getObjectsForKeyStub = ^NSArray *_Nonnull(TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvokedCount++;
        return @[ transactionStub ];
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvokedCount++;
        return @[ downloadStub ];
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvokedCount++;
        return @[ transactionStub ];
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };

  __block NSInteger clearInvokedCount = 0;
  cacheStub.clearStub = ^{
    clearInvokedCount++;
  };

  [handler startObservingPaymentQueue];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyUpdatedDownloadsInvokedCount);
  XCTAssertEqual(1, TransactionCacheKeyRemovedTransactionsInvokedCount);
  XCTAssertEqual(1, clearInvokedCount);
}

- (void)testTransactionsShouldBeCachedWhenNotObserving {
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
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
      transactionCache:cacheStub];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvokedCount = 0;

  cacheStub.addObjectsStub = ^(NSArray *_Nonnull objects, TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvokedCount++;
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvokedCount++;
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvokedCount++;
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };

  [handler addPayment:payment];

  XCTAssertEqual(1, TransactionCacheKeyUpdatedTransactionsInvokedCount);
  XCTAssertEqual(0, TransactionCacheKeyUpdatedDownloadsInvokedCount);
  XCTAssertEqual(0, TransactionCacheKeyRemovedTransactionsInvokedCount);
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
  SKPaymentTransaction *transactionStub = [[SKPaymentTransactionStub alloc] init];
  SKDownload *downloadStub = [[SKDownload alloc] init];
  PaymentQueueStub *queue = [[PaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStatePurchased;
  TransactionCacheStub *cacheStub = [[TransactionCacheStub alloc] init];
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ transactionStub ]);
        [updateTransactionsExpectation fulfill];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ transactionStub ]);
        [removeTransactionsExpectation fulfill];
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
        XCTAssertEqualObjects(downloads, @[ downloadStub ]);
        [updateDownloadsExpectation fulfill];
      }
      transactionCache:cacheStub];

  SKPaymentQueueStub *paymentQueueStub = [[SKPaymentQueueStub alloc] init];

  [handler startObservingPaymentQueue];
  [handler paymentQueue:paymentQueueStub updatedTransactions:@[ transactionStub ]];
  [handler paymentQueue:paymentQueueStub removedTransactions:@[ transactionStub ]];
  [handler paymentQueue:paymentQueueStub updatedDownloads:@[ downloadStub ]];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];

  __block NSInteger TransactionCacheKeyUpdatedTransactionsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyUpdatedDownloadsInvokedCount = 0;
  __block NSInteger TransactionCacheKeyRemovedTransactionsInvokedCount = 0;

  cacheStub.addObjectsStub = ^(NSArray *_Nonnull objects, TransactionCacheKey key) {
    switch (key) {
      case TransactionCacheKeyUpdatedTransactions:
        TransactionCacheKeyUpdatedTransactionsInvokedCount++;
        break;
      case TransactionCacheKeyUpdatedDownloads:
        TransactionCacheKeyUpdatedDownloadsInvokedCount++;
        break;
      case TransactionCacheKeyRemovedTransactions:
        TransactionCacheKeyRemovedTransactionsInvokedCount++;
        break;
      default:
        XCTFail("Invalid transaction state was invoked.");
    }
  };
  XCTAssertEqual(0, TransactionCacheKeyUpdatedTransactionsInvokedCount);
  XCTAssertEqual(0, TransactionCacheKeyUpdatedDownloadsInvokedCount);
  XCTAssertEqual(0, TransactionCacheKeyRemovedTransactionsInvokedCount);
}
@end
