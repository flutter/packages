// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTCameraDeviceDiscovering.h"

@implementation FLTDefaultCameraDeviceDiscoverer

- (NSArray<NSObject<FLTCaptureDevice> *> *)
    discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                          mediaType:(AVMediaType)mediaType
                           position:(AVCaptureDevicePosition)position {
  AVCaptureDeviceDiscoverySession *discoverySession =
      [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                             mediaType:mediaType
                                                              position:position];

  NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
  NSMutableArray<NSObject<FLTCaptureDevice> *> *deviceControllers =
      [NSMutableArray arrayWithCapacity:devices.count];
  for (AVCaptureDevice *device in devices) {
    [deviceControllers addObject:[[FLTDefaultCaptureDevice alloc] initWithDevice:device]];
  }

  return deviceControllers;
}

@end
