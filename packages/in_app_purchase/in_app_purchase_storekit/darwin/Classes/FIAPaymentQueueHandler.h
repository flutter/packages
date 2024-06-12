// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "FLTPaymentQueueHandlerProtocol.h"
#import "FLTPaymentQueueProtocol.h"
#import "FLTTransactionCacheProtocol.h"

@class SKPaymentTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface FIAPaymentQueueHandler
    : NSObject <SKPaymentTransactionObserver, FLTPaymentQueueHandlerProtocol>
@end

NS_ASSUME_NONNULL_END
