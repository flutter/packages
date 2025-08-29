// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCam.h"
#import "./include/camera_avfoundation/FLTCam_Test.h"

@import Flutter;
#import <libkern/OSAtomic.h>

#import "./include/camera_avfoundation/FLTCaptureConnection.h"
#import "./include/camera_avfoundation/FLTCaptureDevice.h"
#import "./include/camera_avfoundation/FLTDeviceOrientationProviding.h"
#import "./include/camera_avfoundation/FLTEventChannel.h"
#import "./include/camera_avfoundation/FLTFormatUtils.h"
#import "./include/camera_avfoundation/FLTImageStreamHandler.h"
#import "./include/camera_avfoundation/FLTSavePhotoDelegate.h"
#import "./include/camera_avfoundation/FLTThreadSafeEventChannel.h"
#import "./include/camera_avfoundation/QueueUtils.h"
#import "./include/camera_avfoundation/messages.g.h"

@interface FLTCam ()
@end

@implementation FLTCam
@end
