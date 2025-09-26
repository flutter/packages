// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCam.h"
#import "FLTCaptureConnection.h"
#import "FLTCaptureDevice.h"
#import "FLTCapturePhotoOutput.h"
#import "FLTCaptureVideoDataOutput.h"
#import "FLTDeviceOrientationProviding.h"
#import "FLTImageStreamHandler.h"
#import "FLTSavePhotoDelegate.h"

// APIs exposed for unit testing.
@interface FLTCam ()

/// The output for video capturing.
@property(strong, nonatomic) NSObject<FLTCaptureVideoDataOutput> *captureVideoOutput;

/// The output for photo capturing. Exposed setter for unit tests.
@property(strong, nonatomic) NSObject<FLTCapturePhotoOutput> *capturePhotoOutput;

@end
