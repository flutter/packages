#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol ResourceLoaderDelegate;

@interface ResourceLoader : NSObject

@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, weak) id<ResourceLoaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (void)addRequest:(AVAssetResourceLoadingRequest *)request;
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;

- (void)cancel;

@end

@protocol ResourceLoaderDelegate <NSObject>

- (void)resourceLoader:(ResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end
