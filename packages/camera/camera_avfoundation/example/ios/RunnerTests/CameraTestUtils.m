// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraTestUtils.h"

#import <OCMock/OCMock.h>
@import AVFoundation;
@import camera_avfoundation;

static FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(
    FCPPlatformResolutionPreset resolutionPreset) {
  return [FCPPlatformMediaSettings makeWithResolutionPreset:resolutionPreset
                                            framesPerSecond:nil
                                               videoBitrate:nil
                                               audioBitrate:nil
                                                enableAudio:YES];
}

FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue) {
  return FLTCreateCamWithCaptureSessionQueueAndMediaSettings(captureSessionQueue, nil, nil, nil);
}

FLTCam *FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
    dispatch_queue_t captureSessionQueue, FCPPlatformMediaSettings *mediaSettings,
    FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper,
    CaptureDeviceFactory captureDeviceFactory) {
  if (!mediaSettings) {
    mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMedium);
  }

  if (!mediaSettingsAVWrapper) {
    mediaSettingsAVWrapper = [[FLTCamMediaSettingsAVWrapper alloc] init];
  }

  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock beginConfiguration])
      .andDo(^(NSInvocation *invocation){
      });
  OCMStub([videoSessionMock commitConfiguration])
      .andDo(^(NSInvocation *invocation){
      });

  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id audioSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id fltCam = [[FLTCam alloc] initWithMediaSettings:mediaSettings
                             mediaSettingsAVWrapper:mediaSettingsAVWrapper
                             orientation:UIDeviceOrientationPortrait
                             videoCaptureSession:videoSessionMock
                             audioCaptureSession:audioSessionMock
                             captureSessionQueue:captureSessionQueue
                               captureDeviceFactory:captureDeviceFactory ?: ^AVCaptureDevice *(void) {
                               return [AVCaptureDevice deviceWithUniqueID:@"camera"];
                             }
                             videoDimensionsForFormat:^CMVideoDimensions(AVCaptureDeviceFormat *format) {
                               return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                             }
                             error:nil];

  id captureVideoDataOutputMock = [OCMockObject niceMockForClass:[AVCaptureVideoDataOutput class]];

  OCMStub([captureVideoDataOutputMock new]).andReturn(captureVideoDataOutputMock);

  OCMStub([captureVideoDataOutputMock
              recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4])
      .andReturn(@{});

  OCMStub([captureVideoDataOutputMock sampleBufferCallbackQueue]).andReturn(captureSessionQueue);

  id videoMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([videoMock assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
                                                sourcePixelBufferAttributes:OCMOCK_ANY])
      .andReturn(videoMock);

  id writerInputMock = [OCMockObject niceMockForClass:[AVAssetWriterInput class]];

  OCMStub([writerInputMock assetWriterInputWithMediaType:AVMediaTypeAudio
                                          outputSettings:[OCMArg any]])
      .andReturn(writerInputMock);

  OCMStub([writerInputMock assetWriterInputWithMediaType:AVMediaTypeVideo
                                          outputSettings:[OCMArg any]])
      .andReturn(writerInputMock);

  return fltCam;
}

FLTCam *FLTCreateCamWithVideoCaptureSession(AVCaptureSession *captureSession,
                                            FCPPlatformResolutionPreset resolutionPreset) {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id audioSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  return [[FLTCam alloc] initWithCameraName:@"camera"
                              mediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
                     mediaSettingsAVWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
                                orientation:UIDeviceOrientationPortrait
                        videoCaptureSession:captureSession
                        audioCaptureSession:audioSessionMock
                        captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
                                      error:nil];
}

FLTCam *FLTCreateCamWithVideoDimensionsForFormat(
    AVCaptureSession *captureSession, FCPPlatformResolutionPreset resolutionPreset,
    AVCaptureDevice *captureDevice, VideoDimensionsForFormat videoDimensionsForFormat) {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id audioSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  return [[FLTCam alloc] initWithMediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
                        mediaSettingsAVWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
                                   orientation:UIDeviceOrientationPortrait
                           videoCaptureSession:captureSession
                           audioCaptureSession:audioSessionMock
                           captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
                          captureDeviceFactory:^AVCaptureDevice *(void) {
                            return captureDevice;
                          }
                      videoDimensionsForFormat:videoDimensionsForFormat
                                         error:nil];
}

CMSampleBufferRef FLTCreateTestSampleBuffer(void) {
  CVPixelBufferRef pixelBuffer;
  CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, NULL, &pixelBuffer);

  CMFormatDescriptionRef formatDescription;
  CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer,
                                               &formatDescription);

  CMSampleTimingInfo timingInfo = {CMTimeMake(1, 44100), kCMTimeZero, kCMTimeInvalid};

  CMSampleBufferRef sampleBuffer;
  CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDescription,
                                           &timingInfo, &sampleBuffer);

  CFRelease(pixelBuffer);
  CFRelease(formatDescription);
  return sampleBuffer;
}

CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void) {
  CMBlockBufferRef blockBuffer;
  CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, NULL, 100, kCFAllocatorDefault, NULL, 0,
                                     100, kCMBlockBufferAssureMemoryNowFlag, &blockBuffer);

  CMFormatDescriptionRef formatDescription;
  AudioStreamBasicDescription basicDescription = {44100, kAudioFormatLinearPCM, 0, 1, 1, 1, 1, 8};
  CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &basicDescription, 0, NULL, 0, NULL, NULL,
                                 &formatDescription);

  CMSampleBufferRef sampleBuffer;
  CMAudioSampleBufferCreateReadyWithPacketDescriptions(
      kCFAllocatorDefault, blockBuffer, formatDescription, 1, kCMTimeZero, NULL, &sampleBuffer);

  CFRelease(blockBuffer);
  CFRelease(formatDescription);
  return sampleBuffer;
}
