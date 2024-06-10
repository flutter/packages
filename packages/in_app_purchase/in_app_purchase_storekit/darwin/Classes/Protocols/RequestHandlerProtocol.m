#import "RequestHandlerProtocol.h"
#import <Foundation/Foundation.h>
#import "FIAPRequestHandler.h"

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
