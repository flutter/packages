// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@protocol ResourceLoaderManagerDelegate;

@interface ResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>

@property(nonatomic, weak) id<ResourceLoaderManagerDelegate> delegate;

- (void)cleanCache;

- (void)cancelLoaders;

@end

@protocol ResourceLoaderManagerDelegate <NSObject>

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface ResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url;
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end
