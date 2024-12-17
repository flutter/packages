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

- (instancetype)initWithPath:(GMSMutablePath *)path
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
  self.polygon.path = FGMGetPathFromPoints(points);
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

- (void)updateFromPlatformPolygon:(FGMPlatformPolygon *)polygon
                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self setConsumeTapEvents:polygon.consumesTapEvents];
  [self setVisible:polygon.visible];
  [self setZIndex:(int)polygon.zIndex];
  [self setPoints:FGMGetPointsForPigeonLatLngs(polygon.points)];
  [self setHoles:FGMGetHolesForPigeonLatLngArrays(polygon.holes)];
  [self setFillColor:FGMGetColorForRGBA(polygon.fillColor)];
  [self setStrokeColor:FGMGetColorForRGBA(polygon.strokeColor)];
  [self setStrokeWidth:polygon.strokeWidth];
}

@end

@interface FLTPolygonsController ()

@property(strong, nonatomic) NSMutableDictionary *polygonIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTPolygonsController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _polygonIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addPolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToAdd {
  for (FGMPlatformPolygon *polygon in polygonsToAdd) {
    GMSMutablePath *path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polygon.points));
    NSString *identifier = polygon.polygonId;
    FLTGoogleMapPolygonController *controller =
        [[FLTGoogleMapPolygonController alloc] initWithPath:path
                                                 identifier:identifier
                                                    mapView:self.mapView];
    [controller updateFromPlatformPolygon:polygon registrar:self.registrar];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)changePolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToChange {
  for (FGMPlatformPolygon *polygon in polygonsToChange) {
    NSString *identifier = polygon.polygonId;
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    [controller updateFromPlatformPolygon:polygon registrar:self.registrar];
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
  [self.callbackHandler didTapPolygonWithIdentifier:identifier
                                         completion:^(FlutterError *_Nullable _){
                                         }];
}

- (bool)hasPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polygonIdentifierToController[identifier] != nil;
}

@end
