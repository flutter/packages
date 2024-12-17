// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "messages.g.h"

#import "FLTCaptureDeviceControlling.h"
#import "FLTCaptureSessionProtocol.h"

typedef id<FLTCaptureSessionProtocol> (^CaptureSessionFactory)(void);
typedef id<FLTCaptureDeviceControlling> (^CaptureNamedDeviceFactory)(NSString *name);

@interface CameraPlugin : NSObject <FlutterPlugin, FCPCameraApi>
@end
