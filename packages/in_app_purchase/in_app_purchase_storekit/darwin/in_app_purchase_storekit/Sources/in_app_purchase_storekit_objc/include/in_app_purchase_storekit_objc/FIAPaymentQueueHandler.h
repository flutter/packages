// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"
#import "FLTPaymentQueueHandlerProtocol.h"
#import "FLTPaymentQueueProtocol.h"
#import "FLTTransactionCacheProtocol.h"

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@class SKPaymentTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface FIAPaymentQueueHandler
    : NSObject <SKPaymentTransactionObserver, FLTPaymentQueueHandlerProtocol>
@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
