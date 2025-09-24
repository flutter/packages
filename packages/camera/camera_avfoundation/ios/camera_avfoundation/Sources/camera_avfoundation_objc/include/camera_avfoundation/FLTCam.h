// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import Flutter;
@import CoreMotion;

#import "CameraProperties.h"
#import "FLTCamConfiguration.h"
#import "FLTCamMediaSettingsAVWrapper.h"
#import "FLTCaptureDevice.h"
#import "FLTDeviceOrientationProviding.h"
#import "FLTImageStreamHandler.h"
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// A class that manages camera's state and performs camera operations.
@interface FLTCam : NSObject

// captureDevice is assignable for the Swift DefaultCamera subclass
@property(strong, nonatomic) NSObject<FLTCaptureDevice> *captureDevice;
@property(readonly, nonatomic) CGSize previewSize;
@property(assign, nonatomic) FCPPlatformImageFileFormat fileFormat;

// Properties exposed for the Swift DefaultCamera subclass
@property(assign, nonatomic) BOOL isRecording;
// videoCaptureSession is assignable for the Swift DefaultCamera subclass
@property(strong, nonatomic) NSObject<FLTCaptureSession> *videoCaptureSession;
// audioCaptureSession is assignable for the Swift DefaultCamera subclass
@property(strong, nonatomic) NSObject<FLTCaptureSession> *audioCaptureSession;
@property(assign, nonatomic) UIDeviceOrientation lockedCaptureOrientation;
@property(assign, nonatomic) UIDeviceOrientation deviceOrientation;
@property(nonatomic) CMMotionManager *motionManager;
@property(strong, nonatomic) NSObject<FLTCaptureInput> *captureVideoInput;
/// A wrapper for CMVideoFormatDescriptionGetDimensions.
/// Allows for alternate implementations in tests.
@property(nonatomic, copy) VideoDimensionsForFormat videoDimensionsForFormat;

// Methods exposed for the Swift DefaultCamera subclass
- (void)updateOrientation;

- (BOOL)setCaptureSessionPreset:(FCPPlatformResolutionPreset)resolutionPreset
                      withError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
