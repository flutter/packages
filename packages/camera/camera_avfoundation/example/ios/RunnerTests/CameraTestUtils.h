// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif

NS_ASSUME_NONNULL_BEGIN

extern FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(
    FCPPlatformResolutionPreset resolutionPreset);

/// Creates a test `FLTCamConfiguration` that has a default mock setup.
extern FLTCamConfiguration *FLTCreateTestConfiguration(void);

/// Creates an `FLTCam` with a test configuration.
extern FLTCam *FLTCreateCamWithConfiguration(FLTCamConfiguration *configuration);

/// Creates a test sample buffer.
/// @return a test sample buffer.
extern CMSampleBufferRef FLTCreateTestSampleBuffer(void);

/// Creates a test audio sample buffer.
/// @return a test audio sample buffer.
extern CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void);

NS_ASSUME_NONNULL_END
