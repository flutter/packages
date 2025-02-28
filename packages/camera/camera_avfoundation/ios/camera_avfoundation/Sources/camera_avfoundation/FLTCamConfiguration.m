// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCamConfiguration.h"

@implementation FLTCamConfiguration

- (instancetype)initWithMediaSettings:(FCPPlatformMediaSettings *)mediaSettings
                 mediaSettingsWrapper:(FLTCamMediaSettingsAVWrapper *)mediaSettingsWrapper
                 captureDeviceFactory:(CaptureDeviceFactory)captureDeviceFactory
                captureSessionFactory:(CaptureSessionFactory)captureSessionFactory
                  captureSessionQueue:(dispatch_queue_t)captureSessionQueue
            captureDeviceInputFactory:
                (NSObject<FLTCaptureDeviceInputFactory> *)captureDeviceInputFactory {
  self = [super init];
  if (self) {
    _mediaSettings = mediaSettings;
    _mediaSettingsWrapper = mediaSettingsWrapper;
    _captureSessionQueue = captureSessionQueue;
    _videoCaptureSession = captureSessionFactory();
    _audioCaptureSession = captureSessionFactory();
    _captureDeviceFactory = captureDeviceFactory;
    _orientation = [[UIDevice currentDevice] orientation];
    _deviceOrientationProvider = [[FLTDefaultDeviceOrientationProvider alloc] init];
    _videoDimensionsForFormat = ^CMVideoDimensions(NSObject<FLTCaptureDeviceFormat> *format) {
      return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
    };
    _captureDeviceInputFactory = captureDeviceInputFactory;
    _assetWriterFactory = ^id<FLTAssetWriter>(NSURL *url, AVFileType fileType, NSError **error) {
      return [[FLTDefaultAssetWriter alloc] initWithURL:url fileType:fileType error:error];
    };
    _inputPixelBufferAdaptorFactory = ^NSObject<FLTAssetWriterInputPixelBufferAdaptor> *(
        NSObject<FLTAssetWriterInput> *assetWriterInput,
        NSDictionary<NSString *, id> *sourcePixelBufferAttributes) {
      return [[FLTDefaultAssetWriterInputPixelBufferAdaptor alloc]
          initWithAdaptor:[[AVAssetWriterInputPixelBufferAdaptor alloc]
                                 initWithAssetWriterInput:assetWriterInput.input
                              sourcePixelBufferAttributes:sourcePixelBufferAttributes]];
    };
  }
  return self;
}

@end
