// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "messages.g.h"

// Defines circle controllable by Flutter.
@interface FLTGoogleMapCircleController : NSObject
- (instancetype)initCircleWithPosition:(CLLocationCoordinate2D)position
                                radius:(CLLocationDistance)radius
                              circleId:(NSString *)circleIdentifier
                               mapView:(GMSMapView *)mapView
                               options:(NSDictionary *)options;
- (void)removeCircle;
@end

@interface FLTCirclesController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addJSONCircles:(NSArray<NSDictionary<NSString *, id> *> *)circlesToAdd;
- (void)addCircles:(NSArray<FGMPlatformCircle *> *)circlesToAdd;
- (void)changeCircles:(NSArray<FGMPlatformCircle *> *)circlesToChange;
- (void)removeCirclesWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)didTapCircleWithIdentifier:(NSString *)identifier;
- (bool)hasCircleWithIdentifier:(NSString *)identifier;
@end
