// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTCaptureDeviceControlling.h"

@implementation FLTDefaultCaptureDeviceInputFactory

- (AVCaptureInput *)deviceInputWithDevice:(id<FLTCaptureDeviceControlling>)device
                                    error:(NSError **)error {
  return [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
}

@end
