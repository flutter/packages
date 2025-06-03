// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "FLTCaptureOutput.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCaptureVideoDataOutput`. It exists to allow
/// mocking `AVCaptureVideoDataOutput` in tests.
@protocol FLTCaptureVideoDataOutput <FLTCaptureOutput>

/// The underlying instance of `AVCaptureVideoDataOutput`.
@property(nonatomic, readonly) AVCaptureVideoDataOutput *avOutput;

/// Corresponds to the `alwaysDiscardsLateVideoFrames` property of `AVCaptureVideoDataOutput`
@property(nonatomic) BOOL alwaysDiscardsLateVideoFrames;

/// Corresponds to the `videoSettings` property of `AVCaptureVideoDataOutput`
@property(nonatomic, copy, null_resettable) NSDictionary<NSString *, id> *videoSettings;

/// Corresponds to the `setSampleBufferDelegate` method of `AVCaptureVideoDataOutput`
- (void)setSampleBufferDelegate:
            (nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate
                          queue:(nullable dispatch_queue_t)sampleBufferCallbackQueue;

@end

/// A default implementation of `FLTCaptureVideoDataOutput` which wraps an instance of
/// `AVCaptureVideoDataOutput`.
@interface FLTDefaultCaptureVideoDataOutput : NSObject <FLTCaptureVideoDataOutput>

/// Initializes an instance of `FLTDefaultCaptureVideDataOutput` with the given
/// `AVCaptureVideoDataOutput`. All method and property calls will be forwarded to the given
/// `videoOutput`.
- (instancetype)initWithCaptureVideoOutput:(AVCaptureVideoDataOutput *)videoOutput;

@end

NS_ASSUME_NONNULL_END
