// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapHeatmapController.h"
#import "FLTGoogleMapJSONConversions.h"
@import GoogleMapsUtils;

@interface FLTGoogleMapHeatmapController ()

// The heatmap tile layer this controller handles.
@property(nonatomic, strong) GMUHeatmapTileLayer *heatmapTileLayer;

// The map view owned by GoogmeMapController.
@property(nonatomic, weak) GMSMapView *mapView;

@end

// Static wrapper for interpreting heatmap options.
static void InterpretHeatmapOptions(FLTGoogleMapHeatmapController *self, NSDictionary<NSString *, id> *options) {
    [self interpretHeatmapOptions:options];
}

@implementation FLTGoogleMapHeatmapController
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary<NSString *, id> *)options {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;
    InterpretHeatmapOptions(self, options);
  }
  return self;
}

- (void)removeHeatmap {
  _heatmapTileLayer.map = nil;
}

- (void)clearTileCache {
  [_heatmapTileLayer clearTileCache];
}

- (void)setWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData {
  _heatmapTileLayer.weightedData = weightedData;
}

- (void)setGradient:(GMUGradient *)gradient {
  _heatmapTileLayer.gradient = gradient;
}

- (void)setOpacity:(double)opacity {
  _heatmapTileLayer.opacity = opacity;
}

- (void)setRadius:(int)radius {
  _heatmapTileLayer.radius = radius;
}

- (void)setMinimumZoomIntensity:(int)intensity {
  _heatmapTileLayer.minimumZoomIntensity = intensity;
}

- (void)setMaximumZoomIntensity:(int)intensity {
  _heatmapTileLayer.maximumZoomIntensity = intensity;
}

- (void)setMap {
  _heatmapTileLayer.map = _mapView;
}

- (void)interpretHeatmapOptions:(NSDictionary<NSString *, id> *)data {
  id weightedData = data[kHeatmapDataKey];
  if ([weightedData isKindOfClass:[NSArray class]]) {
    [self setWeightedData:[FLTGoogleMapJSONConversions weightedDataFromArray:weightedData]];
  }

  id gradient = data[kHeatmapGradientKey];
  if ([gradient isKindOfClass:[NSDictionary class]]) {
    [self setGradient:[FLTGoogleMapJSONConversions gradientFromDictionary:gradient]];
  }

  id opacity = data[kHeatmapOpacityKey];
  if ([opacity isKindOfClass:[NSNumber class]]) {
    [self setOpacity:[opacity doubleValue]];
  }

  id radius = data[kHeatmapRadiusKey];
  if ([radius isKindOfClass:[NSNumber class]]) {
    [self setRadius:[radius intValue]];
  }

  id minimumZoomIntensity = data[kHeatmapMinimumZoomIntensityKey];
  if ([minimumZoomIntensity isKindOfClass:[NSNumber class]]) {
    [self setMinimumZoomIntensity:[minimumZoomIntensity intValue]];
  }

  id maximumZoomIntensity = data[kHeatmapMaximumZoomIntensityKey];
  if ([maximumZoomIntensity isKindOfClass:[NSNumber class]]) {
    [self setMaximumZoomIntensity:[maximumZoomIntensity intValue]];
  }

  // The map must be set each time for options to update.
  [self setMap];
}
- (NSDictionary<NSString *, id> *)getHeatmapInfo {
  NSMutableDictionary *options = [@{} mutableCopy];
  options[kHeatmapDataKey] =
      [FLTGoogleMapJSONConversions arrayFromWeightedData:_heatmapTileLayer.weightedData];
  options[kHeatmapGradientKey] =
      [FLTGoogleMapJSONConversions dictionaryFromGradient:_heatmapTileLayer.gradient];
  options[kHeatmapOpacityKey] = @(_heatmapTileLayer.opacity);
  options[kHeatmapRadiusKey] = @(_heatmapTileLayer.radius);
  options[kHeatmapMinimumZoomIntensityKey] = @(_heatmapTileLayer.minimumZoomIntensity);
  options[kHeatmapMaximumZoomIntensityKey] = @(_heatmapTileLayer.maximumZoomIntensity);
  return options;
}
@end

@interface FLTHeatmapsController ()

// A map from heatmapId to the controller that manages it.
@property(nonatomic, strong) NSMutableDictionary *heatmapIdToController;

// The map view owned by GoogmeMapController.
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTHeatmapsController
- (instancetype)initWithMapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _mapView = mapView;
    _heatmapIdToController = [@{} mutableCopy];
  }
  return self;
}
- (void)addHeatmaps:(NSArray<NSDictionary<NSString *, id> *> *)heatmapsToAdd {
  for (NSDictionary<NSString *, id> *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapIdentifier:heatmap];
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmapTileLayer:heatmapTileLayer
                                                                mapView:_mapView
                                                                options:heatmap];
    _heatmapIdToController[heatmapId] = controller;
  }
}
- (void)changeHeatmaps:(NSArray<NSDictionary<NSString *, id> *> *)heatmapsToChange {
  for (NSDictionary<NSString *, id> *heatmap in heatmapsToChange) {
    NSString *heatmapId = [FLTHeatmapsController getHeatmapIdentifier:heatmap];
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [controller interpretHeatmapOptions:heatmap];

    [controller clearTileCache];
  }
}
- (void)removeHeatmapsWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *heatmapId in identifiers) {
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];
    if (!controller) {
      continue;
    }
    [controller removeHeatmap];
    [_heatmapIdToController removeObjectForKey:heatmapId];
  }
}
- (bool)hasHeatmapWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return NO;
  }
  return _heatmapIdToController[identifier] != nil;
}
- (nullable NSDictionary<NSString *, id> *)heatmapInfoWithIdentifier:(NSString *)identifier {
  if (self.heatmapIdToController[identifier] == nil) {
    return nil;
  }
  return [self.heatmapIdToController[identifier] getHeatmapInfo];
}
+ (NSString *)getHeatmapIdentifier:(NSDictionary<NSString *, id> *)heatmap {
  return heatmap[kHeatmapIdKey];
}
@end
