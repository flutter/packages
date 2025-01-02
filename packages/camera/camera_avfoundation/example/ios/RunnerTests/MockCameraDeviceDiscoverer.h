// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockCameraDeviceDiscoverer : NSObject <FLTCameraDeviceDiscovering>
@property(nonatomic, copy)
    NSArray<id<FLTCaptureDeviceControlling>> *_Nullable (^discoverySessionStub)
        (NSArray<AVCaptureDeviceType> *deviceTypes, AVMediaType mediaType,
         AVCaptureDevicePosition position);
@end

NS_ASSUME_NONNULL_END
