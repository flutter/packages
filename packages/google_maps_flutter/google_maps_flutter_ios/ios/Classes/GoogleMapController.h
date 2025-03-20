// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "FGMCATransactionWrapper.h"
#import "FGMClusterManagersController.h"
#import "GoogleMapCircleController.h"
#import "GoogleMapMarkerController.h"
#import "GoogleMapPolygonController.h"
#import "GoogleMapPolylineController.h"
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

// Defines map overlay controllable from Flutter.
@interface FLTGoogleMapController : NSObject <GMSMapViewDelegate, FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
           creationParameters:(FGMPlatformMapViewCreationParams *)creationParameters
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)showAtOrigin:(CGPoint)origin;
- (void)hide;
- (nullable GMSCameraPosition *)cameraPosition;
@end

// Allows the engine to create new Google Map instances.
@interface FLTGoogleMapFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

/// Implementation of the Pigeon maps API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapCallHandler : NSObject <FGMMapsApi>
@end

/// Implementation of the Pigeon maps inspector API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapInspector : NSObject <FGMMapsInspectorApi>
@end

NS_ASSUME_NONNULL_END
