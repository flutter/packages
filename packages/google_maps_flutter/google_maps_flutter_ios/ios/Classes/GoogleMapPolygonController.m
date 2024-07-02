// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolygonController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapPolygonController ()

@property(strong, nonatomic) GMSPolygon *polygon;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapPolygonController

- (instancetype)initPolygonWithPath:(GMSMutablePath *)path
                         identifier:(NSString *)identifier
                            mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _polygon = [GMSPolygon polygonWithPath:path];
    _mapView = mapView;
    _polygon.userData = @[ identifier ];
  }
  return self;
}

- (void)removePolygon {
  self.polygon.map = nil;
}

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.polygon.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.polygon.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.polygon.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation *> *)points {
  GMSMutablePath *path = [GMSMutablePath path];

  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  self.polygon.path = path;
}
- (void)setHoles:(NSArray<NSArray<CLLocation *> *> *)rawHoles {
  NSMutableArray<GMSMutablePath *> *holes = [[NSMutableArray<GMSMutablePath *> alloc] init];

  for (NSArray<CLLocation *> *points in rawHoles) {
    GMSMutablePath *path = [GMSMutablePath path];
    for (CLLocation *location in points) {
      [path addCoordinate:location.coordinate];
    }
    [holes addObject:path];
  }

  self.polygon.holes = holes;
}

- (void)setFillColor:(UIColor *)color {
  self.polygon.fillColor = color;
}
- (void)setStrokeColor:(UIColor *)color {
  self.polygon.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.polygon.strokeWidth = width;
}

- (void)interpretPolygonOptions:(NSDictionary *)data
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSNumber *consumeTapEvents = FGMGetValueOrNilFromDict(data, @"consumeTapEvents");
  if (consumeTapEvents) {
    [self setConsumeTapEvents:[consumeTapEvents boolValue]];
  }

  NSNumber *visible = FGMGetValueOrNilFromDict(data, @"visible");
  if (visible) {
    [self setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = FGMGetValueOrNilFromDict(data, @"zIndex");
  if (zIndex) {
    [self setZIndex:[zIndex intValue]];
  }

  NSArray *points = FGMGetValueOrNilFromDict(data, @"points");
  if (points) {
    [self setPoints:[FLTGoogleMapJSONConversions pointsFromLatLongs:points]];
  }

  NSArray *holes = FGMGetValueOrNilFromDict(data, @"holes");
  if (holes) {
    [self setHoles:[FLTGoogleMapJSONConversions holesFromPointsArray:holes]];
  }

  NSNumber *fillColor = FGMGetValueOrNilFromDict(data, @"fillColor");
  if (fillColor) {
    [self setFillColor:[FLTGoogleMapJSONConversions colorFromRGBA:fillColor]];
  }

  NSNumber *strokeColor = FGMGetValueOrNilFromDict(data, @"strokeColor");
  if (strokeColor) {
    [self setStrokeColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = FGMGetValueOrNilFromDict(data, @"strokeWidth");
  if (strokeWidth) {
    [self setStrokeWidth:[strokeWidth intValue]];
  }
}

@end

@interface FLTPolygonsController ()

@property(strong, nonatomic) NSMutableDictionary *polygonIdentifierToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTPolygonsController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _polygonIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addJSONPolygons:(NSArray<NSDictionary<NSString *, id> *> *)polygonsToAdd {
  for (NSDictionary<NSString *, id> *polygon in polygonsToAdd) {
    GMSMutablePath *path = [FLTPolygonsController getPath:polygon];
    NSString *identifier = polygon[@"polygonId"];
    FLTGoogleMapPolygonController *controller =
        [[FLTGoogleMapPolygonController alloc] initPolygonWithPath:path
                                                        identifier:identifier
                                                           mapView:self.mapView];
    [controller interpretPolygonOptions:polygon registrar:self.registrar];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)addPolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToAdd {
  for (FGMPlatformPolygon *polygon in polygonsToAdd) {
    GMSMutablePath *path = [FLTPolygonsController getPath:polygon.json];
    NSString *identifier = polygon.json[@"polygonId"];
    FLTGoogleMapPolygonController *controller =
        [[FLTGoogleMapPolygonController alloc] initPolygonWithPath:path
                                                        identifier:identifier
                                                           mapView:self.mapView];
    [controller interpretPolygonOptions:polygon.json registrar:self.registrar];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)changePolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToChange {
  for (FGMPlatformPolygon *polygon in polygonsToChange) {
    NSString *identifier = polygon.json[@"polygonId"];
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    [controller interpretPolygonOptions:polygon.json registrar:self.registrar];
  }
}

- (void)removePolygonWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removePolygon];
    [self.polygonIdentifierToController removeObjectForKey:identifier];
  }
}

- (void)didTapPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.methodChannel invokeMethod:@"polygon#onTap" arguments:@{@"polygonId" : identifier}];
}

- (bool)hasPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polygonIdentifierToController[identifier] != nil;
}

+ (GMSMutablePath *)getPath:(NSDictionary *)polygon {
  NSArray *pointArray = polygon[@"points"];
  NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatLongs:pointArray];
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}

@end
