// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
#import <Flutter/Flutter.h>

#import "FLTPermissionServicing.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FLTCameraPermissionRequestCompletionHandler)(FlutterError *_Nullable);

@interface FLTCameraPermissionManager : NSObject
@property(nonatomic, strong) id<FLTPermissionServicing> permissionService;

- (instancetype)initWithPermissionService:(id<FLTPermissionServicing>)service;

/// Requests camera access permission.
///
/// If it is the first time requesting camera access, a permission dialog will show up on the
/// screen. Otherwise AVFoundation simply returns the user's previous choice, and in this case the
/// user will have to update the choice in Settings app.
///
/// @param handler if access permission is (or was previously) granted, completion handler will be
/// called without error; Otherwise completion handler will be called with error. Handler can be
/// called on an arbitrary dispatch queue.
- (void)requestCameraPermissionWithCompletionHandler:
    (FLTCameraPermissionRequestCompletionHandler)handler;

/// Requests audio access permission.
///
/// If it is the first time requesting audio access, a permission dialog will show up on the
/// screen. Otherwise AVFoundation simply returns the user's previous choice, and in this case the
/// user will have to update the choice in Settings app.
///
/// @param handler if access permission is (or was previously) granted, completion handler will be
/// called without error; Otherwise completion handler will be called with error. Handler can be
/// called on an arbitrary dispatch queue.
- (void)requestAudioPermissionWithCompletionHandler:
    (FLTCameraPermissionRequestCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
