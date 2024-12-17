// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

@interface MockCapturePhotoOutput : NSObject <FLTCapturePhotoOutput>
@property(nonatomic, copy) void (^capturePhotoWithSettingsStub)
    (id<FLTCapturePhotoSettings>, id<AVCapturePhotoCaptureDelegate>);
@property(nonatomic, strong) NSArray<AVVideoCodecType> *availablePhotoCodecTypes;
@end
