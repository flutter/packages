// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"
#import "GoogleMapCircleController_Test.h"

#import "FGMConversionUtils.h"

@interface FLTGoogleMapCircleController ()

@property(nonatomic, strong) GMSCircle *circle;
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapCircleController

- (instancetype)initCircleWithPlatformCircle:(FGMPlatformCircle *)circle
                                     mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:FGMGetCoordinateForPigeonLatLng(circle.center)
                                     radius:circle.radius];
    _mapView = mapView;
    _circle.userData = @[ circle.circleId ];
    [FLTGoogleMapCircleController updateCircle:_circle
                            fromPlatformCircle:circle
                                   withMapView:mapView];
  }
  return self;
}

- (void)removeCircle {
  self.circle.map = nil;
}

- (void)updateFromPlatformCircle:(FGMPlatformCircle *)platformCircle {
  [FLTGoogleMapCircleController updateCircle:self.circle
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

@interface FLTCirclesController ()

@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSMutableDictionary *circleIdToController;

@end

@implementation FLTCirclesController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _circleIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
  }
  return self;
}

- (void)addCircles:(NSArray<FGMPlatformCircle *> *)circlesToAdd {
  for (FGMPlatformCircle *circle in circlesToAdd) {
    FLTGoogleMapCircleController *controller =
        [[FLTGoogleMapCircleController alloc] initCircleWithPlatformCircle:circle
                                                                   mapView:self.mapView];
    self.circleIdToController[circle.circleId] = controller;
  }
}

- (void)changeCircles:(NSArray<FGMPlatformCircle *> *)circlesToChange {
  for (FGMPlatformCircle *circle in circlesToChange) {
    FLTGoogleMapCircleController *controller = self.circleIdToController[circle.circleId];
    [controller updateFromPlatformCircle:circle];
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
  [self.callbackHandler didTapCircleWithIdentifier:identifier
                                        completion:^(FlutterError *_Nullable _){
                                        }];
}

@end
