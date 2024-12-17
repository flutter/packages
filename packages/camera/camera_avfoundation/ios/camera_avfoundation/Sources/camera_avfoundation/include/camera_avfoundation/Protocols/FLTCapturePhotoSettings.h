// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCapturePhotoSettings <NSObject>
@property(nonatomic, readonly) AVCapturePhotoSettings *settings;

@property(readonly, nonatomic) int64_t uniqueID;
@property(nonatomic, copy, readonly) NSDictionary<NSString *, id> *format;

- (void)setFlashMode:(AVCaptureFlashMode)flashMode;
- (void)setHighResolutionPhotoEnabled:(BOOL)enabled;
@end

@interface FLTDefaultCapturePhotoSettings : NSObject <FLTCapturePhotoSettings>
- (instancetype)initWithSettings:(AVCapturePhotoSettings *)settings;
@end

NS_ASSUME_NONNULL_END
