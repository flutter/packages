// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FLTRequestHandlerProtocol.h"

// StoreKit 1 is intentionally used as the fallback on iOS < 15 and macOS < 12,
// where StoreKit 2 is unavailable. Suppress its deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NS_ASSUME_NONNULL_BEGIN

@interface FIAPRequestHandler : NSObject <FLTRequestHandlerProtocol>

- (instancetype)initWithRequest:(SKRequest *)request;
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

@end

// The default request handler that wraps FIAPRequestHandler
@interface DefaultRequestHandler : NSObject <FLTRequestHandlerProtocol>

// Initialize this wrapper with an instance of FIAPRequestHandler
- (instancetype)initWithRequestHandler:(FIAPRequestHandler *)handler;
@end
NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
