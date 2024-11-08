// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCamMediaSettingsAVWrapper.h"

@implementation FLTCamMediaSettingsAVWrapper

- (BOOL)lockDevice:(AVCaptureDevice *)captureDevice error:(NSError *_Nullable *_Nullable)outError {
  return [captureDevice lockForConfiguration:outError];
}

- (void)unlockDevice:(AVCaptureDevice *)captureDevice {
  return [captureDevice unlockForConfiguration];
}

- (void)beginConfigurationForSession:(AVCaptureSession *)videoCaptureSession {
  [videoCaptureSession beginConfiguration];
}

- (void)commitConfigurationForSession:(AVCaptureSession *)videoCaptureSession {
  [videoCaptureSession commitConfiguration];
}

- (void)setMinFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
  captureDevice.activeVideoMinFrameDuration = duration;
}

- (void)setMaxFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
  captureDevice.activeVideoMaxFrameDuration = duration;
}

- (AVAssetWriterInput *)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:outputSettings];
}

- (AVAssetWriterInput *)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:outputSettings];
}

- (void)addInput:(AVAssetWriterInput *)writerInput toAssetWriter:(AVAssetWriter *)writer {
  [writer addInput:writerInput];
}

- (nullable NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output {
  return [output recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
}

@end
