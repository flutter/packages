// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import camera_avfoundation.Test;"

#import "CameraPlugin.h"
#import "FLTCam.h"
#import "FLTCamConfiguration.h"
#import "FLTCameraDeviceDiscovering.h"
#import "FLTCameraPermissionManager.h"
#import "FLTCaptureDevice.h"
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSObject<FLTCaptureDevice> *_Nonnull (^CaptureNamedDeviceFactory)(NSString *name);

/// APIs exposed for unit testing.
@interface CameraPlugin ()

/// All FLTCam's state access and capture session related operations should be on run on this queue.
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;

/// An internal camera object that manages camera's state and performs camera operations.
@property(nonatomic, strong) FLTCam *_Nullable camera;

/// Inject @p FlutterTextureRegistry and @p FlutterBinaryMessenger for unit testing.
- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger;

/// Inject @p FlutterTextureRegistry, @p FlutterBinaryMessenger, and Pigeon callback handler for
/// unit testing.
- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       globalAPI:(FCPCameraGlobalEventApi *)globalAPI
                deviceDiscoverer:(id<FLTCameraDeviceDiscovering>)deviceDiscoverer
               permissionManager:(FLTCameraPermissionManager *)permissionManager
                   deviceFactory:(CaptureNamedDeviceFactory)deviceFactory
           captureSessionFactory:(CaptureSessionFactory)captureSessionFactory
       captureDeviceInputFactory:(id<FLTCaptureDeviceInputFactory>)captureDeviceInputFactory
    NS_DESIGNATED_INITIALIZER;

/// Hide the default public constructor.
- (instancetype)init NS_UNAVAILABLE;

/// Called by the @c NSNotificationManager each time the device's orientation is changed.
///
/// @param notification @c NSNotification instance containing a reference to the `UIDevice` object
/// that triggered the orientation change.
- (void)orientationChanged:(NSNotification *)notification;

/// Creates FLTCam on session queue and reports the creation result.
/// @param name the name of the camera.
/// @param settings the creation settings.
/// @param completion the callback to inform the Dart side of the plugin of creation.
- (void)createCameraOnSessionQueueWithName:(NSString *)name
                                  settings:(FCPPlatformMediaSettings *)settings
                                completion:(void (^)(NSNumber *_Nullable,
                                                     FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
