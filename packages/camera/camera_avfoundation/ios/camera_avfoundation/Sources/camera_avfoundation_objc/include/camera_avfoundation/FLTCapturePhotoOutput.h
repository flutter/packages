// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "FLTCaptureOutput.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCapturePhotoOutput`. It exists to allow mocking
/// `AVCapturePhotoOutput` in tests.
@protocol FLTCapturePhotoOutput <FLTCaptureOutput>

/// The underlying instance of `AVCapturePhotoOutput`.
@property(nonatomic, readonly) AVCapturePhotoOutput *avOutput;

/// Corresponds to the `availablePhotoCodecTypes` property of `AVCapturePhotoOutput`
@property(nonatomic, readonly) NSArray<AVVideoCodecType> *availablePhotoCodecTypes;

/// Corresponds to the `highResolutionCaptureEnabled` property of `AVCapturePhotoOutput`
@property(nonatomic, assign) BOOL highResolutionCaptureEnabled;

/// Corresponds to the `supportedFlashModes` property of `AVCapturePhotoOutput`
@property(nonatomic, readonly) NSArray<NSNumber *> *supportedFlashModes;

/// Corresponds to the `capturePhotoWithSettings` method of `AVCapturePhotoOutput`
- (void)capturePhotoWithSettings:(AVCapturePhotoSettings *)settings
                        delegate:(NSObject<AVCapturePhotoCaptureDelegate> *)delegate;

@end

/// A default implementation of `FLTCapturePhotoOutput` which wraps an instance of
/// `AVCapturePhotoOutput`.
@interface FLTDefaultCapturePhotoOutput : NSObject <FLTCapturePhotoOutput>

/// Initializes an instance of `FLTDefaultCapturePhotoOutput` with the given `AVCapturePhotoOutput`.
/// All method and property calls will be forwarded to the given `photoOutput`.
- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput;

@end

NS_ASSUME_NONNULL_END
