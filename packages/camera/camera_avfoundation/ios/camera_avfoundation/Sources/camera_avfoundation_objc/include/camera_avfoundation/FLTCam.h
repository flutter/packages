// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import Flutter;

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

@property(readonly, nonatomic) NSObject<FLTCaptureDevice> *captureDevice;
@property(readonly, nonatomic) CGSize previewSize;
@property(assign, nonatomic) BOOL isPreviewPaused;
@property(nonatomic, copy, nullable) void (^onFrameAvailable)(void);
/// The API instance used to communicate with the Dart side of the plugin. Once initially set, this
/// should only ever be accessed on the main thread.
@property(nonatomic, nullable) FCPCameraEventApi *dartAPI;
// Format used for video and image streaming.
@property(assign, nonatomic) FourCharCode videoFormat;
@property(assign, nonatomic) FCPPlatformImageFileFormat fileFormat;
@property(readonly, nonatomic) CGFloat minimumAvailableZoomFactor;
@property(readonly, nonatomic) CGFloat maximumAvailableZoomFactor;
@property(readonly, nonatomic) CGFloat minimumExposureOffset;
@property(readonly, nonatomic) CGFloat maximumExposureOffset;

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

/// Initializes an `FLTCam` instance with the given configuration.
/// @param error report to the caller if any error happened creating the camera.
- (instancetype)initWithConfiguration:(FLTCamConfiguration *)configuration error:(NSError **)error;

/// Informs the Dart side of the plugin of the current camera state and capabilities.
- (void)reportInitializationState;
- (void)start;
- (void)stop;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;
- (void)captureToFileWithCompletion:(void (^)(NSString *_Nullable,
                                              FlutterError *_Nullable))completion;
- (void)close;
- (void)setImageFileFormat:(FCPPlatformImageFileFormat)fileFormat;
/// Starts recording a video with an optional streaming messenger.
/// If the messenger is non-nil then it will be called for each
/// captured frame, allowing streaming concurrently with recording.
///
/// @param messenger Nullable messenger for capturing each frame.
- (void)startVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion
                    messengerForStreaming:(nullable NSObject<FlutterBinaryMessenger> *)messenger;
- (void)stopVideoRecordingWithCompletion:(void (^)(NSString *_Nullable,
                                                   FlutterError *_Nullable))completion;
- (void)pauseVideoRecording;
- (void)resumeVideoRecording;
- (void)lockCaptureOrientation:(FCPPlatformDeviceOrientation)orientation
    NS_SWIFT_NAME(lockCaptureOrientation(_:));
- (void)unlockCaptureOrientation;
- (void)setFlashMode:(FCPPlatformFlashMode)mode
      withCompletion:(void (^)(FlutterError *_Nullable))completion;
- (void)setExposureMode:(FCPPlatformExposureMode)mode;
/// Sets FocusMode on the current AVCaptureDevice.
///
/// If the @c focusMode is set to FocusModeAuto the AVCaptureDevice is configured to use
/// AVCaptureFocusModeContinuousModeAutoFocus when supported, otherwise it is set to
/// AVCaptureFocusModeAutoFocus. If neither AVCaptureFocusModeContinuousModeAutoFocus nor
/// AVCaptureFocusModeAutoFocus are supported focus mode will not be set.
/// If @c focusMode is set to FocusModeLocked the AVCaptureDevice is configured to use
/// AVCaptureFocusModeAutoFocus. If AVCaptureFocusModeAutoFocus is not supported focus mode will not
/// be set.
///
/// @param mode The focus mode that should be applied.
- (void)setFocusMode:(FCPPlatformFocusMode)mode;

/// Acknowledges the receipt of one image stream frame.
///
/// This should be called each time a frame is received. Failing to call it may
/// cause later frames to be dropped instead of streamed.
- (void)receivedImageStreamData;

- (void)pausePreview;
- (void)resumePreview;
- (void)setDescriptionWhileRecording:(NSString *)cameraName
                      withCompletion:(void (^)(FlutterError *_Nullable))completion;

/// Sets the exposure point, in a (0,1) coordinate system.
///
/// If @c point is nil, the exposure point will reset to the center.
- (void)setExposurePoint:(nullable FCPPlatformPoint *)point
          withCompletion:(void (^)(FlutterError *_Nullable))completion;

/// Sets the focus point, in a (0,1) coordinate system.
///
/// If @c point is nil, the focus point will reset to the center.
- (void)setFocusPoint:(nullable FCPPlatformPoint *)point
       withCompletion:(void (^)(FlutterError *_Nullable))completion
    NS_SWIFT_NAME(setFocusPoint(_:completion:));
- (void)setExposureOffset:(double)offset;
- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                           completion:(nonnull void (^)(FlutterError *_Nullable))completion;
- (void)stopImageStream;
- (void)setZoomLevel:(CGFloat)zoom withCompletion:(void (^)(FlutterError *_Nullable))completion;
- (void)setUpCaptureSessionForAudioIfNeeded;

@end

NS_ASSUME_NONNULL_END
