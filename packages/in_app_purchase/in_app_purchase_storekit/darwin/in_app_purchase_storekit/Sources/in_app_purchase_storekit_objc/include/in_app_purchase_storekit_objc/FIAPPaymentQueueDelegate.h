// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif
#import <StoreKit/StoreKit.h>
#import "FLTMethodChannelProtocol.h"

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NS_ASSUME_NONNULL_BEGIN

API_UNAVAILABLE(tvos, watchos)
@interface FIAPPaymentQueueDelegate : NSObject <SKPaymentQueueDelegate>
- (id)initWithMethodChannel:(id<FLTMethodChannelProtocol>)methodChannel;
@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
