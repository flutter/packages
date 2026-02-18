// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMPolygonController.h"
#import "FGMPolygonController_Test.h"

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

@interface FGMPolygonController ()

@property(strong, nonatomic) GMSPolygon *polygon;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FGMPolygonController

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
  [FGMPolygonController updatePolygon:self.polygon
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

@interface FGMPolygonsController ()

@property(strong, nonatomic) NSMutableDictionary *polygonIdentifierToController;
@property(weak, nonatomic) NSObject<FGMMapEventDelegate> *eventDelegate;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FGMPolygonsController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                  eventDelegate:(NSObject<FGMMapEventDelegate> *)eventDelegate {
  self = [super init];
  if (self) {
    _eventDelegate = eventDelegate;
    _mapView = mapView;
    _polygonIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)addPolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToAdd {
  for (FGMPlatformPolygon *polygon in polygonsToAdd) {
    GMSMutablePath *path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polygon.points));
    NSString *identifier = polygon.polygonId;
    FGMPolygonController *controller = [[FGMPolygonController alloc] initWithPath:path
                                                                       identifier:identifier
                                                                          mapView:self.mapView];
    [controller updateFromPlatformPolygon:polygon];
    self.polygonIdentifierToController[identifier] = controller;
  }
}

- (void)changePolygons:(NSArray<FGMPlatformPolygon *> *)polygonsToChange {
  for (FGMPlatformPolygon *polygon in polygonsToChange) {
    NSString *identifier = polygon.polygonId;
    FGMPolygonController *controller = self.polygonIdentifierToController[identifier];
    [controller updateFromPlatformPolygon:polygon];
  }
}

- (void)removePolygonWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FGMPolygonController *controller = self.polygonIdentifierToController[identifier];
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
  FGMPolygonController *controller = self.polygonIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.eventDelegate didTapPolygonWithIdentifier:identifier];
}

- (bool)hasPolygonWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polygonIdentifierToController[identifier] != nil;
}

@end
