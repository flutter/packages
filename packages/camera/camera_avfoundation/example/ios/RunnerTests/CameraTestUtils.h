// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif

NS_ASSUME_NONNULL_BEGIN

/// Creates an `FLTCam` that runs its capture session operations on a given queue.
/// @param captureSessionQueue the capture session queue
/// @param mediaSettings media settings configuration parameters
/// @param mediaSettingsAVWrapper provider to perform media settings operations (for unit test
/// dependency injection).
/// @param captureDeviceFactory a callback to create capture device instances
/// @return an FLTCam object.
extern FLTCam *_Nullable FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
    dispatch_queue_t _Nullable captureSessionQueue,
    FCPPlatformMediaSettings *_Nullable mediaSettings,
    FLTCamMediaSettingsAVWrapper *_Nullable mediaSettingsAVWrapper,
    CaptureDeviceFactory _Nullable captureDeviceFactory,
    id<FLTDeviceOrientationProviding> _Nullable deviceOrientationProvider);

extern FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue);

/// Creates an `FLTCam` with a given captureSession and resolutionPreset
/// @param captureSession AVCaptureSession for video
/// @param resolutionPreset preset for camera's captureSession resolution
/// @return an FLTCam object.
extern FLTCam *FLTCreateCamWithVideoCaptureSession(AVCaptureSession *captureSession,
                                                   FCPPlatformResolutionPreset resolutionPreset);

/// Creates an `FLTCam` with a given captureSession and resolutionPreset.
/// Allows to inject a capture device and a block to compute the video dimensions.
/// @param captureSession AVCaptureSession for video
/// @param resolutionPreset preset for camera's captureSession resolution
/// @param captureDevice AVCaptureDevice to be used
/// @param videoDimensionsForFormat custom code to determine video dimensions
/// @return an FLTCam object.
extern FLTCam *FLTCreateCamWithVideoDimensionsForFormat(
    AVCaptureSession *captureSession, FCPPlatformResolutionPreset resolutionPreset,
    AVCaptureDevice *captureDevice, VideoDimensionsForFormat videoDimensionsForFormat);

/// Creates a test sample buffer.
/// @return a test sample buffer.
extern CMSampleBufferRef FLTCreateTestSampleBuffer(void);

/// Creates a test audio sample buffer.
/// @return a test audio sample buffer.
extern CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void);

NS_ASSUME_NONNULL_END
