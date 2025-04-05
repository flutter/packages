// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A protocol which provides the current device orientation.
/// It exists to allow replacing UIDevice in tests.
@protocol FLTDeviceOrientationProviding <NSObject>

/// Returns the physical orientation of the device.
- (UIDeviceOrientation)orientation;

@end

/// A default implementation of FLTDeviceOrientationProviding which uses orientation
/// of the current device from UIDevice.
@interface FLTDefaultDeviceOrientationProvider : NSObject <FLTDeviceOrientationProviding>
@end

NS_ASSUME_NONNULL_END
