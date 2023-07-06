
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ResourceLoaderManagerDelegate;

@interface ResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>


@property (nonatomic, weak) id<ResourceLoaderManagerDelegate> delegate;

/**
 Normally you no need to call this method to clean cache. Cache cleaned after AVPlayer delloc.
 If you have a singleton AVPlayer then you need call this method to clean cache at suitable time.
 */
- (void)cleanCache;

/**
 Cancel all downloading loaders.
 */
- (void)cancelLoaders;

@end

@protocol ResourceLoaderManagerDelegate <NSObject>

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface ResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url;
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end
