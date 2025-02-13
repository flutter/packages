// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// A mock implementation of `FLTCaptureConnection` protocol that allows injecting a custom
/// implementation.
@interface MockCaptureConnection : NSObject <FLTCaptureConnection>

// Properties redeclared as read/write for testing purposes.
@property(nonatomic, strong) AVCaptureConnection *connection;
@property(nonatomic, assign) BOOL videoMirrored;
@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property(nonatomic, strong) NSArray<AVCaptureInputPort *> *inputPorts;
@property(nonatomic, assign) BOOL isVideoMirroringSupported;
@property(nonatomic, assign) BOOL isVideoOrientationSupported;

@end

NS_ASSUME_NONNULL_END
