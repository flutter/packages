// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockCaptureConnection : NSObject <FLTCaptureConnection>
@property(nonatomic, assign) BOOL videoMirrored;
@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property(nonatomic, strong) NSArray<AVCaptureInputPort *> *inputPorts;
@property(nonatomic, assign) BOOL isVideoMirroringSupported;
@property(nonatomic, assign) BOOL isVideoOrientationSupported;
@end

NS_ASSUME_NONNULL_END
