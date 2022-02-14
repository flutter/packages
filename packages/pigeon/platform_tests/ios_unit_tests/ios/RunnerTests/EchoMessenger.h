// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A FlutterBinaryMessenger who replies with the first argument sent to it.
@interface EchoBinaryMessenger : NSObject <FlutterBinaryMessenger>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec>*)codec;
@end

NS_ASSUME_NONNULL_END
