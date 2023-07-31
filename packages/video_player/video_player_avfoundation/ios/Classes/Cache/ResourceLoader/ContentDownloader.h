// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol ContentDownloaderDelegate;
@class ContentInfo;
@class ContentCacheWorker;

@interface ContentDownloaderStatus : NSObject

+ (instancetype)shared;

/**
 add url source to downloading
 */
- (void)addURL:(NSURL *)url;

/**
 removes url source from downloading
 */
- (void)removeURL:(NSURL *)url;

/**
 return YES if downloading the url source
 */
- (BOOL)containsURL:(NSURL *)url;

/**
 return downloading urls
 */
- (NSSet *)urls;

@end

@interface ContentDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(ContentCacheWorker *)cacheWorker;

/**
 @property url
 url of video
 */
@property(nonatomic, strong, readonly) NSURL *url;

/**
 @property delegate
 ContentDownloaderDelegate
 */
@property(nonatomic, weak) id<ContentDownloaderDelegate> delegate;

/**
 @property info
 hold information about the content
 */
@property(nonatomic, strong) ContentInfo *info;

/**
 @property saveToCache
 should save to cache
 */
@property(nonatomic, assign) BOOL saveToCache;

/**
 start download with offset
 */
- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;
/**
 start download and sets the startToEnd property
 */
- (void)downloadFromStartToEnd;

/**
 cancels downloading
 */
- (void)cancel;

@end

@protocol ContentDownloaderDelegate <NSObject>

@optional

/**
 callback when received response
 */
- (void)contentDownloader:(ContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response;

/**
 callback when received data
 */
- (void)contentDownloader:(ContentDownloader *)downloader didReceiveData:(NSData *)data;

/**
 callback when error received
 */
- (void)contentDownloader:(ContentDownloader *)downloader didFinishedWithError:(NSError *)error;

@end
