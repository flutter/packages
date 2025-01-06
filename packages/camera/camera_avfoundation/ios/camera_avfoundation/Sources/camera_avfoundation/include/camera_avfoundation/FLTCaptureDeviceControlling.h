// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCaptureDeviceControlling <NSObject>

// Device
- (NSString *)uniqueID;

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
- (BOOL)isFocusPointOfInterestSupported;
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode;
- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
- (void)setFocusPointOfInterest:(CGPoint)point;

// Exposure
- (BOOL)isExposurePointOfInterestSupported;
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

@end

@protocol FLTCaptureDeviceInputFactory <NSObject>
+ (nullable AVCaptureInput*)deviceInputWithDevice:(id<FLTCaptureDeviceControlling>)device
                                            error:(NSError **)error;
@end

@interface AVCaptureDevice (FLTCaptureDeviceControlling) <FLTCaptureDeviceControlling>
@end

@interface AVCaptureDeviceInput (FLTCaptureDeviceInputFactory) <FLTCaptureDeviceInputFactory>
@end

NS_ASSUME_NONNULL_END
