// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapPolylineController ()

@property(strong, nonatomic) GMSPolyline *polyline;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapPolylineController

- (instancetype)initWithPath:(GMSMutablePath *)path
                  identifier:(NSString *)identifier
                     mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _polyline = [GMSPolyline polylineWithPath:path];
    _mapView = mapView;
    _polyline.userData = @[ identifier ];
  }
  return self;
}

- (void)removePolyline {
  self.polyline.map = nil;
}

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.polyline.tappable = consumes;
}
- (void)setVisible:(BOOL)visible {
  self.polyline.map = visible ? self.mapView : nil;
}
- (void)setZIndex:(int)zIndex {
  self.polyline.zIndex = zIndex;
}
- (void)setPoints:(NSArray<CLLocation *> *)points {
  GMSMutablePath *path = [GMSMutablePath path];

  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  self.polyline.path = path;
}

- (void)setColor:(UIColor *)color {
  self.polyline.strokeColor = color;
}
- (void)setStrokeWidth:(CGFloat)width {
  self.polyline.strokeWidth = width;
}

- (void)setGeodesic:(BOOL)isGeodesic {
  self.polyline.geodesic = isGeodesic;
}

- (void)setPattern:(NSArray<GMSStrokeStyle *> *)styles lengths:(NSArray<NSNumber *> *)lengths {
  self.polyline.spans = GMSStyleSpans(self.polyline.path, styles, lengths, kGMSLengthRhumb);
}

- (void)updateFromPlatformPolyline:(FGMPlatformPolyline *)polyline
                         registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self setConsumeTapEvents:polyline.consumesTapEvents];
  [self setVisible:polyline.visible];
  [self setZIndex:(int)polyline.zIndex];
  [self setPoints:FGMGetPointsForPigeonLatLngs(polyline.points)];
  [self setColor:FGMGetColorForRGBA(polyline.color)];
  [self setStrokeWidth:polyline.width];
  [self setGeodesic:polyline.geodesic];
  [self setPattern:FGMGetStrokeStylesFromPatterns(polyline.patterns, self.polyline.strokeColor)
           lengths:FGMGetSpanLengthsFromPatterns(polyline.patterns)];
}

@end

@interface FLTPolylinesController ()

@property(strong, nonatomic) NSMutableDictionary *polylineIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end
;

@implementation FLTPolylinesController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _polylineIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addPolylines:(NSArray<FGMPlatformPolyline *> *)polylinesToAdd {
  for (FGMPlatformPolyline *polyline in polylinesToAdd) {
    GMSMutablePath *path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polyline.points));
    NSString *identifier = polyline.polylineId;
    FLTGoogleMapPolylineController *controller =
        [[FLTGoogleMapPolylineController alloc] initWithPath:path
                                                  identifier:identifier
                                                     mapView:self.mapView];
    [controller updateFromPlatformPolyline:polyline registrar:self.registrar];
    self.polylineIdentifierToController[identifier] = controller;
  }
}

- (void)changePolylines:(NSArray<FGMPlatformPolyline *> *)polylinesToChange {
  for (FGMPlatformPolyline *polyline in polylinesToChange) {
    NSString *identifier = polyline.polylineId;
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    [controller updateFromPlatformPolyline:polyline registrar:self.registrar];
  }
}

- (void)removePolylineWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removePolyline];
    [self.polylineIdentifierToController removeObjectForKey:identifier];
  }
}

- (void)didTapPolylineWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler didTapPolylineWithIdentifier:identifier
                                          completion:^(FlutterError *_Nullable _){
                                          }];
}

- (bool)hasPolylineWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polylineIdentifierToController[identifier] != nil;
}

@end
