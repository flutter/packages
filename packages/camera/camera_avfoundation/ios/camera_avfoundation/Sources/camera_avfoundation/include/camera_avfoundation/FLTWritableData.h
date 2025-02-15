// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which abstracts the file writing operation implemented in `NSData`.
/// It exists to allow replacing `NSData` in tests.
@protocol FLTWritableData <NSObject>
- (BOOL)writeToFile:(NSString *)path
            options:(NSDataWritingOptions)writeOptionsMask
              error:(NSError **)errorPtr;
@end

/// A default implementation of the `FLTWritableData` protocol which operates on
/// an `NSData` instance.
@interface FLTDefaultWritableData : NSObject <FLTWritableData>
@property(nonatomic, strong, readonly) NSData *data;
- (instancetype)initWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
