// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapCircleController ()

@property(nonatomic, strong) GMSCircle *circle;
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapCircleController

- (instancetype)initCircleWithPosition:(CLLocationCoordinate2D)position
                                radius:(CLLocationDistance)radius
                              circleId:(NSString *)circleIdentifier
                               mapView:(GMSMapView *)mapView
                               options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:position radius:radius];
    _mapView = mapView;
    _circle.userData = @[ circleIdentifier ];
    [self interpretCircleOptions:options];
  }
  return self;
}

- (void)removeCircle {
  self.circle.map = nil;
}

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.circle.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.circle.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.circle.zIndex = zIndex;
}
- (void)setCenter:(CLLocationCoordinate2D)center {
  self.circle.position = center;
}
- (void)setRadius:(CLLocationDistance)radius {
  self.circle.radius = radius;
}

- (void)setStrokeColor:(UIColor *)color {
  self.circle.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.circle.strokeWidth = width;
}
- (void)setFillColor:(UIColor *)color {
  self.circle.fillColor = color;
}

- (void)interpretCircleOptions:(NSDictionary *)data {
  NSNumber *consumeTapEvents = FGMGetValueOrNilFromDict(data, @"consumeTapEvents");
  if (consumeTapEvents) {
    [self setConsumeTapEvents:consumeTapEvents.boolValue];
  }

  NSNumber *visible = FGMGetValueOrNilFromDict(data, @"visible");
  if (visible) {
    [self setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = FGMGetValueOrNilFromDict(data, @"zIndex");
  if (zIndex) {
    [self setZIndex:[zIndex intValue]];
  }

  NSArray *center = FGMGetValueOrNilFromDict(data, @"center");
  if (center) {
    [self setCenter:[FLTGoogleMapJSONConversions locationFromLatLong:center]];
  }

  NSNumber *radius = FGMGetValueOrNilFromDict(data, @"radius");
  if (radius) {
    [self setRadius:[radius floatValue]];
  }

  NSNumber *strokeColor = FGMGetValueOrNilFromDict(data, @"strokeColor");
  if (strokeColor) {
    [self setStrokeColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = FGMGetValueOrNilFromDict(data, @"strokeWidth");
  if (strokeWidth) {
    [self setStrokeWidth:[strokeWidth intValue]];
  }

  NSNumber *fillColor = FGMGetValueOrNilFromDict(data, @"fillColor");
  if (fillColor) {
    [self setFillColor:[FLTGoogleMapJSONConversions colorFromRGBA:fillColor]];
  }
}

@end

@interface FLTCirclesController ()

@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSMutableDictionary *circleIdToController;

@end

@implementation FLTCirclesController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _circleIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)addJSONCircles:(NSArray<NSDictionary<NSString *, id> *> *)circlesToAdd {
  for (NSDictionary<NSString *, id> *circle in circlesToAdd) {
    CLLocationCoordinate2D position = [FLTCirclesController getPosition:circle];
    CLLocationDistance radius = [FLTCirclesController getRadius:circle];
    NSString *circleId = [FLTCirclesController getCircleId:circle];
    FLTGoogleMapCircleController *controller =
        [[FLTGoogleMapCircleController alloc] initCircleWithPosition:position
                                                              radius:radius
                                                            circleId:circleId
                                                             mapView:self.mapView
                                                             options:circle];
    self.circleIdToController[circleId] = controller;
  }
}

- (void)addCircles:(NSArray<FGMPlatformCircle *> *)circlesToAdd {
  for (FGMPlatformCircle *circle in circlesToAdd) {
    CLLocationCoordinate2D position = [FLTCirclesController getPosition:circle.json];
    CLLocationDistance radius = [FLTCirclesController getRadius:circle.json];
    NSString *circleId = [FLTCirclesController getCircleId:circle.json];
    FLTGoogleMapCircleController *controller =
        [[FLTGoogleMapCircleController alloc] initCircleWithPosition:position
                                                              radius:radius
                                                            circleId:circleId
                                                             mapView:self.mapView
                                                             options:circle.json];
    self.circleIdToController[circleId] = controller;
  }
}

- (void)changeCircles:(NSArray<FGMPlatformCircle *> *)circlesToChange {
  for (FGMPlatformCircle *circle in circlesToChange) {
    NSString *circleId = [FLTCirclesController getCircleId:circle.json];
    FLTGoogleMapCircleController *controller = self.circleIdToController[circleId];
    [controller interpretCircleOptions:circle.json];
  }
}

- (void)removeCirclesWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapCircleController *controller = self.circleIdToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removeCircle];
    [self.circleIdToController removeObjectForKey:identifier];
  }
}

- (bool)hasCircleWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.circleIdToController[identifier] != nil;
}

- (void)didTapCircleWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapCircleController *controller = self.circleIdToController[identifier];
  if (!controller) {
    return;
  }
  [self.methodChannel invokeMethod:@"circle#onTap" arguments:@{@"circleId" : identifier}];
}

+ (CLLocationCoordinate2D)getPosition:(NSDictionary *)circle {
  NSArray *center = circle[@"center"];
  return [FLTGoogleMapJSONConversions locationFromLatLong:center];
}

+ (CLLocationDistance)getRadius:(NSDictionary *)circle {
  NSNumber *radius = circle[@"radius"];
  return [radius floatValue];
}

+ (NSString *)getCircleId:(NSDictionary *)circle {
  return circle[@"circleId"];
}

@end
