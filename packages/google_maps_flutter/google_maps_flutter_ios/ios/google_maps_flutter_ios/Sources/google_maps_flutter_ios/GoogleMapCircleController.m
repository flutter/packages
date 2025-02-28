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

- (instancetype)initCircleWithPlatformCircle:(FGMPlatformCircle *)circle
                                     mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _circle = [GMSCircle circleWithPosition:FGMGetCoordinateForPigeonLatLng(circle.center)
                                     radius:circle.radius];
    _mapView = mapView;
    _circle.userData = @[ circle.circleId ];
    // TODO(stuartmorgan: Refactor to avoid this call to an instance method in init.
    [self updateFromPlatformCircle:circle];
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

- (void)updateFromPlatformCircle:(FGMPlatformCircle *)platformCircle {
  [self setConsumeTapEvents:platformCircle.consumeTapEvents];
  [self setVisible:platformCircle.visible];
  [self setZIndex:platformCircle.zIndex];
  [self setCenter:FGMGetCoordinateForPigeonLatLng(platformCircle.center)];
  [self setRadius:platformCircle.radius];
  [self setStrokeColor:FGMGetColorForRGBA(platformCircle.strokeColor)];
  [self setStrokeWidth:platformCircle.strokeWidth];
  [self setFillColor:FGMGetColorForRGBA(platformCircle.fillColor)];
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
