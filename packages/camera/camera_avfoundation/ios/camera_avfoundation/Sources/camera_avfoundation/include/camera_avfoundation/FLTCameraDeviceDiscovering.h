// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

#import "FLTCaptureDevice.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which abstracts the discovery of camera devices.
/// It is a thin wrapper around `AVCaptureDiscoverySession` and it exists to allow mocking in tests.
@protocol FLTCameraDeviceDiscovering <NSObject>
- (NSArray<NSObject<FLTCaptureDevice> *> *)
    discoverySessionWithDeviceTypes:(NSArray<AVCaptureDeviceType> *)deviceTypes
                          mediaType:(AVMediaType)mediaType
                           position:(AVCaptureDevicePosition)position;
@end

/// The default implementation of the `FLTCameraDeviceDiscovering` protocol.
/// It wraps a call to `AVCaptureDeviceDiscoverySession`.
@interface FLTDefaultCameraDeviceDiscoverer : NSObject <FLTCameraDeviceDiscovering>
@end

NS_ASSUME_NONNULL_END
