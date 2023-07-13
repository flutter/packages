
#import <Foundation/Foundation.h>

@protocol ContentDownloaderDelegate;
@class ContentInfo;
@class ContentCacheWorker;

@interface ContentDownloaderStatus : NSObject

+ (instancetype)shared;

- (void)addURL:(NSURL *)url;
- (void)removeURL:(NSURL *)url;

/**
 return YES if downloading the url source
 */
- (BOOL)containsURL:(NSURL *)url;
- (NSSet *)urls;

@end

@interface ContentDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(ContentCacheWorker *)cacheWorker;
@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, weak) id<ContentDownloaderDelegate> delegate;
@property(nonatomic, strong) ContentInfo *info;
@property(nonatomic, assign) BOOL saveToCache;

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;
- (void)downloadFromStartToEnd;

- (void)cancel;

@end

@protocol ContentDownloaderDelegate <NSObject>

@optional
- (void)contentDownloader:(ContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response;
- (void)contentDownloader:(ContentDownloader *)downloader didReceiveData:(NSData *)data;
- (void)contentDownloader:(ContentDownloader *)downloader didFinishedWithError:(NSError *)error;

@end
