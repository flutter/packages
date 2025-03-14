// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCamMediaSettingsAVWrapper.h"
#import "./include/camera_avfoundation/FLTAssetWriter.h"
#import "./include/camera_avfoundation/FLTCaptureDevice.h"
#import "./include/camera_avfoundation/FLTCaptureSession.h"

@implementation FLTCamMediaSettingsAVWrapper

- (BOOL)lockDevice:(NSObject<FLTCaptureDevice> *)captureDevice
             error:(NSError *_Nullable *_Nullable)outError {
  return [captureDevice lockForConfiguration:outError];
}

- (void)unlockDevice:(NSObject<FLTCaptureDevice> *)captureDevice {
  return [captureDevice unlockForConfiguration];
}

- (void)beginConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession {
  [videoCaptureSession beginConfiguration];
}

- (void)commitConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession {
  [videoCaptureSession commitConfiguration];
}

- (void)setMinFrameDuration:(CMTime)duration onDevice:(NSObject<FLTCaptureDevice> *)captureDevice {
  captureDevice.activeVideoMinFrameDuration = duration;
}

- (void)setMaxFrameDuration:(CMTime)duration onDevice:(NSObject<FLTCaptureDevice> *)captureDevice {
  captureDevice.activeVideoMaxFrameDuration = duration;
}

- (NSObject<FLTAssetWriterInput> *)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [[FLTDefaultAssetWriterInput alloc]
      initWithInput:[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                       outputSettings:outputSettings]];
}

- (NSObject<FLTAssetWriterInput> *)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [[FLTDefaultAssetWriterInput alloc]
      initWithInput:[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                       outputSettings:outputSettings]];
}

- (void)addInput:(NSObject<FLTAssetWriterInput> *)writerInput
    toAssetWriter:(NSObject<FLTAssetWriter> *)writer {
  [writer addInput:writerInput.input];
}

- (nullable NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output {
  return [output recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
}

@end
