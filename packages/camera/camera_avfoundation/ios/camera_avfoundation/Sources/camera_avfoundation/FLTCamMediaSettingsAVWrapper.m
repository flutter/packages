// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCamMediaSettingsAVWrapper.h"
#import "./include/camera_avfoundation/Protocols/FLTAssetWriter.h"
#import "./include/camera_avfoundation/Protocols/FLTCaptureDeviceControlling.h"
#import "./include/camera_avfoundation/Protocols/FLTCaptureSessionProtocol.h"

@implementation FLTCamMediaSettingsAVWrapper

- (BOOL)lockDevice:(id<FLTCaptureDeviceControlling>)captureDevice
             error:(NSError *_Nullable *_Nullable)outError {
  return [captureDevice lockForConfiguration:outError];
}

- (void)unlockDevice:(id<FLTCaptureDeviceControlling>)captureDevice {
  return [captureDevice unlockForConfiguration];
}

- (void)beginConfigurationForSession:(id<FLTCaptureSessionProtocol>)videoCaptureSession {
  [videoCaptureSession beginConfiguration];
}

- (void)commitConfigurationForSession:(id<FLTCaptureSessionProtocol>)videoCaptureSession {
  [videoCaptureSession commitConfiguration];
}

- (void)setMinFrameDuration:(CMTime)duration
                   onDevice:(id<FLTCaptureDeviceControlling>)captureDevice {
  captureDevice.activeVideoMinFrameDuration = duration;
}

- (void)setMaxFrameDuration:(CMTime)duration
                   onDevice:(id<FLTCaptureDeviceControlling>)captureDevice {
  captureDevice.activeVideoMaxFrameDuration = duration;
}

- (id<FLTAssetWriterInput>)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [[FLTDefaultAssetWriterInput alloc]
      initWithInput:[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                       outputSettings:outputSettings]];
}

- (id<FLTAssetWriterInput>)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return [[FLTDefaultAssetWriterInput alloc]
      initWithInput:[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                       outputSettings:outputSettings]];
}

- (void)addInput:(id<FLTAssetWriterInput>)writerInput toAssetWriter:(id<FLTAssetWriter>)writer {
  [writer addInput:writerInput.input];
}

- (nullable NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output {
  return [output recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
}

@end
