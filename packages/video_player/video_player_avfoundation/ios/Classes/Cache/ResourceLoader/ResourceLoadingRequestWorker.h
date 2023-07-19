

#import <Foundation/Foundation.h>

@class ContentDownloader, AVAssetResourceLoadingRequest;
@protocol ResourceLoadingRequestWorkerDelegate;

@interface ResourceLoadingRequestWorker : NSObject

- (instancetype)initWithContentDownloader:(ContentDownloader *)contentDownloader
                   resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request;

@property(nonatomic, weak) id<ResourceLoadingRequestWorkerDelegate> delegate;

@property(nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

- (void)startWork;
- (void)cancel;
- (void)finish;

@end

@protocol ResourceLoadingRequestWorkerDelegate <NSObject>

- (void)resourceLoadingRequestWorker:(ResourceLoadingRequestWorker *)requestWorker
                didCompleteWithError:(NSError *)error;

@end
