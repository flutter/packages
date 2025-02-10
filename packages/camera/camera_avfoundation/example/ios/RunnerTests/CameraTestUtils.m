// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraTestUtils.h"

#import <OCMock/OCMock.h>
@import AVFoundation;
@import camera_avfoundation;

#import "MockCaptureDevice.h"
#import "MockCaptureSession.h"
#import "MockDeviceOrientationProvider.h"

static FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(
    FCPPlatformResolutionPreset resolutionPreset) {
  return [FCPPlatformMediaSettings makeWithResolutionPreset:resolutionPreset
                                            framesPerSecond:nil
                                               videoBitrate:nil
                                               audioBitrate:nil
                                                enableAudio:YES];
}

FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue) {
  return FLTCreateCamWithCaptureSessionQueueAndMediaSettings(captureSessionQueue, nil, nil, nil,
                                                             nil);
}

FLTCam *FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
    dispatch_queue_t captureSessionQueue, FCPPlatformMediaSettings *mediaSettings,
    FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper, CaptureDeviceFactory captureDeviceFactory,
    NSObject<FLTDeviceOrientationProviding> *deviceOrientationProvider) {
  if (!mediaSettings) {
    mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMedium);
  }

  if (!mediaSettingsAVWrapper) {
    mediaSettingsAVWrapper = [[FLTCamMediaSettingsAVWrapper alloc] init];
  }

  if (!deviceOrientationProvider) {
    deviceOrientationProvider = [[MockDeviceOrientationProvider alloc] init];
  }

  if (!captureSessionQueue) {
    captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  }

  id videoSessionMock = OCMProtocolMock(@protocol(FLTCaptureSession));
  OCMStub([videoSessionMock beginConfiguration])
      .andDo(^(NSInvocation *invocation){
      });
  OCMStub([videoSessionMock commitConfiguration])
      .andDo(^(NSInvocation *invocation){
      });

  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id audioSessionMock = OCMProtocolMock(@protocol(FLTCaptureSession));
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id frameRateRangeMock1 = OCMClassMock([AVFrameRateRange class]);
  OCMStub([frameRateRangeMock1 minFrameRate]).andReturn(3);
  OCMStub([frameRateRangeMock1 maxFrameRate]).andReturn(30);
  id captureDeviceFormatMock1 = OCMClassMock([AVCaptureDeviceFormat class]);
  OCMStub([captureDeviceFormatMock1 videoSupportedFrameRateRanges]).andReturn(@[
    frameRateRangeMock1
  ]);

  id frameRateRangeMock2 = OCMClassMock([AVFrameRateRange class]);
  OCMStub([frameRateRangeMock2 minFrameRate]).andReturn(3);
  OCMStub([frameRateRangeMock2 maxFrameRate]).andReturn(60);
  id captureDeviceFormatMock2 = OCMClassMock([AVCaptureDeviceFormat class]);
  OCMStub([captureDeviceFormatMock2 videoSupportedFrameRateRanges]).andReturn(@[
    frameRateRangeMock2
  ]);

  id captureDeviceMock = OCMProtocolMock(@protocol(FLTCaptureDevice));
  OCMStub([captureDeviceMock lockForConfiguration:[OCMArg setTo:nil]]).andReturn(YES);
  OCMStub([captureDeviceMock formats]).andReturn((@[
    captureDeviceFormatMock1, captureDeviceFormatMock2
  ]));
  __block AVCaptureDeviceFormat *format = captureDeviceFormatMock1;
  OCMStub([captureDeviceMock setActiveFormat:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    [invocation retainArguments];
    [invocation getArgument:&format atIndex:2];
  });
  OCMStub([captureDeviceMock activeFormat]).andDo(^(NSInvocation *invocation) {
    [invocation setReturnValue:&format];
  });

  FLTCamConfiguration *configuration = [[FLTCamConfiguration alloc] initWithMediaSettings:mediaSettings
                                                                     mediaSettingsWrapper:mediaSettingsAVWrapper
                                                                     captureDeviceFactory:captureDeviceFactory ?: ^NSObject<FLTCaptureDevice> *(void) {
                                                                        return captureDeviceMock;
                                                                      }
                                                                    captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull{
    return videoSessionMock;
                                                                      }
                                                                      captureSessionQueue:captureSessionQueue
                                                                captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];

  configuration.videoDimensionsForFormat = ^CMVideoDimensions(AVCaptureDeviceFormat *format) {
    return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
  };
  configuration.deviceOrientationProvider = deviceOrientationProvider;
  configuration.videoCaptureSession = videoSessionMock;
  configuration.audioCaptureSession = audioSessionMock;

  id fltCam = [[FLTCam alloc] initWithConfiguration:configuration error:nil];

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

FLTCam *FLTCreateCamWithVideoCaptureSession(NSObject<FLTCaptureSession> *captureSession,
                                            FCPPlatformResolutionPreset resolutionPreset) {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id audioSessionMock = OCMProtocolMock(@protocol(FLTCaptureSession));
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id captureDeviceMock = OCMProtocolMock(@protocol(FLTCaptureDevice));

  FLTCamConfiguration *configuration = [[FLTCamConfiguration alloc]
      initWithMediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
      mediaSettingsWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
      captureDeviceFactory:^NSObject<FLTCaptureDevice> *(void) {
        return captureDeviceMock;
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull {
        return captureSession;
      }
      captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];

  configuration.orientation = UIDeviceOrientationPortrait;
  configuration.videoCaptureSession = captureSession;
  configuration.audioCaptureSession = audioSessionMock;

  return [[FLTCam alloc] initWithConfiguration:configuration error:nil];
}

FLTCam *FLTCreateCamWithVideoDimensionsForFormat(
    AVCaptureSession *captureSession, FCPPlatformResolutionPreset resolutionPreset,
    AVCaptureDevice *captureDevice, VideoDimensionsForFormat videoDimensionsForFormat) {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id audioSessionMock = OCMProtocolMock(@protocol(FLTCaptureSession));
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  FLTCamConfiguration *configuration = [[FLTCamConfiguration alloc]
      initWithMediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
      mediaSettingsWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
      captureDeviceFactory:^NSObject<FLTCaptureDevice> *(void) {
        return [[FLTDefaultCaptureDevice alloc] initWithDevice:captureDevice];
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull {
        return [[FLTDefaultCaptureSession alloc]
            initWithCaptureSession:[[AVCaptureSession alloc] init]];
      }
      captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];

  configuration.videoDimensionsForFormat = videoDimensionsForFormat;
  configuration.deviceOrientationProvider = [[MockDeviceOrientationProvider alloc] init];
  configuration.videoCaptureSession =
      [[FLTDefaultCaptureSession alloc] initWithCaptureSession:captureSession];
  configuration.audioCaptureSession = audioSessionMock;
  configuration.orientation = UIDeviceOrientationPortrait;

  return [[FLTCam alloc] initWithConfiguration:configuration error:nil];
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
