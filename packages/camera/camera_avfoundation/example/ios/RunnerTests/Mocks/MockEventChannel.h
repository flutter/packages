// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

/// A mock implementation of `FLTEventChannel` that allows injecting a custom stream handler.
@interface MockEventChannel : NSObject <FLTEventChannel>

/// Overrides the default implementation of setting the stream handler.
@property(nonatomic, copy) void (^setStreamHandlerStub)(NSObject<FlutterStreamHandler> *);

@end

NS_ASSUME_NONNULL_END
