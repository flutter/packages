// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockBinaryMessenger : NSObject <FlutterBinaryMessenger>
@property(nonatomic, retain) NSObject *result;
@property(nonatomic, retain) NSObject<FlutterMessageCodec> *codec;
@property(nonatomic, retain) NSMutableDictionary<NSString *, FlutterBinaryMessageHandler> *handlers;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
