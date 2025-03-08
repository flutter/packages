// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif

NS_ASSUME_NONNULL_BEGIN

/// This method provides a convenient way to create media settings with minimal configuration.
/// Audio is enabled by default, while other parameters use platform-specific defaults.
extern FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(
    FCPPlatformResolutionPreset resolutionPreset);

/// Creates a test `FLTCamConfiguration` with a default mock setup.
extern FLTCamConfiguration *FLTCreateTestCameraConfiguration(void);

extern FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue);

/// Creates an `FLTCam` with a test configuration.
extern FLTCam *FLTCreateCamWithConfiguration(FLTCamConfiguration *configuration);

/// Creates a test sample buffer.
/// @return a test sample buffer.
extern CMSampleBufferRef FLTCreateTestSampleBuffer(void);

/// Creates a test audio sample buffer.
/// @return a test audio sample buffer.
extern CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void);

/// Calls `dispatch_queue_set_specific` with a key that is used to identify the queue.
/// This method is needed for comaptibility of Swift tests with Objective-C code.
/// In Swift, the API for settinng key-value pairs on a queue is different, so Swift tests
/// need to call this method to set the key-value pair on the queue in a way that's
/// compatible withn the existing Objective-C code.
extern void FLTdispatchQueueSetSpecific(dispatch_queue_t queue, const void *key);

NS_ASSUME_NONNULL_END
