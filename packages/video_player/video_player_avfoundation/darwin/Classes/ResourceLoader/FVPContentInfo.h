// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
* `FVPContentInfo` is a model class that represents essential information about cached or downloaded
media content. It includes details such as content length, content type, * and whether byte-range
access is supported.

*
*  Usage:
*  1. Create an instance of `FVPContentInfo` with relevant content information.
*  2. Encode and decode instances for storage and retrieval as needed.
*
*  Example:

*  // Create an instance of FVPContentInfo with content information
*  FVPContentInfo *contentInfo = [[FVPContentInfo alloc] init];
*  contentInfo.contentLength = 1024 * 1024; // 1MB
*  contentInfo.contentType = @"video/mp4";
*  contentInfo.byteRangeAccessSupported = YES;
*
*  // Encode the contentInfo for storage
*  NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:contentInfo];
*  // Store or save the encodedData as needed
*
*  // Decode the contentInfo when retrieving from storage
*  FVPContentInfo *decodedContentInfo = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
* @warning Ensure that the encoding and decoding keys match the constants defined in this class.
*
* @see NSCoding
*/
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
