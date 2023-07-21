// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@interface CacheSessionManager : NSObject

@property(nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

+ (instancetype)shared;

@end
