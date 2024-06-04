// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response,
                                         NSError *_Nullable errror);

@interface FIAPRequestHandler : NSObject

- (instancetype)initWithRequest:(SKRequest *)request;
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

@end

@protocol RequestHandler <NSObject>

- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

@end

@interface DefaultRequestHandler : NSObject<RequestHandler>
- (instancetype)initWithRequestHandler:(FIAPRequestHandler*)handler;
@property FIAPRequestHandler *handler;
@end

@interface TestRequestHandler : NSObject<RequestHandler>
@property (nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)(ProductRequestCompletion);
@end

NS_ASSUME_NONNULL_END
