// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraTestUtils.h"

@import AVFoundation;
@import camera_avfoundation;

#import "MockAssetWriter.h"
#import "MockCaptureDeviceController.h"
#import "MockCapturePhotoSettings.h"
#import "MockCaptureSession.h"

FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(FCPPlatformResolutionPreset resolutionPreset) {
  return [FCPPlatformMediaSettings makeWithResolutionPreset:resolutionPreset
                                            framesPerSecond:nil
                                               videoBitrate:nil
                                               audioBitrate:nil
                                                enableAudio:YES];
}

FLTCamConfiguration *FLTCreateTestConfiguration(void) {
  FCPPlatformMediaSettings *mediaSettings =
      FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMedium);
  FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper =
      [[FLTCamMediaSettingsAVWrapper alloc] init];
  MockAssetWriter *assetWriter = [[MockAssetWriter alloc] init];
  MockPixelBufferAdaptor *pixelBufferAdaptor = [[MockPixelBufferAdaptor alloc] init];

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  videoSessionMock.mockCanSetSessionPreset = YES;

  MockCaptureSession *audioSessionMock = [[MockCaptureSession alloc] init];
  audioSessionMock.mockCanSetSessionPreset = YES;

  __block MockCaptureDeviceController *mockDevice = [[MockCaptureDeviceController alloc] init];

  MockFrameRateRange *frameRateRange1 = [[MockFrameRateRange alloc] initWithMinFrameRate:3
                                                                            maxFrameRate:30];
  MockCaptureDeviceFormat *captureDeviceFormatMock1 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock1.videoSupportedFrameRateRanges = @[ frameRateRange1 ];

  MockFrameRateRange *frameRateRange2 = [[MockFrameRateRange alloc] initWithMinFrameRate:3
                                                                            maxFrameRate:60];
  MockCaptureDeviceFormat *captureDeviceFormatMock2 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock2.videoSupportedFrameRateRanges = @[ frameRateRange2 ];

  MockCaptureInput *inputMock = [[MockCaptureInput alloc] init];

  mockDevice.formats = @[ captureDeviceFormatMock1, captureDeviceFormatMock2 ];
  mockDevice.activeFormat = captureDeviceFormatMock1;
  mockDevice.inputToReturn = inputMock;

  FLTCamConfiguration *configuration =
      [[FLTCamConfiguration alloc] initWithMediaSettings:mediaSettings
          mediaSettingsWrapper:mediaSettingsAVWrapper
          captureDeviceFactory:^id<FLTCaptureDeviceControlling>(void) {
            return mockDevice;
          }
          captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
          captureSessionFactory:^id<FLTCaptureSession> _Nonnull {
            return videoSessionMock;
          }
          audioCaptureDeviceFactory:^id<FLTCaptureDeviceControlling> _Nonnull {
            return mockDevice;
          }];
  configuration.capturePhotoOutput =
      [[FLTDefaultCapturePhotoOutput alloc] initWithPhotoOutput:[AVCapturePhotoOutput new]];
  configuration.orientation = UIDeviceOrientationPortrait;
  configuration.assetWriterFactory = ^id<FLTAssetWriter> _Nonnull(
      NSURL *_Nonnull url, AVFileType _Nonnull fileType, NSError **error) {
    return assetWriter;
  };
  configuration.pixelBufferAdaptorFactory = ^id<FLTPixelBufferAdaptor> _Nonnull(
      id<FLTAssetWriterInput> _Nonnull input, NSDictionary<NSString *, id> *_Nullable settings) {
    return pixelBufferAdaptor;
  };
  configuration.photoSettingsFactory = [[MockCapturePhotoSettingsFactory alloc] init];

  return configuration;
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
