// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to AVCaptureDevice.
/// It exists to allow replacing AVCaptureDevice in tests.
@protocol FLTCaptureDeviceControlling <NSObject>

// Position/Orientation
- (AVCaptureDevicePosition)position;

// Format/Configuration
- (AVCaptureDeviceFormat *)activeFormat;
- (NSArray<AVCaptureDeviceFormat *> *)formats;
- (void)setActiveFormat:(AVCaptureDeviceFormat *)format;

// Flash/Torch
- (BOOL)hasFlash;
- (BOOL)hasTorch;
- (BOOL)isTorchAvailable;
- (AVCaptureTorchMode)torchMode;
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode;

// Focus
- (BOOL)focusPointOfInterestSupported;
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode;
- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
- (void)setFocusPointOfInterest:(CGPoint)point;

// Exposure
- (BOOL)exposurePointOfInterestSupported;
- (void)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (void)setExposurePointOfInterest:(CGPoint)point;
- (float)minExposureTargetBias;
- (float)maxExposureTargetBias;
- (void)setExposureTargetBias:(float)bias completionHandler:(void (^_Nullable)(CMTime))handler;
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode;

// Zoom
- (float)maxAvailableVideoZoomFactor;
- (float)minAvailableVideoZoomFactor;
- (float)videoZoomFactor;
- (void)setVideoZoomFactor:(float)factor;

// Camera Properties
- (float)lensAperture;
- (CMTime)exposureDuration;
- (float)ISO;

// Configuration Lock
- (BOOL)lockForConfiguration:(NSError **)error;
- (void)unlockForConfiguration;

// Frame Duration
- (CMTime)activeVideoMinFrameDuration;
- (void)setActiveVideoMinFrameDuration:(CMTime)duration;
- (CMTime)activeVideoMaxFrameDuration;
- (void)setActiveVideoMaxFrameDuration:(CMTime)duration;

- (AVCaptureInput *)createInput:(NSError *_Nullable *_Nullable)error;

@end

/// A default implementation of FLTCaptureDeviceControlling protocol which
/// wraps an instance of AVCaptureDevice.
@interface FLTDefaultCaptureDeviceController : NSObject <FLTCaptureDeviceControlling>

/// Initializes the controller with the given device.
- (instancetype)initWithDevice:(AVCaptureDevice *)device;

@end

NS_ASSUME_NONNULL_END
