// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "FGMCATransactionWrapper.h"
#import "GoogleMapController.h"

NS_ASSUME_NONNULL_BEGIN

/// Implementation of the Pigeon maps API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapCallHandler : NSObject <FGMMapsApi>

/// The transaction wrapper to use for camera animations.
@property(nonatomic, strong) id<FGMCATransactionProtocol> transactionWrapper;

@end

/// Implementation of the Pigeon maps inspector API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapInspector : NSObject <FGMMapsInspectorApi>

/// Initializes a Pigeon API for inpector with a map controller.
- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix;

@end

@interface FLTGoogleMapController (Test)

/// Initializes a map controller with a concrete map view.
///
/// @param mapView A map view that will be displayed by the controller
/// @param viewId A unique identifier for the controller.
/// @param creationParameters Parameters for initialising the map view.
/// @param registrar The plugin registrar passed from Flutter.
- (instancetype)initWithMapView:(GMSMapView *)mapView
                 viewIdentifier:(int64_t)viewId
             creationParameters:(FGMPlatformMapViewCreationParams *)creationParameters
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

// The main Pigeon API implementation.
@property(nonatomic, strong, readonly) FGMMapCallHandler *callHandler;

@end

NS_ASSUME_NONNULL_END
