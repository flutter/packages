// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "messages.g.h"

// Defines polygon controllable by Flutter.
@interface FLTGoogleMapPolygonController : NSObject
- (instancetype)initWithPath:(GMSMutablePath *)path
                  identifier:(NSString *)identifier
                     mapView:(GMSMapView *)mapView;
- (void)removePolygon;
@end

@interface FLTPolygonsController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addPolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToAdd;
- (void)changePolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToChange;
- (void)removePolygonWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)didTapPolygonWithIdentifier:(NSString *)identifier;
- (bool)hasPolygonWithIdentifier:(NSString *)identifier;
@end
