// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTPermissionServicing <NSObject>
- (AVAuthorizationStatus)authorizationStatusForMediaType:(AVMediaType)mediaType;
- (void)requestAccessForMediaType:(AVMediaType)mediaType
                completionHandler:(void (^)(BOOL granted))handler;
@end

@interface FLTDefaultPermissionService : NSObject <FLTPermissionServicing>
@end

NS_ASSUME_NONNULL_END
