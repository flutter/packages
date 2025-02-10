// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// A mock implementation of `FLTDeviceOrientationProviding` that allows mocking the class
/// properties.
@interface MockCaptureDeviceFormat : NSObject <FLTCaptureDeviceFormat>

/// Initializes a `MockCaptureDeviceFormat` with the given dimensions.
- (instancetype)initWithDimensions:(CMVideoDimensions)dimensions;

// Properties redeclared as read/write to allow mocking.
@property(nonatomic, strong) AVCaptureDeviceFormat *format;
@property(nonatomic, strong) NSArray<NSObject<FLTFrameRateRange> *> *videoSupportedFrameRateRanges;
@property(nonatomic, assign) CMFormatDescriptionRef formatDescription;

@end

/// A mock implementation of `FLTFrameRateRange` that allows mocking the class properties.
@interface MockFrameRateRange : NSObject <FLTFrameRateRange>

/// Initializes a `MockFrameRateRange` with the given frame rate range.
- (instancetype)initWithMinFrameRate:(float)minFrameRate maxFrameRate:(float)maxFrameRate;

// Properties redeclared as read/write to allow mocking.
@property(nonatomic, assign) float minFrameRate;
@property(nonatomic, assign) float maxFrameRate;

@end

NS_ASSUME_NONNULL_END
