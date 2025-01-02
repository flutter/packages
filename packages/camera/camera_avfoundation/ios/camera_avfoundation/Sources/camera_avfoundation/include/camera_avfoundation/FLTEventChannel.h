// Copyright 2013 The Flutter Authors. All rights reserved.
 // Use of this source code is governed by a BSD-style license that can be
 // found in the LICENSE file.

 @import Flutter;

 NS_ASSUME_NONNULL_BEGIN

 @protocol FLTEventChannel <NSObject>
 - (void)setStreamHandler:(nullable NSObject<FlutterStreamHandler> *)handler;
 @end

 /// The default method channel that wraps FlutterMethodChannel
 @interface FLTDefaultEventChannel : NSObject <FLTEventChannelProtocol>
 - (instancetype)initWithEventChannel:(FlutterEventChannel *)channel;
 @end

 NS_ASSUME_NONNULL_END
