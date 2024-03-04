// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <StoreKit/StoreKit.h>
#import "FIAPRequestHandler.h"
#import "InAppPurchasePlugin.h"

@interface InAppPurchasePlugin ()

// Holding strong references to FIAPRequestHandlers. Remove the handlers from the set after
// the request is finished.
@property(strong, nonatomic, readonly) NSMutableSet *requestHandlers;

// Callback channel to dart used for when a function from the transaction observer is triggered.
@property(strong, nonatomic) FlutterMethodChannel *transactionObserverCallbackChannel;

// Callback channel to dart used for when a function from the transaction observer is triggered.
@property(strong, nonatomic) FIAPRequestHandler * (^handlerFactory)(SKRequest *);

// Convenience initializer with dependancy injection
- (instancetype)initWithReceiptManager:(FIAPReceiptManager *)receiptManager
                        handlerFactory:(FIAPRequestHandler * (^)(SKRequest *))handlerFactory;

// Transaction observer methods
- (void)handleTransactionsUpdated:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)handleTransactionsRemoved:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)handleTransactionRestoreFailed:(NSError *)error;
- (void)restoreCompletedTransactionsFinished;
- (BOOL)shouldAddStorePayment:(SKPayment *)payment product:(SKProduct *)product;

@end
