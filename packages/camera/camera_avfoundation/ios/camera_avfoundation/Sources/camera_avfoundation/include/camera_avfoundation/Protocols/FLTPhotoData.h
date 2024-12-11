// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTPhotoData <NSObject>
- (BOOL)writeToFile:(NSString *)path
           options:(NSDataWritingOptions)writeOptionsMask
             error:(NSError **)errorPtr;
@end


@interface FLTDefaultPhotoData : NSObject <FLTPhotoData>
@property(nonatomic, strong, readonly) NSData *data;
- (instancetype)initWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
