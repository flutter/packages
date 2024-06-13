#import "FLTRequestHandlerProtocol.h"
#import <Foundation/Foundation.h>
#import "FIAPRequestHandler.h"

@interface DefaultRequestHandler ()
// The wrapped FIAPRequestHandler
@property(strong, nonatomic) FIAPRequestHandler *handler;
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
