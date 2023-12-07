// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;

NS_ASSUME_NONNULL_BEGIN

/// Creates an `FLTCam` that runs its capture session operations on a given queue.
/// @param captureSessionQueue the capture session queue
/// @param mediaSettings media settings configuration parameters
/// @param mediaSettingsAVWrapper provider to perform media settings operations (for unit test
/// dependency injection).
/// @return an FLTCam object.
extern FLTCam *_Nullable FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
    dispatch_queue_t _Nullable captureSessionQueue, FLTCamMediaSettings *_Nullable mediaSettings,
    FLTCamMediaSettingsAVWrapper *_Nullable mediaSettingsAVWrapper);

extern FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue);

/// Creates a test sample buffer.
/// @return a test sample buffer.
extern CMSampleBufferRef FLTCreateTestSampleBuffer(void);

/// Creates a test audio sample buffer.
/// @return a test audio sample buffer.
extern CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void);

NS_ASSUME_NONNULL_END
