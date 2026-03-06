// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMCircleController.h"
#import "FGMCircleController_Test.h"

#import "FGMConversionUtils.h"

@interface FGMCircleController ()

@property(nonatomic, strong) GMSCircle *circle;
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FGMCircleController

- (instancetype)initCircleWithPlatformCircle:(FGMPlatformCircle *)circle
                                     mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:FGMGetCoordinateForPigeonLatLng(circle.center)
                                     radius:circle.radius];
    _mapView = mapView;
    _circle.userData = @[ circle.circleId ];
    [FGMCircleController updateCircle:_circle fromPlatformCircle:circle withMapView:mapView];
  }
  return self;
}

- (void)removeCircle {
  self.circle.map = nil;
}

- (void)updateFromPlatformCircle:(FGMPlatformCircle *)platformCircle {
  [FGMCircleController updateCircle:self.circle
                 fromPlatformCircle:platformCircle
                        withMapView:self.mapView];
}

+ (void)updateCircle:(GMSCircle *)circle
    fromPlatformCircle:(FGMPlatformCircle *)platformCircle
           withMapView:(GMSMapView *)mapView {
  circle.tappable = platformCircle.consumeTapEvents;
  circle.zIndex = platformCircle.zIndex;
  circle.position = FGMGetCoordinateForPigeonLatLng(platformCircle.center);
  circle.radius = platformCircle.radius;
  circle.strokeColor = FGMGetColorForPigeonColor(platformCircle.strokeColor);
  circle.strokeWidth = platformCircle.strokeWidth;
  circle.fillColor = FGMGetColorForPigeonColor(platformCircle.fillColor);

  // This must be done last, to avoid visual flickers of default property values.
  circle.map = platformCircle.visible ? mapView : nil;
}

@end

@interface FGMCirclesController ()

@property(weak, nonatomic) NSObject<FGMMapEventDelegate> *eventDelegate;
@property(weak, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSMutableDictionary *circleIdToController;

@end

@implementation FGMCirclesController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                  eventDelegate:(NSObject<FGMMapEventDelegate> *)eventDelegate {
  self = [super init];
  if (self) {
    _eventDelegate = eventDelegate;
    _mapView = mapView;
    _circleIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)addCircles:(NSArray<FGMPlatformCircle *> *)circlesToAdd {
  for (FGMPlatformCircle *circle in circlesToAdd) {
    FGMCircleController *controller =
        [[FGMCircleController alloc] initCircleWithPlatformCircle:circle mapView:self.mapView];
    self.circleIdToController[circle.circleId] = controller;
  }
}

- (void)changeCircles:(NSArray<FGMPlatformCircle *> *)circlesToChange {
  for (FGMPlatformCircle *circle in circlesToChange) {
    FGMCircleController *controller = self.circleIdToController[circle.circleId];
    [controller updateFromPlatformCircle:circle];
  }
}

- (void)removeCirclesWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FGMCircleController *controller = self.circleIdToController[identifier];
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
  FGMCircleController *controller = self.circleIdToController[identifier];
  if (!controller) {
    return;
  }
  [self.eventDelegate didTapCircleWithIdentifier:identifier];
}

@end
