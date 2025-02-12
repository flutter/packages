// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// Mock implementation of `FLTCameraDeviceDiscovering` protocol which allows injecting a custom
/// implementation for session discovery.
@interface MockCameraDeviceDiscoverer : NSObject <FLTCameraDeviceDiscovering>

/// A stub that replaces the default implementation of
/// `discoverySessionWithDeviceTypes:mediaType:position`.
@property(nonatomic, copy) NSArray<NSObject<FLTCaptureDevice> *> *_Nullable (^discoverySessionStub)
    (NSArray<AVCaptureDeviceType> *deviceTypes, AVMediaType mediaType,
     AVCaptureDevicePosition position);

@end

NS_ASSUME_NONNULL_END
