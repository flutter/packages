// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/in_app_purchase_storekit_objc/FIAPRequestHandler.h"
#import <StoreKit/StoreKit.h>

#pragma mark - Main Handler

@interface FIAPRequestHandler () <SKProductsRequestDelegate>

@property(nonatomic, copy) ProductRequestCompletion completion;
@property(nonatomic, strong) SKRequest *request;

@end

@implementation FIAPRequestHandler

- (instancetype)initWithRequest:(SKRequest *)request {
  self = [super init];
  if (self) {
    self.request = request;
    request.delegate = self;
  }
  return self;
}

- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion {
  self.completion = completion;
  [self.request start];
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  if (self.completion) {
    self.completion(response, nil);
    // set the completion to nil here so self.completion won't be triggered again in
    // requestDidFinish for SKProductRequest.
    self.completion = nil;
  }
}

- (void)requestDidFinish:(SKRequest *)request {
  if (self.completion) {
    self.completion(nil, nil);
  }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  if (self.completion) {
    self.completion(nil, error);
  }
}

@end
