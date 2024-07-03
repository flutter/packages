// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapPolylineController ()

@property(strong, nonatomic) GMSPolyline *polyline;
@property(weak, nonatomic) GMSMapView *mapView;

@end

/// Returns dict[key], or nil if dict[key] is NSNull.
static id GetValueOrNilFromDict(NSDictionary *dict, NSString *key) {
  id value = dict[key];
  return value == [NSNull null] ? nil : value;
}

@implementation FLTGoogleMapPolylineController

- (instancetype)initPolylineWithPath:(GMSMutablePath *)path
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

- (void)interpretPolylineOptions:(NSDictionary *)data
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSNumber *consumeTapEvents = GetValueOrNilFromDict(data, @"consumeTapEvents");
  if (consumeTapEvents) {
    [self setConsumeTapEvents:[consumeTapEvents boolValue]];
  }

  NSNumber *visible = GetValueOrNilFromDict(data, @"visible");
  if (visible) {
    [self setVisible:[visible boolValue]];
  }

  NSNumber *zIndex = GetValueOrNilFromDict(data, @"zIndex");
  if (zIndex) {
    [self setZIndex:[zIndex intValue]];
  }

  NSArray *points = GetValueOrNilFromDict(data, @"points");
  if (points) {
    [self setPoints:[FLTGoogleMapJSONConversions pointsFromLatLongs:points]];
  }

  NSNumber *strokeColor = GetValueOrNilFromDict(data, @"color");
  if (strokeColor) {
    [self setColor:[FLTGoogleMapJSONConversions colorFromRGBA:strokeColor]];
  }

  NSNumber *strokeWidth = GetValueOrNilFromDict(data, @"width");
  if (strokeWidth) {
    [self setStrokeWidth:[strokeWidth intValue]];
  }

  NSNumber *geodesic = GetValueOrNilFromDict(data, @"geodesic");
  if (geodesic) {
    [self setGeodesic:geodesic.boolValue];
  }

  NSArray *patterns = GetValueOrNilFromDict(data, @"pattern");
  if (patterns) {
    [self
        setPattern:[FLTGoogleMapJSONConversions strokeStylesFromPatterns:patterns
                                                             strokeColor:self.polyline.strokeColor]
           lengths:[FLTGoogleMapJSONConversions spanLengthsFromPatterns:patterns]];
  }
}

@end

@interface FLTPolylinesController ()

@property(strong, nonatomic) NSMutableDictionary *polylineIdentifierToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end
;

@implementation FLTPolylinesController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _polylineIdentifierToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}
- (void)addPolylines:(NSArray *)polylinesToAdd {
  for (NSDictionary *polyline in polylinesToAdd) {
    GMSMutablePath *path = [FLTPolylinesController pathForPolyline:polyline];
    NSString *identifier = polyline[@"polylineId"];
    FLTGoogleMapPolylineController *controller =
        [[FLTGoogleMapPolylineController alloc] initPolylineWithPath:path
                                                          identifier:identifier
                                                             mapView:self.mapView];
    [controller interpretPolylineOptions:polyline registrar:self.registrar];
    self.polylineIdentifierToController[identifier] = controller;
  }
}
- (void)changePolylines:(NSArray *)polylinesToChange {
  for (NSDictionary *polyline in polylinesToChange) {
    NSString *identifier = polyline[@"polylineId"];
    FLTGoogleMapPolylineController *controller = self.polylineIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller interpretPolylineOptions:polyline registrar:self.registrar];
  }
}
- (void)removePolylineWithIdentifiers:(NSArray *)identifiers {
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
  [self.methodChannel invokeMethod:@"polyline#onTap" arguments:@{@"polylineId" : identifier}];
}
- (bool)hasPolylineWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return false;
  }
  return self.polylineIdentifierToController[identifier] != nil;
}
+ (GMSMutablePath *)pathForPolyline:(NSDictionary *)polyline {
  NSArray *pointArray = polyline[@"points"];
  NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatLongs:pointArray];
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}

@end
