// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

#import "FLTCaptureDeviceControlling.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCameraDeviceDiscovering <NSObject>
- (NSArray<id<FLTCaptureDeviceControlling>> *)
    discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                          mediaType:(AVMediaType)mediaType
                           position:(AVCaptureDevicePosition)position;
@end

@interface FLTDefaultCameraDeviceDiscoverer : NSObject <FLTCameraDeviceDiscovering>
@end

NS_ASSUME_NONNULL_END
