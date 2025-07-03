// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTPermissionServicing.h"

@implementation FLTDefaultPermissionService
- (AVAuthorizationStatus)authorizationStatusForMediaType:(AVMediaType)mediaType {
  return [AVCaptureDevice authorizationStatusForMediaType:mediaType];
}

- (void)requestAccessForMediaType:(AVMediaType)mediaType
                completionHandler:(void (^)(BOOL granted))handler {
  [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:handler];
}
@end
