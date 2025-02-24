// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCaptureConnection`. It exists to allow replacing
/// `AVCaptureConnection` in tests.
@protocol FLTCaptureConnection <NSObject>

/// Underlying `AVCaptureConnection` instance. All methods and properties are passed through to
/// this.
@property(nonatomic, readonly) AVCaptureConnection *connection;

@property(nonatomic, getter=isVideoMirrored) BOOL videoMirrored;
@property(nonatomic) AVCaptureVideoOrientation videoOrientation;
@property(nonatomic, readonly) NSArray<AVCaptureInputPort *> *inputPorts;
@property(nonatomic, readonly, getter=isVideoMirroringSupported) BOOL supportsVideoMirroring;
@property(nonatomic, readonly, getter=isVideoOrientationSupported) BOOL supportsVideoOrientation;

@end

/// A default implementation of the `FLTCaptureConnection` protocol. It wraps an instance
/// of `AVCaptureConnection`.
@interface FLTDefaultCaptureConnection : NSObject <FLTCaptureConnection>

/// Initializes a `FLTDefaultCaptureConnection` with the given `AVCaptureConnection`.
/// All methods and property calls are passed through to this connection.
- (instancetype)initWithConnection:(AVCaptureConnection *)connection;

@end

NS_ASSUME_NONNULL_END
