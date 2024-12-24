// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCamConfiguration.h"

@implementation FLTCamConfiguration

- (nonnull instancetype)
        initWithMediaSettings:(nonnull FCPPlatformMediaSettings *)mediaSettings
         mediaSettingsWrapper:(nonnull FLTCamMediaSettingsAVWrapper *)mediaSettingsWrapper
         captureDeviceFactory:(nonnull CaptureDeviceFactory)captureDeviceFactory
          captureSessionQueue:(nonnull dispatch_queue_t)captureSessionQueue
        captureSessionFactory:(nonnull CaptureSessionFactory)captureSessionFactory
    audioCaptureDeviceFactory:(nonnull AudioCaptureDeviceFactory)audioCaptureDeviceFactory {
  self = [super init];
  if (self) {
    _mediaSettings = mediaSettings;
    _mediaSettingsWrapper = mediaSettingsWrapper;
    _captureSessionQueue = captureSessionQueue;
    _videoCaptureSession = captureSessionFactory();
    _audioCaptureSession = captureSessionFactory();
    _captureDeviceFactory = captureDeviceFactory;
    _audioCaptureDeviceFactory = audioCaptureDeviceFactory;
    _orientation = [[UIDevice currentDevice] orientation];
    _capturePhotoOutput =
        [[FLTDefaultCapturePhotoOutput alloc] initWithPhotoOutput:[AVCapturePhotoOutput new]];
    _deviceOrientationProvider = [[FLTDefaultDeviceOrientationProvider alloc] init];
    _assetWriterFactory =
        ^id<FLTAssetWriter> _Nonnull(NSURL *_Nonnull url, AVFileType _Nonnull fileType,
                                     NSError *_Nullable __autoreleasing *_Nullable error) {
      return [[FLTDefaultAssetWriter alloc] initWithURL:url fileType:fileType error:error];
    };
    _pixelBufferAdaptorFactory = ^id<FLTPixelBufferAdaptor>(
        id<FLTAssetWriterInput> _Nonnull assetWriterInput,
        NSDictionary<NSString *, id> *_Nullable sourcePixelBufferAttributes) {
      return [[FLTDefaultPixelBufferAdaptor alloc]
          initWithAdaptor:[[AVAssetWriterInputPixelBufferAdaptor alloc]
                                 initWithAssetWriterInput:assetWriterInput.input
                              sourcePixelBufferAttributes:sourcePixelBufferAttributes]];
    };
    _photoSettingsFactory = [[FLTDefaultCapturePhotoSettingsFactory alloc] init];
    _videoDimensionsForFormat = ^CMVideoDimensions(id<FLTCaptureDeviceFormat> _Nonnull format) {
      return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
    };
  }
  return self;
}

@end
