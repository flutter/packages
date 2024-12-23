// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import Flutter;

#import "CameraProperties.h"
#import "FLTAssetWriter.h"
#import "FLTCamMediaSettingsAVWrapper.h"
#import "FLTCaptureDeviceControlling.h"
#import "FLTCapturePhotoOutput.h"
#import "FLTDeviceOrientationProviding.h"

NS_ASSUME_NONNULL_BEGIN

/// Factory block returning an AVCaptureDevice.
/// Used in tests to inject a device into FLTCam.
typedef id<FLTCaptureDeviceControlling> _Nonnull (^CaptureDeviceFactory)(void);

typedef id<FLTCaptureDeviceControlling> _Nonnull (^AudioCaptureDeviceFactory)(void);

typedef id<FLTAssetWriter> _Nonnull (^AssetWriterFactory)(NSURL *, AVFileType,
                                                          NSError *_Nullable *_Nullable);

typedef id<FLTPixelBufferAdaptor> _Nonnull (^PixelBufferAdaptorFactory)(
    id<FLTAssetWriterInput>, NSDictionary<NSString *, id> *_Nullable);

typedef id<FLTCaptureSession> _Nonnull (^CaptureSessionFactory)(void);

/// Determines the video dimensions (width and height) for a given capture device format.
/// Used in tests to mock CMVideoFormatDescriptionGetDimensions.
typedef CMVideoDimensions (^VideoDimensionsForFormat)(id<FLTCaptureDeviceFormat>);

@interface FLTCamConfiguration : NSObject

- (instancetype)initWithMediaSettings:(FCPPlatformMediaSettings *)mediaSettings
                 mediaSettingsWrapper:(FLTCamMediaSettingsAVWrapper *)mediaSettingsWrapper
                 captureDeviceFactory:(CaptureDeviceFactory)captureDeviceFactory
                  captureSessionQueue:(dispatch_queue_t)captureSessionQueue
                captureSessionFactory:(CaptureSessionFactory)captureSessionFactory
            audioCaptureDeviceFactory:(AudioCaptureDeviceFactory)audioCaptureDeviceFactory;

@property(nonatomic, strong) id<FLTDeviceOrientationProviding> deviceOrientationProvider;
@property(nonatomic, strong) id<FLTCaptureSession> videoCaptureSession;
@property(nonatomic, strong) id<FLTCaptureSession> audioCaptureSession;
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;
@property(nonatomic, strong) FCPPlatformMediaSettings *mediaSettings;
@property(nonatomic, strong) FLTCamMediaSettingsAVWrapper *mediaSettingsWrapper;
@property(nonatomic, strong) id<FLTCapturePhotoOutput> capturePhotoOutput;
@property(nonatomic, copy) AssetWriterFactory assetWriterFactory;
@property(nonatomic, copy) PixelBufferAdaptorFactory pixelBufferAdaptorFactory;
@property(nonatomic, strong) id<FLTCapturePhotoSettingsFactory> photoSettingsFactory;
@property(nonatomic, copy) CaptureDeviceFactory captureDeviceFactory;
@property(nonatomic, copy) CaptureDeviceFactory audioCaptureDeviceFactory;
@property(nonatomic, copy) VideoDimensionsForFormat videoDimensionsForFormat;
@property(nonatomic, assign) UIDeviceOrientation orientation;

@end

NS_ASSUME_NONNULL_END
