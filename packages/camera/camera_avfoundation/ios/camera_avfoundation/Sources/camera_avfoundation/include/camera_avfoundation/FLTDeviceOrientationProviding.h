// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLTDeviceOrientationProviding <NSObject>
- (UIDeviceOrientation)orientation;
@end

@interface FLTDefaultDeviceOrientationProvider : NSObject <FLTDeviceOrientationProviding>
@end

NS_ASSUME_NONNULL_END
