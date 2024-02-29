// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import "FIAPRequestHandler.h"
#import <StoreKit/StoreKit.h>

@interface InAppPurchasePlugin ()

// Holding strong references to FIAPRequestHandlers. Remove the handlers from the set after
// the request is finished.
@property(strong, nonatomic, readonly) NSMutableSet *requestHandlers;
@property(strong, nonatomic) FlutterMethodChannel *transactionObserverCallbackChannel;

// Transaction observer methods
- (void)handleTransactionsUpdated:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)handleTransactionsRemoved:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)handleTransactionRestoreFailed:(NSError *)error;
- (void)restoreCompletedTransactionsFinished;
- (BOOL)shouldAddStorePayment:(SKPayment *)payment product:(SKProduct *)product;

// Dependency Injection
- (FIAPRequestHandler *)getHandler:(SKRequest *)request;
@end
