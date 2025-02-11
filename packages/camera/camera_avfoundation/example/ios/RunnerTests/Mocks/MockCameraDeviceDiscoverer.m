// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCameraDeviceDiscoverer.h"

@implementation MockCameraDeviceDiscoverer

- (NSArray<NSObject<FLTCaptureDevice> *> *)
    discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                          mediaType:(AVMediaType)mediaType
                           position:(AVCaptureDevicePosition)position {
  if (self.discoverySessionStub) {
    return self.discoverySessionStub(deviceTypes, mediaType, position);
  }
  return @[];
}

@end
