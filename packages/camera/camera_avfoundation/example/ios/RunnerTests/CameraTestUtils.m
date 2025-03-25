// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraTestUtils.h"

@import AVFoundation;
@import camera_avfoundation;

#import "MockAssetWriter.h"
#import "MockCaptureDevice.h"
#import "MockCaptureDeviceFormat.h"
#import "MockCaptureSession.h"
#import "MockDeviceOrientationProvider.h"

FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(FCPPlatformResolutionPreset resolutionPreset) {
  return [FCPPlatformMediaSettings makeWithResolutionPreset:resolutionPreset
                                            framesPerSecond:nil
                                               videoBitrate:nil
                                               audioBitrate:nil
                                                enableAudio:YES];
}

FLTCamConfiguration *FLTCreateTestCameraConfiguration(void) {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  videoSessionMock.canSetSessionPreset = YES;

  MockCaptureSession *audioSessionMock = [[MockCaptureSession alloc] init];
  audioSessionMock.canSetSessionPreset = YES;

  MockFrameRateRange *frameRateRangeMock1 = [[MockFrameRateRange alloc] initWithMinFrameRate:3
                                                                                maxFrameRate:30];
  MockCaptureDeviceFormat *captureDeviceFormatMock1 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock1.videoSupportedFrameRateRanges = @[ frameRateRangeMock1 ];

  MockFrameRateRange *frameRateRangeMock2 = [[MockFrameRateRange alloc] initWithMinFrameRate:3
                                                                                maxFrameRate:60];
  MockCaptureDeviceFormat *captureDeviceFormatMock2 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock2.videoSupportedFrameRateRanges = @[ frameRateRangeMock2 ];

  MockCaptureDevice *captureDeviceMock = [[MockCaptureDevice alloc] init];
  captureDeviceMock.lockForConfigurationStub = ^BOOL(NSError **error) {
    return YES;
  };
  captureDeviceMock.formats = @[ captureDeviceFormatMock1, captureDeviceFormatMock2 ];

  __block NSObject<FLTCaptureDeviceFormat> *currentFormat = captureDeviceFormatMock1;
  captureDeviceMock.activeFormatStub = ^NSObject<FLTCaptureDeviceFormat> * {
    return currentFormat;
  };
  captureDeviceMock.setActiveFormatStub = ^(NSObject<FLTCaptureDeviceFormat> *format) {
    currentFormat = format;
  };

  FLTCamConfiguration *configuration = [[FLTCamConfiguration alloc]
      initWithMediaSettings:FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMedium)
      mediaSettingsWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
      captureDeviceFactory:^NSObject<FLTCaptureDevice> *(void) {
        return captureDeviceMock;
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull {
        return videoSessionMock;
      }
      captureSessionQueue:captureSessionQueue
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];
  configuration.videoCaptureSession = videoSessionMock;
  configuration.audioCaptureSession = audioSessionMock;
  configuration.orientation = UIDeviceOrientationPortrait;
  configuration.assetWriterFactory =
      ^NSObject<FLTAssetWriter> *(NSURL *url, AVFileType fileType, NSError **error) {
    return [[MockAssetWriter alloc] init];
  };
  configuration.inputPixelBufferAdaptorFactory = ^NSObject<FLTAssetWriterInputPixelBufferAdaptor> *(
      NSObject<FLTAssetWriterInput> *input, NSDictionary<NSString *, id> *settings) {
    return [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  };

  return configuration;
}

FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue) {
  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureSessionQueue = captureSessionQueue;
  return FLTCreateCamWithConfiguration(configuration);
}

FLTCam *FLTCreateCamWithConfiguration(FLTCamConfiguration *configuration) {
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

void FLTdispatchQueueSetSpecific(dispatch_queue_t queue, const void *key) {
  dispatch_queue_set_specific(queue, key, (void *)key, NULL);
}
