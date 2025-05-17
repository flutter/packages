// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
#import "./include/camera_avfoundation/FLTCameraPermissionManager.h"
#import "./include/camera_avfoundation/FLTPermissionServicing.h"

@implementation FLTCameraPermissionManager

- (instancetype)initWithPermissionService:(id<FLTPermissionServicing>)service {
  self = [super init];
  if (self) {
    _permissionService = service ?: [[FLTDefaultPermissionService alloc] init];
  }
  return self;
}

- (void)requestAudioPermissionWithCompletionHandler:
    (__strong FLTCameraPermissionRequestCompletionHandler)handler {
  [self requestPermissionForAudio:YES handler:handler];
}

- (void)requestCameraPermissionWithCompletionHandler:
    (__strong FLTCameraPermissionRequestCompletionHandler)handler {
  [self requestPermissionForAudio:NO handler:handler];
}

- (void)requestPermissionForAudio:(BOOL)forAudio
                          handler:(FLTCameraPermissionRequestCompletionHandler)handler {
  AVMediaType mediaType;
  if (forAudio) {
    mediaType = AVMediaTypeAudio;
  } else {
    mediaType = AVMediaTypeVideo;
  }

  switch ([_permissionService authorizationStatusForMediaType:mediaType]) {
    case AVAuthorizationStatusAuthorized:
      handler(nil);
      break;
    case AVAuthorizationStatusDenied: {
      FlutterError *flutterError;
      if (forAudio) {
        flutterError =
            [FlutterError errorWithCode:@"AudioAccessDeniedWithoutPrompt"
                                message:@"User has previously denied the audio access request. "
                                        @"Go to Settings to enable audio access."
                                details:nil];
      } else {
        flutterError =
            [FlutterError errorWithCode:@"CameraAccessDeniedWithoutPrompt"
                                message:@"User has previously denied the camera access request. "
                                        @"Go to Settings to enable camera access."
                                details:nil];
      }
      handler(flutterError);
      break;
    }
    case AVAuthorizationStatusRestricted: {
      FlutterError *flutterError;
      if (forAudio) {
        flutterError = [FlutterError errorWithCode:@"AudioAccessRestricted"
                                           message:@"Audio access is restricted."
                                           details:nil];
      } else {
        flutterError = [FlutterError errorWithCode:@"CameraAccessRestricted"
                                           message:@"Camera access is restricted."
                                           details:nil];
      }
      handler(flutterError);
      break;
    }
    case AVAuthorizationStatusNotDetermined: {
      [_permissionService requestAccessForMediaType:mediaType
                                  completionHandler:^(BOOL granted) {
                                    // handler can be invoked on an arbitrary dispatch queue.
                                    if (granted) {
                                      handler(nil);
                                    } else {
                                      FlutterError *flutterError;
                                      if (forAudio) {
                                        flutterError = [FlutterError
                                            errorWithCode:@"AudioAccessDenied"
                                                  message:@"User denied the audio access request."
                                                  details:nil];
                                      } else {
                                        flutterError = [FlutterError
                                            errorWithCode:@"CameraAccessDenied"
                                                  message:@"User denied the camera access request."
                                                  details:nil];
                                      }
                                      handler(flutterError);
                                    }
                                  }];
      break;
    }
  }
}

@end
