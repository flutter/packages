// Copyright 2013 The Flutter Authors. All rights reserved.
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
@property(assign, nonatomic) BOOL isPreviewPaused;
@property(nonatomic, copy, nullable) void (^onFrameAvailable)(void);
/// The API instance used to communicate with the Dart side of the plugin. Once initially set, this
/// should only ever be accessed on the main thread.
@property(nonatomic, nullable) FCPCameraEventApi *dartAPI;
// Format used for video and image streaming.
@property(assign, nonatomic) FourCharCode videoFormat;
@property(assign, nonatomic) FCPPlatformImageFileFormat fileFormat;

// Properties exposed for the Swift DefaultCamera subclass
@property(nonatomic, nullable) FLTImageStreamHandler *imageStreamHandler;
/// Number of frames currently pending processing.
@property(assign, nonatomic) int streamingPendingFramesCount;
@property(assign, nonatomic) BOOL isFirstVideoSample;
@property(assign, nonatomic) BOOL isRecording;
@property(assign, nonatomic) BOOL isRecordingPaused;
@property(strong, nonatomic, nullable) NSObject<FLTAssetWriter> *videoWriter;
@property(assign, nonatomic) BOOL videoIsDisconnected;
@property(assign, nonatomic) BOOL audioIsDisconnected;
@property(assign, nonatomic) CMTime videoTimeOffset;
@property(assign, nonatomic) CMTime audioTimeOffset;
@property(strong, nonatomic, nullable) NSObject<FLTAssetWriterInput> *videoWriterInput;
@property(strong, nonatomic, nullable) NSObject<FLTAssetWriterInput> *audioWriterInput;
@property(nullable) NSObject<FLTAssetWriterInputPixelBufferAdaptor> *videoAdaptor;
@property(readonly, nonatomic) NSObject<FLTCaptureSession> *videoCaptureSession;
@property(readonly, nonatomic) NSObject<FLTCaptureSession> *audioCaptureSession;
@property(readonly, nonatomic) NSObject<FLTDeviceOrientationProviding> *deviceOrientationProvider;
@property(assign, nonatomic) UIDeviceOrientation lockedCaptureOrientation;
@property(assign, nonatomic) UIDeviceOrientation deviceOrientation;
@property(assign, nonatomic) FCPPlatformFlashMode flashMode;
@property(nonatomic) CMMotionManager *motionManager;
@property(strong, nonatomic, nullable) NSString *videoRecordingPath;
@property(nonatomic, copy) CaptureDeviceFactory captureDeviceFactory;
@property(strong, nonatomic) NSObject<FLTCaptureInput> *captureVideoInput;
@property(readonly, nonatomic) NSObject<FLTCaptureDeviceInputFactory> *captureDeviceInputFactory;
/// All FLTCam's state access and capture session related operations should be on run on this queue.
@property(strong, nonatomic) dispatch_queue_t captureSessionQueue;
@property(nonatomic, copy) AssetWriterFactory assetWriterFactory;
@property(readonly, nonatomic) FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper;
@property(readonly, nonatomic) FCPPlatformMediaSettings *mediaSettings;
@property(nonatomic, copy) InputPixelBufferAdaptorFactory inputPixelBufferAdaptorFactory;
@property(assign, nonatomic) BOOL isAudioSetup;
/// A wrapper for AVCaptureDevice creation to allow for dependency injection in tests.
@property(nonatomic, copy) AudioCaptureDeviceFactory audioCaptureDeviceFactory;

/// Initializes an `FLTCam` instance with the given configuration.
/// @param error report to the caller if any error happened creating the camera.
- (instancetype)initWithConfiguration:(FLTCamConfiguration *)configuration error:(NSError **)error;

// Methods exposed for the Swift DefaultCamera subclass
- (void)updateOrientation;

@end

NS_ASSUME_NONNULL_END
