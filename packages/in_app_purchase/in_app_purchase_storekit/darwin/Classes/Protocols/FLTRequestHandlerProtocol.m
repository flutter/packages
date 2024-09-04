// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTRequestHandlerProtocol.h"
#import <Foundation/Foundation.h>
#import "FIAPRequestHandler.h"

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
