// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTDeviceOrientationProviding.h"
#import <UIKit/UIKit.h>

@implementation FLTDefaultDeviceOrientationProvider

- (UIDeviceOrientation)orientation {
  return [[UIDevice currentDevice] orientation];
}

@end
