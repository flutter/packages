// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CacheType) { CacheTypeLocal = 0, CacheTypeRemote };

@interface CacheAction : NSObject

- (instancetype)initWithActionType:(CacheType)cacheType range:(NSRange)range;

@property(nonatomic) CacheType cacheType;
@property(nonatomic) NSRange range;

@end
