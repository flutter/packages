// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/in_app_purchase_storekit_objc/FLTRequestHandlerProtocol.h"
#import <Foundation/Foundation.h>
#import "../include/in_app_purchase_storekit_objc/FIAPRequestHandler.h"

@interface DefaultRequestHandler ()
/// The wrapped FIAPRequestHandler
@property(nonatomic, strong) FIAPRequestHandler *handler;
@end

@implementation DefaultRequestHandler

- (void)startProductRequestWithCompletionHandler:(nonnull ProductRequestCompletion)completion {
  [self.handler startProductRequestWithCompletionHandler:completion];
}

- (nonnull instancetype)initWithRequestHandler:(nonnull FIAPRequestHandler *)handler {
  self = [super init];
  if (self) {
    _handler = handler;
  }
  return self;
}
@end
