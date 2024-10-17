// Copyright 2013 The Flutter Authors. All rights reserved.
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

/// Sets the pattern on polyline controller
///
/// @param styles The styles for repeating pattern sections.
/// @param lengths The lengths for repeating pattern sections.
- (void)setPattern:(NSArray<GMSStrokeStyle *> *)styles lengths:(NSArray<NSNumber *> *)lengths;
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
