// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <RequestHandlerProtocol.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FIAPRequestHandler : NSObject <RequestHandler>

- (instancetype)initWithRequest:(SKRequest *)request;
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

@end

@interface DefaultRequestHandler : NSObject <RequestHandler>
@property FIAPRequestHandler *handler;
- (instancetype)initWithRequestHandler:(FIAPRequestHandler *)handler;
@end
NS_ASSUME_NONNULL_END
