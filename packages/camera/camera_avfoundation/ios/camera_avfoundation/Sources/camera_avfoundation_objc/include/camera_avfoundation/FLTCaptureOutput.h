// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "FLTCaptureConnection.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to `AVCapturePhotoOutput`. It exists to allow mocking
/// `AVCapturePhotoOutput` in tests.
@protocol FLTCaptureOutput <NSObject>

///// The underlying instance of `AVCapturePhotoOutput`.
//@property(nonatomic, readonly) AVCaptureOutput *avOutput;

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:(AVMediaType)mediaType;

@end

NS_ASSUME_NONNULL_END
