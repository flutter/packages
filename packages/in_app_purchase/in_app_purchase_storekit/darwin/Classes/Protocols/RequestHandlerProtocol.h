#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response,
                                         NSError *_Nullable errror);
@protocol RequestHandler <NSObject>
// Wrapper for SKRequest's start https://developer.apple.com/documentation/storekit/skrequest/1385534-start
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;
@end
NS_ASSUME_NONNULL_END
