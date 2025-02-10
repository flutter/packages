// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

#import "FLTCaptureDevice.h"
#import "FLTCaptureSession.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @interface FLTCamMediaSettingsAVWrapper
 * @abstract An interface for performing media settings operations.
 *
 * @discussion
 * xctest-expectation-checking implementation (`TestMediaSettingsAVWrapper`) of this interface can
 * be injected into `camera-avfoundation` plugin allowing to run media-settings tests without any
 * additional mocking of AVFoundation classes.
 */
@interface FLTCamMediaSettingsAVWrapper : NSObject

/**
 * @method lockDevice:error:
 * @abstract Requests exclusive access to configure device hardware properties.
 * @param captureDevice The capture device.
 * @param outError The optional error.
 * @result A BOOL indicating whether the device was successfully locked for configuration.
 */
- (BOOL)lockDevice:(NSObject<FLTCaptureDevice> *)captureDevice
             error:(NSError *_Nullable *_Nullable)outError;

/**
 * @method unlockDevice:
 * @abstract Release exclusive control over device hardware properties.
 * @param captureDevice The capture device.
 */
- (void)unlockDevice:(NSObject<FLTCaptureDevice> *)captureDevice;

/**
 * @method beginConfigurationForSession:
 * @abstract When paired with commitConfiguration, allows a client to batch multiple configuration
 * operations on a running session into atomic updates.
 * @param videoCaptureSession The video capture session.
 */
- (void)beginConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession;

/**
 * @method commitConfigurationForSession:
 * @abstract When preceded by beginConfiguration, allows a client to batch multiple configuration
 * operations on a running session into atomic updates.
 * @param videoCaptureSession The video capture session.
 */
- (void)commitConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession;

/**
 * @method setMinFrameDuration:onDevice:
 * @abstract Set receiver's current active minimum frame duration (the reciprocal of its max frame
 * rate).
 * @param duration The frame duration.
 * @param captureDevice The capture device
 */
- (void)setMinFrameDuration:(CMTime)duration onDevice:(NSObject<FLTCaptureDevice> *)captureDevice;

/**
 * @method setMaxFrameDuration:onDevice:
 * @abstract Set receiver's current active maximum frame duration (the reciprocal of its min frame
 * rate).
 * @param duration The frame duration.
 * @param captureDevice The capture device
 */
- (void)setMaxFrameDuration:(CMTime)duration onDevice:(NSObject<FLTCaptureDevice> *)captureDevice;

/**
 * @method assetWriterAudioInputWithOutputSettings:
 * @abstract Creates a new input of the audio media type to receive sample buffers for writing to
 * the output file.
 * @param outputSettings The settings used for encoding the audio appended to the output.
 * @result An instance of `AVAssetWriterInput`.
 */
- (AVAssetWriterInput *)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings;

/**
 * @method assetWriterVideoInputWithOutputSettings:
 * @abstract Creates a new input of the video media type to receive sample buffers for writing to
 * the output file.
 * @param outputSettings The settings used for encoding the video appended to the output.
 * @result An instance of `AVAssetWriterInput`.
 */
- (AVAssetWriterInput *)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings;

/**
 * @method addInput:toAssetWriter:
 * @abstract Adds an input to the asset writer.
 * @param writerInput The `AVAssetWriterInput` object to be added.
 * @param writer The `AVAssetWriter` object.
 */
- (void)addInput:(AVAssetWriterInput *)writerInput toAssetWriter:(AVAssetWriter *)writer;

/**
 * @method recommendedVideoSettingsForAssetWriterWithFileType:forOutput:
 * @abstract Specifies the recommended video settings for `AVCaptureVideoDataOutput`.
 * @param fileType Specifies the UTI of the file type to be written (see AVMediaFormat.h for a list
 * of file format UTIs).
 * @param output The `AVCaptureVideoDataOutput` instance.
 * @result A fully populated dictionary of keys and values that are compatible with AVAssetWriter.
 */
- (nullable NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output;
@end

NS_ASSUME_NONNULL_END
