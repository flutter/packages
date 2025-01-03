// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTEventChannel <NSObject>
- (void)setStreamHandler:(nullable NSObject<FlutterStreamHandler> *)handler;
@end

@interface FlutterEventChannel (FLTEventChannel) <FLTEventChannel>
@end

NS_ASSUME_NONNULL_END
