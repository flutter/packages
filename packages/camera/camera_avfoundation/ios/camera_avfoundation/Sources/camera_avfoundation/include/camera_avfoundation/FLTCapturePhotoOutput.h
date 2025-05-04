// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "FLTCapturePhotoOutput.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCapturePhotoOutput`. It exists to allow mocking
/// `AVCapturePhotoOutput` in tests.
@protocol FLTCapturePhotoOutput <NSObject>

/// The underlying instance of `AVCapturePhotoOutput`.
@property(nonatomic, readonly) AVCapturePhotoOutput *photoOutput;

@property(nonatomic, readonly) NSArray<AVVideoCodecType> *availablePhotoCodecTypes;
@property(nonatomic, assign) BOOL highResolutionCaptureEnabled;
@property(nonatomic, readonly) NSArray<NSNumber *> *supportedFlashModes;

- (void)capturePhotoWithSettings:(AVCapturePhotoSettings *)settings
                        delegate:(NSObject<AVCapturePhotoCaptureDelegate> *)delegate;
- (nullable AVCaptureConnection *)connectionWithMediaType:(AVMediaType)mediaType;

@end

/// A default implementation of `FLTCapturePhotoOutput` which wraps an instance of
/// `AVCapturePhotoOutput`.
@interface FLTDefaultCapturePhotoOutput : NSObject <FLTCapturePhotoOutput>

/// Initializes an instance of `FLTDefaultCapturePhotoOutput` with the given `AVCapturePhotoOutput`.
/// All method and property calls will be forwarded to the given `photoOutput`.
- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput;

@end

NS_ASSUME_NONNULL_END
