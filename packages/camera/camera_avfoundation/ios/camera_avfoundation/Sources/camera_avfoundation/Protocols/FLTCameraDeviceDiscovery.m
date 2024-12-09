// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTCameraDeviceDiscovery.h"

@implementation FLTDefaultCameraDeviceDiscovery

- (NSArray<id<FLTCaptureDeviceControlling>> *)discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                                                    mediaType:(AVMediaType)mediaType
                                                     position:(AVCaptureDevicePosition)position {
  AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
      discoverySessionWithDeviceTypes:deviceTypes
                            mediaType:mediaType
                             position:position];
  
  NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
  NSMutableArray<id<FLTCaptureDeviceControlling>> *deviceControllers = [NSMutableArray array];
  
  for (AVCaptureDevice *device in devices) {
      FLTDefaultCaptureDeviceController *controller = [[FLTDefaultCaptureDeviceController alloc] initWithDevice:device];
      [deviceControllers addObject:controller];
  }
  
  return deviceControllers;
}

@end
