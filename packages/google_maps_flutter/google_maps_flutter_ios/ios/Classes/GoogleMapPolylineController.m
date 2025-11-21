// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "GoogleMapPolylineController_Test.h"

#import "FGMConversionUtils.h"

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

- (void)updateFromPlatformPolyline:(FGMPlatformPolyline *)polyline {
  [FLTGoogleMapPolylineController updatePolyline:self.polyline
                            fromPlatformPolyline:polyline
                                     withMapView:self.mapView];
}

+ (void)updatePolyline:(GMSPolyline *)polyline
    fromPlatformPolyline:(FGMPlatformPolyline *)platformPolyline
             withMapView:(GMSMapView *)mapView {
  polyline.tappable = platformPolyline.consumesTapEvents;
  polyline.zIndex = (int)platformPolyline.zIndex;
  GMSMutablePath *path =
      FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(platformPolyline.points));
  polyline.path = path;
  UIColor *strokeColor = FGMGetColorForPigeonColor(platformPolyline.color);
  polyline.strokeColor = strokeColor;
  polyline.strokeWidth = platformPolyline.width;
  polyline.geodesic = platformPolyline.geodesic;
  polyline.spans =
      GMSStyleSpans(path, FGMGetStrokeStylesFromPatterns(platformPolyline.patterns, strokeColor),
                    FGMGetSpanLengthsFromPatterns(platformPolyline.patterns), kGMSLengthRhumb);

  // This must be done last, to avoid visual flickers of default property values.
  polyline.map = platformPolyline.visible ? mapView : nil;
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
    [controller updateFromPlatformPolyline:polyline];
    self.polylineIdentifierToController[identifier] = controller;
  }
}

- (void)changePolylines:(NSArray<FGMPlatformPolyline *> *)polylinesToChange {
  for (FGMPlatformPolyline *polyline in polylinesToChange) {
    NSString *identifier = polyline.polylineId;
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    [controller updateFromPlatformPolyline:polyline];
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
