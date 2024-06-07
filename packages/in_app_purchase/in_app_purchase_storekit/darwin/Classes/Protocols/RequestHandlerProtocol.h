#import <StoreKit/StoreKit.h>
#import "FIAPRequestHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RequestHandler <NSObject>

- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;

@end

@interface DefaultRequestHandler : NSObject <RequestHandler>
- (instancetype)initWithRequestHandler:(FIAPRequestHandler *)handler;
@property FIAPRequestHandler *handler;
@end

@interface TestRequestHandler : NSObject <RequestHandler>
@property(nonatomic, copy, nullable) void (^startProductRequestWithCompletionHandlerStub)
    (ProductRequestCompletion);
@end

NS_ASSUME_NONNULL_END
