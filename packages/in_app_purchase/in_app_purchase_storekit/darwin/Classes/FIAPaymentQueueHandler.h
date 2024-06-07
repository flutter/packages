// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "PaymentQueueProtocol.h"
#import "TransactionCacheProtocol.h"
#import "PaymentQueueHandlerProtocol.h"

@class SKPaymentTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface FIAPaymentQueueHandler : NSObject <SKPaymentTransactionObserver, PaymentQueueHandler>
@end

NS_ASSUME_NONNULL_END
