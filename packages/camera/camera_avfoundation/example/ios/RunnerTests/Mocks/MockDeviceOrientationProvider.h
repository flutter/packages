// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockDeviceOrientationProvider : NSObject <FLTDeviceOrientationProviding>
@property(nonatomic, assign) UIDeviceOrientation orientation;
@end

NS_ASSUME_NONNULL_END
