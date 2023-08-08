// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@interface FVPContentInfo : NSObject <NSCoding>

/**
 * @property contentType
 */
@property(nonatomic, copy) NSString *contentType;
/**
 * @property byteRangeAccessSupported
 */
@property(nonatomic, assign) BOOL byteRangeAccessSupported;
/**
 * @property contentLength
 */
@property(nonatomic, assign) unsigned long long contentLength;
/**
 * @property downloadedContentLength
 */
@property(nonatomic) unsigned long long downloadedContentLength;

@end
