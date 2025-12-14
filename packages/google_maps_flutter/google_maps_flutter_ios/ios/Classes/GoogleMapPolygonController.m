// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolygonController.h"
#import "GoogleMapPolygonController_Test.h"

#import "FGMConversionUtils.h"

/// Converts a list of holes represented as CLLocation lists to GMSMutablePath lists.
static NSArray<GMSMutablePath *> *FMGPathHolesFromLocationHoles(
    NSArray<NSArray<CLLocation *> *> *locationHoles) {
  NSMutableArray<GMSMutablePath *> *pathHoles =
      [NSMutableArray arrayWithCapacity:locationHoles.count];
  for (NSArray<CLLocation *> *hole in locationHoles) {
    [pathHoles addObject:FGMGetPathFromPoints(hole)];
  }
  return pathHoles;
}

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

- (void)updateFromPlatformPolygon:(FGMPlatformPolygon *)polygon {
  [FLTGoogleMapPolygonController updatePolygon:self.polygon
                           fromPlatformPolygon:polygon
                                   withMapView:self.mapView];
}

+ (void)updatePolygon:(GMSPolygon *)polygon
    fromPlatformPolygon:(FGMPlatformPolygon *)platformPolygon
            withMapView:(GMSMapView *)mapView {
  polygon.tappable = platformPolygon.consumesTapEvents;
  polygon.zIndex = (int)platformPolygon.zIndex;
  polygon.path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(platformPolygon.points));
  polygon.holes =
      FMGPathHolesFromLocationHoles(FGMGetHolesForPigeonLatLngArrays(platformPolygon.holes));
  polygon.fillColor = FGMGetColorForPigeonColor(platformPolygon.fillColor);
  polygon.strokeColor = FGMGetColorForPigeonColor(platformPolygon.strokeColor);
  polygon.strokeWidth = platformPolygon.strokeWidth;

  // This must be done last, to avoid visual flickers of default property values.
  polygon.map = platformPolygon.visible ? mapView : nil;
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
    [controller updateFromPlatformPolygon:polygon];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)changePolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToChange {
  for (FGMPlatformPolygon *polygon in polygonsToChange) {
    NSString *identifier = polygon.polygonId;
    FLTGoogleMapPolygonController *controller = self.polygonIdentifierToController[identifier];
    [controller updateFromPlatformPolygon:polygon];
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
