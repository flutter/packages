// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "FLTCapturePhotoOutput.h"
#import "FLTCapturePhotoSettings.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCapturePhotoOutput <NSObject>
@property(nonatomic, readonly) AVCapturePhotoOutput *photoOutput;
@property(nonatomic, readonly) NSArray<AVVideoCodecType> *availablePhotoCodecTypes;
@property(nonatomic, assign, getter=isHighResolutionCaptureEnabled)
    BOOL highResolutionCaptureEnabled;
@property(nonatomic, readonly) NSArray<NSNumber *> *supportedFlashModes;

- (void)capturePhotoWithSettings:(id<FLTCapturePhotoSettings>)settings
                        delegate:(id<AVCapturePhotoCaptureDelegate>)delegate;
- (nullable AVCaptureConnection *)connectionWithMediaType:(AVMediaType)mediaType;
@end

@interface FLTDefaultCapturePhotoOutput : NSObject <FLTCapturePhotoOutput>
- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput;
@end

NS_ASSUME_NONNULL_END
