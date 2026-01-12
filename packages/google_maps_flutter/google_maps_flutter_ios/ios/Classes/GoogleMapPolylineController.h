// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "messages.g.h"

// Defines polyline controllable by Flutter.
@interface FLTGoogleMapPolylineController : NSObject
- (instancetype)initWithPath:(GMSMutablePath *)path
                  identifier:(NSString *)identifier
                     mapView:(GMSMapView *)mapView;
- (void)removePolyline;
@end

@interface FLTPolylinesController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addPolylines:(NSArray<FGMPlatformPolyline *> *)polylinesToAdd;
- (void)changePolylines:(NSArray<FGMPlatformPolyline *> *)polylinesToChange;
- (void)removePolylineWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)didTapPolylineWithIdentifier:(NSString *)identifier;
- (bool)hasPolylineWithIdentifier:(NSString *)identifier;
@end
