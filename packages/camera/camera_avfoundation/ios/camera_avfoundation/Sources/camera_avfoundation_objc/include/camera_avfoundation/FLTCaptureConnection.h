// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCaptureConnection`. It exists to allow replacing
/// `AVCaptureConnection` in tests.
@protocol FLTCaptureConnection <NSObject>

/// Corresponds to the `videoMirrored` property of `AVCaptureConnection`
@property(nonatomic, getter=isVideoMirrored) BOOL videoMirrored;

/// Corresponds to the `videoOrientation` property of `AVCaptureConnection`
@property(nonatomic) AVCaptureVideoOrientation videoOrientation;

/// Corresponds to the `inputPorts` property of `AVCaptureConnection`
@property(nonatomic, readonly) NSArray<AVCaptureInputPort *> *inputPorts;

/// Corresponds to the `supportsVideoMirroring` property of `AVCaptureConnection`
@property(nonatomic, readonly, getter=isVideoMirroringSupported) BOOL supportsVideoMirroring;

/// Corresponds to the `supportsVideoOrientation` property of `AVCaptureConnection`
@property(nonatomic, readonly, getter=isVideoOrientationSupported) BOOL supportsVideoOrientation;

/// Corresponds to the `preferredVideoStabilizationMode` property of `AVCaptureConnection`
@property(nonatomic) AVCaptureVideoStabilizationMode preferredVideoStabilizationMode;

@end

/// A default implementation of the `FLTCaptureConnection` protocol. It wraps an instance
/// of `AVCaptureConnection`.
@interface FLTDefaultCaptureConnection : NSObject <FLTCaptureConnection>

/// Initializes a `FLTDefaultCaptureConnection` with the given `AVCaptureConnection`.
/// All methods and property calls are passed through to this connection.
- (instancetype)initWithConnection:(AVCaptureConnection *)connection;

@end

NS_ASSUME_NONNULL_END
