// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^HandlerBinaryMessengerHandler)(NSArray<id> *_Nonnull args);

/// A FlutterBinaryMessenger that calls a supplied method when a call is
/// invoked.
@interface HandlerBinaryMessenger : NSObject <FlutterBinaryMessenger>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec
                      handler:(HandlerBinaryMessengerHandler)handler;
@end

NS_ASSUME_NONNULL_END
