// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FGMCATransactionWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FGMMapCallHandler : NSObject <FGMMapsApi>

/// Transaction wrapper for CATransaction to allow mocking in tests.
@property(nonatomic, strong) id<FGMCATransactionProtocol> transactionWrapper;

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
