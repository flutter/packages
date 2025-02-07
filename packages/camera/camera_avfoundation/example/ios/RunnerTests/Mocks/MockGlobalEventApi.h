// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif

/// A mock implementation of `FCPCameraGlobalEventApi` that captures received
/// `deviceOrientationChanged` events and exposes the information whether they were received to the
/// testing code.
@interface MockGlobalEventApi : FCPCameraGlobalEventApi

/// Whether the `deviceOrientationChanged` callback was called.
@property(nonatomic) BOOL deviceOrientationChangedCalled;

/// The last orientation received by the `deviceOrientationChanged` callback.
@property(nonatomic) FCPPlatformDeviceOrientation lastOrientation;

@end
