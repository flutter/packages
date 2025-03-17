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
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// A class that manages camera's state and performs camera operations.
@interface FLTCam : NSObject <FlutterTexture>

@property(readonly, nonatomic) NSObject<FLTCaptureDevice> *captureDevice;
@property(readonly, nonatomic) CGSize previewSize;
@property(assign, nonatomic) BOOL isPreviewPaused;
@property(nonatomic, copy) void (^onFrameAvailable)(void);
/// The API instance used to communicate with the Dart side of the plugin. Once initially set, this
/// should only ever be accessed on the main thread.
@property(nonatomic) FCPCameraEventApi *dartAPI;
@property(assign, nonatomic) FCPPlatformExposureMode exposureMode;
@property(assign, nonatomic) FCPPlatformFocusMode focusMode;
@property(assign, nonatomic) FCPPlatformFlashMode flashMode;
// Format used for video and image streaming.
@property(assign, nonatomic) FourCharCode videoFormat;
@property(assign, nonatomic) FCPPlatformImageFileFormat fileFormat;
@property(assign, nonatomic) CGFloat minimumAvailableZoomFactor;
@property(assign, nonatomic) CGFloat maximumAvailableZoomFactor;
@property(assign, nonatomic) CGFloat minimumExposureOffset;
@property(assign, nonatomic) CGFloat maximumExposureOffset;

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
- (void)lockCaptureOrientation:(FCPPlatformDeviceOrientation)orientation;
- (void)unlockCaptureOrientation;
- (void)setFlashMode:(FCPPlatformFlashMode)mode
      withCompletion:(void (^)(FlutterError *_Nullable))completion;
- (void)setExposureMode:(FCPPlatformExposureMode)mode;
- (void)setFocusMode:(FCPPlatformFocusMode)mode;
- (void)applyFocusMode;

/// Acknowledges the receipt of one image stream frame.
///
/// This should be called each time a frame is received. Failing to call it may
/// cause later frames to be dropped instead of streamed.
- (void)receivedImageStreamData;

/// Applies FocusMode on the AVCaptureDevice.
///
/// If the @c focusMode is set to FocusModeAuto the AVCaptureDevice is configured to use
/// AVCaptureFocusModeContinuousModeAutoFocus when supported, otherwise it is set to
/// AVCaptureFocusModeAutoFocus. If neither AVCaptureFocusModeContinuousModeAutoFocus nor
/// AVCaptureFocusModeAutoFocus are supported focus mode will not be set.
/// If @c focusMode is set to FocusModeLocked the AVCaptureDevice is configured to use
/// AVCaptureFocusModeAutoFocus. If AVCaptureFocusModeAutoFocus is not supported focus mode will not
/// be set.
///
/// @param focusMode The focus mode that should be applied to the @captureDevice instance.
/// @param captureDevice The AVCaptureDevice to which the @focusMode will be applied.
- (void)applyFocusMode:(FCPPlatformFocusMode)focusMode
              onDevice:(NSObject<FLTCaptureDevice> *)captureDevice;
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
- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;
- (void)stopImageStream;
- (void)setZoomLevel:(CGFloat)zoom withCompletion:(void (^)(FlutterError *_Nullable))completion;
- (void)setUpCaptureSessionForAudioIfNeeded;

@end

NS_ASSUME_NONNULL_END
