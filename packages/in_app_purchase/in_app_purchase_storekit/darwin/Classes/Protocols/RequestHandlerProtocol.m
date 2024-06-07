#import <Foundation/Foundation.h>
#import "RequestHandlerProtocol.h"

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

@implementation TestRequestHandler

- (void)startProductRequestWithCompletionHandler:(nonnull ProductRequestCompletion)completion {
  if (_startProductRequestWithCompletionHandlerStub) {
    _startProductRequestWithCompletionHandlerStub(completion);
  }
}

@end
