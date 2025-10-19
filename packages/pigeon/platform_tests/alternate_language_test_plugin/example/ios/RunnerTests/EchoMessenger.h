// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// A FlutterBinaryMessenger who replies with the first argument sent to it.
@interface EchoBinaryMessenger : NSObject <FlutterBinaryMessenger>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec;
@end

NS_ASSUME_NONNULL_END
