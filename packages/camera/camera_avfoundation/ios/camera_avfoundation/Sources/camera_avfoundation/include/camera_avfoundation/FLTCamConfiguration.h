// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import Flutter;

#import "CameraProperties.h"
#import "FLTCamMediaSettingsAVWrapper.h"
#import "FLTCaptureDevice.h"
#import "FLTCaptureSession.h"
#import "FLTDeviceOrientationProviding.h"

NS_ASSUME_NONNULL_BEGIN

/// Factory block returning an AVCaptureDevice.
/// Used in tests to inject a device into FLTCam.
typedef NSObject<FLTCaptureDevice> *_Nonnull (^CaptureDeviceFactory)(void);

typedef NSObject<FLTCaptureSession> *_Nonnull (^CaptureSessionFactory)(void);

/// Determines the video dimensions (width and height) for a given capture device format.
/// Used in tests to mock CMVideoFormatDescriptionGetDimensions.
typedef CMVideoDimensions (^VideoDimensionsForFormat)(NSObject<FLTCaptureDeviceFormat> *);

/// A configuration object that centralizes dependencies  for `FLTCam`.
@interface FLTCamConfiguration : NSObject

/// Initializes a new camera configuration with specified media settings and factories.
- (instancetype)initWithMediaSettings:(FCPPlatformMediaSettings *)mediaSettings
                 mediaSettingsWrapper:(FLTCamMediaSettingsAVWrapper *)mediaSettingsWrapper
                 captureDeviceFactory:(CaptureDeviceFactory)captureDeviceFactory
                captureSessionFactory:(CaptureSessionFactory)captureSessionFactory
                  captureSessionQueue:(dispatch_queue_t)captureSessionQueue
            captureDeviceInputFactory:
                (NSObject<FLTCaptureDeviceInputFactory> *)captureDeviceInputFactory;

@property(nonatomic, strong) id<FLTDeviceOrientationProviding> deviceOrientationProvider;
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;
@property(nonatomic, strong) FCPPlatformMediaSettings *mediaSettings;
@property(nonatomic, strong) FLTCamMediaSettingsAVWrapper *mediaSettingsWrapper;
@property(nonatomic, copy) CaptureDeviceFactory captureDeviceFactory;
@property(nonatomic, copy) CaptureDeviceFactory audioCaptureDeviceFactory;
@property(nonatomic, copy) VideoDimensionsForFormat videoDimensionsForFormat;
@property(nonatomic, assign) UIDeviceOrientation orientation;
@property(nonatomic, strong) NSObject<FLTCaptureSession> *videoCaptureSession;
@property(nonatomic, strong) NSObject<FLTCaptureSession> *audioCaptureSession;
@property(nonatomic, strong) NSObject<FLTCaptureDeviceInputFactory> *captureDeviceInputFactory;

@end

NS_ASSUME_NONNULL_END
