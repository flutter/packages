// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockCaptureDeviceController : NSObject <FLTCaptureDeviceControlling>
@property(nonatomic, assign) NSString *uniqueID;

// Position/Orientation
@property(nonatomic, assign) AVCaptureDevicePosition position;

// Format/Configuration
@property(nonatomic, strong) id<FLTCaptureDeviceFormat> activeFormat;
@property(nonatomic, strong) NSArray<id<FLTCaptureDeviceFormat>> *formats;
@property(nonatomic, copy) void (^setActiveFormatStub)(id<FLTCaptureDeviceFormat> format);

// Flash/Torch
@property(nonatomic, assign) BOOL hasFlash;
@property(nonatomic, assign) BOOL hasTorch;
@property(nonatomic, assign) BOOL isTorchAvailable;
@property(nonatomic, assign) AVCaptureTorchMode torchMode;
@property(nonatomic, copy) void (^setTorchModeStub)(AVCaptureTorchMode mode);
@property(nonatomic, assign) BOOL flashModeSupported;

// Focus
@property(nonatomic, assign) BOOL isFocusPointOfInterestSupported;
@property(nonatomic, copy) BOOL (^isFocusModeSupportedStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) AVCaptureFocusMode focusMode;
@property(nonatomic, copy) void (^setFocusModeStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) CGPoint focusPointOfInterest;
@property(nonatomic, copy) void (^setFocusPointOfInterestStub)(CGPoint point);

// Exposure
@property(nonatomic, assign) BOOL isExposurePointOfInterestSupported;
@property(nonatomic, assign) AVCaptureExposureMode exposureMode;
@property(nonatomic, assign) BOOL exposureModeSupported;
@property(nonatomic, copy) void (^setExposureModeStub)(AVCaptureExposureMode mode);
@property(nonatomic, assign) CGPoint exposurePointOfInterest;
@property(nonatomic, copy) void (^setExposurePointOfInterestStub)(CGPoint point);
@property(nonatomic, assign) float minExposureTargetBias;
@property(nonatomic, assign) float maxExposureTargetBias;
@property(nonatomic, copy) void (^setExposureTargetBiasStub)
    (float bias, void (^_Nullable handler)(CMTime));

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
@property(nonatomic, strong) id<FLTCaptureInput> inputToReturn;
@property(nonatomic, copy) void (^createInputStub)(NSError **error);

@end

@interface MockCaptureDeviceFormat : NSObject <FLTCaptureDeviceFormat>
@property(nonatomic, strong) NSArray<id<FLTFrameRateRange>> *videoSupportedFrameRateRanges;
@property(nonatomic, assign) CMFormatDescriptionRef formatDescription;
@property(nonatomic, strong) AVCaptureDeviceFormat *format;

- (instancetype)initWithDimensions:(CMVideoDimensions)dimensions;
@end

@interface MockFrameRateRange : NSObject <FLTFrameRateRange>
- (instancetype)initWithMinFrameRate:(float)minFrameRate maxFrameRate:(float)maxFrameRate;
@property(nonatomic, readwrite) float minFrameRate;
@property(nonatomic, readwrite) float maxFrameRate;
@end

@interface MockCaptureInput : NSObject <FLTCaptureInput>
@property(nonatomic, strong) NSArray<AVCaptureInputPort *> *ports;
@end

NS_ASSUME_NONNULL_END
