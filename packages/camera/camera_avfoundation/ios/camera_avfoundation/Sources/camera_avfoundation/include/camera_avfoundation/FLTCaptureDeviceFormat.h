// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `FLTFrameRateRange`. It exists to allow replacing
/// `AVFrameRateRange` in tests as it has no public initializer.
@protocol FLTFrameRateRange <NSObject>

@property(readonly, nonatomic) float minFrameRate;
@property(readonly, nonatomic) float maxFrameRate;

@end

/// A protocol which is a direct passthrough to `AVCaptureDeviceFormat`. It exists to allow
/// replacing `AVCaptureDeviceFormat` in tests as it has no public initializer.
@protocol FLTCaptureDeviceFormat <NSObject>

/// The underlying `AVCaptureDeviceFormat` instance that this object wraps.
@property(nonatomic, readonly) AVCaptureDeviceFormat *format;

@property(nonatomic, readonly) CMFormatDescriptionRef formatDescription;
@property(nonatomic, readonly)
    NSArray<NSObject<FLTFrameRateRange> *> *videoSupportedFrameRateRanges;

@end

/// A default implementation of `FLTFrameRateRange` that wraps an `AVFrameRateRange` instance.
@interface FLTDefaultFrameRateRange : NSObject <FLTFrameRateRange>

/// Initializes the object with an `AVFrameRateRange` instance. All method and property calls are
/// forwarded to this wrapped instance.
- (instancetype)initWithRange:(AVFrameRateRange *)range;

@end

/// A default implementation of `FLTCaptureDeviceFormat` that wraps an `AVCaptureDeviceFormat`
/// instance.
@interface FLTDefaultCaptureDeviceFormat : NSObject <FLTCaptureDeviceFormat>

/// Initializes the object with an `AVCaptureDeviceFormat` instance. All method and property calls
/// are forwarded to this wrapped instance.
- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format;

@end

NS_ASSUME_NONNULL_END
