// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockCaptureDeviceController : NSObject <FLTCaptureDeviceControlling>
// Position/Orientation
@property(nonatomic, assign) AVCaptureDevicePosition position;

// Format/Configuration
@property(nonatomic, strong) AVCaptureDeviceFormat *activeFormat;
@property(nonatomic, strong) NSArray<AVCaptureDeviceFormat *> *formats;
@property(nonatomic, copy) void (^setActiveFormatStub)(AVCaptureDeviceFormat *format);

// Flash/Torch
@property(nonatomic, assign) BOOL hasFlash;
@property(nonatomic, assign) BOOL hasTorch;
@property(nonatomic, assign) BOOL isTorchAvailable;
@property(nonatomic, assign) AVCaptureTorchMode torchMode;
@property(nonatomic, copy) void (^setTorchModeStub)(AVCaptureTorchMode mode);
@property(nonatomic, assign) BOOL flashModeSupported;

// Focus
@property(nonatomic, assign) BOOL focusPointOfInterestSupported;
@property(nonatomic, copy) BOOL (^isFocusModeSupportedStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) AVCaptureFocusMode focusMode;
@property(nonatomic, copy) void (^setFocusModeStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) CGPoint focusPointOfInterest;
@property(nonatomic, copy) void (^setFocusPointOfInterestStub)(CGPoint point);

// Exposure
@property(nonatomic, assign) BOOL exposurePointOfInterestSupported;
@property(nonatomic, assign) AVCaptureExposureMode exposureMode;
@property(nonatomic, assign) BOOL exposureModeSupported;
@property(nonatomic, copy) void (^setExposureModeStub)(AVCaptureExposureMode mode);
@property(nonatomic, assign) CGPoint exposurePointOfInterest;
@property(nonatomic, copy) void (^setExposurePointOfInterestStub)(CGPoint point);
@property(nonatomic, assign) float minExposureTargetBias;
@property(nonatomic, assign) float maxExposureTargetBias;
@property(nonatomic, copy) void (^setExposureTargetBiasStub)(float bias, void (^_Nullable handler)(CMTime));

// Zoom
@property(nonatomic, assign) float maxAvailableVideoZoomFactor;
@property(nonatomic, assign) float minAvailableVideoZoomFactor;
@property(nonatomic, assign) float videoZoomFactor;
@property(nonatomic, copy) void (^setVideoZoomFactorStub)(float factor);

// Camera Properties
@property(nonatomic, assign) float lensAperture;
@property(nonatomic, assign) CMTime exposureDuration;
@property(nonatomic, assign) float ISO;

// Configuration Lock
@property(nonatomic, assign) BOOL shouldFailConfiguration;
@property(nonatomic, copy) void (^lockForConfigurationStub)(NSError **error);
@property(nonatomic, copy) void (^unlockForConfigurationStub)(void);

// Frame Duration
@property(nonatomic, assign) CMTime activeVideoMinFrameDuration;
@property(nonatomic, assign) CMTime activeVideoMaxFrameDuration;
@property(nonatomic, copy) void (^setActiveVideoMinFrameDurationStub)(CMTime duration);
@property(nonatomic, copy) void (^setActiveVideoMaxFrameDurationStub)(CMTime duration);

// Input Creation
@property(nonatomic, strong) AVCaptureInput *inputToReturn;
@property(nonatomic, copy) void (^createInputStub)(NSError **error);

@property(nonatomic, assign) BOOL isExposurePointOfInterestSupported;
@property(nonatomic, assign) BOOL isFocusPointOfInterestSupported;

@end

NS_ASSUME_NONNULL_END
