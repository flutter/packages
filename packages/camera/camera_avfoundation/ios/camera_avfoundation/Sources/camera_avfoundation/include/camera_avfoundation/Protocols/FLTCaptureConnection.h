// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCaptureConnection <NSObject>
@property(nonatomic, readonly) AVCaptureConnection *connection;
@property(nonatomic) BOOL videoMirrored;
@property(nonatomic) AVCaptureVideoOrientation videoOrientation;
@property(nonatomic, readonly) NSArray<AVCaptureInputPort *> *inputPorts;
@property(nonatomic, readonly) BOOL isVideoMirroringSupported;
@property(nonatomic, readonly) BOOL isVideoOrientationSupported;
@end

@interface FLTDefaultCaptureConnection : NSObject <FLTCaptureConnection>
- (instancetype)initWithConnection:(AVCaptureConnection *)connection;
@end

NS_ASSUME_NONNULL_END
