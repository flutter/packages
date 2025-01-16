// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTCameraDeviceDiscovering.h"

@implementation FLTDefaultCameraDeviceDiscoverer

- (NSArray<id<FLTCaptureDevice>> *)
    discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                          mediaType:(AVMediaType)mediaType
                           position:(AVCaptureDevicePosition)position {
  AVCaptureDeviceDiscoverySession *discoverySession =
      [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                             mediaType:mediaType
                                                              position:position];

  NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
  NSMutableArray<id<FLTCaptureDevice>> *deviceControllers = [NSMutableArray array];

  for (AVCaptureDevice *device in devices) {
    [deviceControllers addObject:(id<FLTCaptureDevice>)device];
  }

  return deviceControllers;
}

@end
