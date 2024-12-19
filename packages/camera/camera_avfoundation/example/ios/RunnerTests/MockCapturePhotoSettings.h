// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

@interface MockCapturePhotoSettings : NSObject <FLTCapturePhotoSettings>
@property(nonatomic, strong) AVCapturePhotoSettings *settings;
@property(nonatomic, assign) int64_t uniqueID;
@property(nonatomic, copy) NSDictionary<NSString *, id> *format;
@property(nonatomic, assign) AVCaptureFlashMode flashMode;
@property(nonatomic, assign) BOOL highResolutionPhotoEnabled;
@end
