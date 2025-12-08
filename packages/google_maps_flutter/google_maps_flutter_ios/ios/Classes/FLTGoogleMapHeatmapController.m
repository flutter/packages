// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapHeatmapController.h"
#import "FLTGoogleMapHeatmapController_Test.h"

@import GoogleMapsUtils;

#import "FGMConversionUtils.h"

@interface FLTGoogleMapHeatmapController ()

/// The heatmap tile layer this controller handles.
@property(nonatomic, strong) GMUHeatmapTileLayer *heatmapTileLayer;

/// The GMSMapView to which the heatmaps are added.
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapHeatmapController
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary<NSString *, id> *)options {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;

    [FLTGoogleMapHeatmapController updateHeatmap:_heatmapTileLayer
                                     fromOptions:options
                                     withMapView:_mapView];
  }
  return self;
}

- (void)removeHeatmap {
  _heatmapTileLayer.map = nil;
}

- (void)clearTileCache {
  [_heatmapTileLayer clearTileCache];
}

- (void)interpretHeatmapOptions:(NSDictionary<NSString *, id> *)data {
  [FLTGoogleMapHeatmapController updateHeatmap:_heatmapTileLayer
                                   fromOptions:data
                                   withMapView:_mapView];
}

+ (void)updateHeatmap:(GMUHeatmapTileLayer *)heatmapTileLayer
          fromOptions:(NSDictionary<NSString *, id> *)options
          withMapView:(GMSMapView *)mapView {
  // TODO(stuartmorgan): Migrate this to Pigeon. See
  // https://github.com/flutter/flutter/issues/117907
  id weightedData = options[kHeatmapDataKey];
  if ([weightedData isKindOfClass:[NSArray class]]) {
    heatmapTileLayer.weightedData = [FGMHeatmapConversions weightedDataFromArray:weightedData];
  }

  id gradient = options[kHeatmapGradientKey];
  if ([gradient isKindOfClass:[NSDictionary class]]) {
    heatmapTileLayer.gradient = [FGMHeatmapConversions gradientFromDictionary:gradient];
  }

  id opacity = options[kHeatmapOpacityKey];
  if ([opacity isKindOfClass:[NSNumber class]]) {
    heatmapTileLayer.opacity = [opacity doubleValue];
  }

  id radius = options[kHeatmapRadiusKey];
  if ([radius isKindOfClass:[NSNumber class]]) {
    heatmapTileLayer.radius = [radius intValue];
  }

  id minimumZoomIntensity = options[kHeatmapMinimumZoomIntensityKey];
  if ([minimumZoomIntensity isKindOfClass:[NSNumber class]]) {
    heatmapTileLayer.minimumZoomIntensity = [minimumZoomIntensity intValue];
  }

  id maximumZoomIntensity = options[kHeatmapMaximumZoomIntensityKey];
  if ([maximumZoomIntensity isKindOfClass:[NSNumber class]]) {
    heatmapTileLayer.maximumZoomIntensity = [maximumZoomIntensity intValue];
  }

  // The map must be set each time for options to update.
  // This must be done last, to avoid visual flickers of default property values.
  heatmapTileLayer.map = mapView;
}
@end

@interface FLTHeatmapsController ()

/// A map from heatmapId to the controller that manages it.
@property(nonatomic, strong)
    NSMutableDictionary<NSString *, FLTGoogleMapHeatmapController *> *heatmapIdToController;

/// The map view owned by GoogmeMapController.
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTHeatmapsController
- (instancetype)initWithMapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _mapView = mapView;
    _heatmapIdToController = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)addHeatmaps:(NSArray<FGMPlatformHeatmap *> *)heatmapsToAdd {
  for (FGMPlatformHeatmap *heatmap in heatmapsToAdd) {
    NSString *heatmapId = [FLTHeatmapsController identifierForHeatmap:heatmap.json];
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmapTileLayer:heatmapTileLayer
                                                                mapView:_mapView
                                                                options:heatmap.json];
    _heatmapIdToController[heatmapId] = controller;
  }
}

- (void)changeHeatmaps:(NSArray<FGMPlatformHeatmap *> *)heatmapsToChange {
  for (FGMPlatformHeatmap *heatmap in heatmapsToChange) {
    NSString *heatmapId = [FLTHeatmapsController identifierForHeatmap:heatmap.json];
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmapId];

    [controller interpretHeatmapOptions:heatmap.json];
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

- (BOOL)hasHeatmapWithIdentifier:(NSString *)identifier {
  return _heatmapIdToController[identifier] != nil;
}

- (nullable NSDictionary<NSString *, id> *)heatmapInfoWithIdentifier:(NSString *)identifier {
  FLTGoogleMapHeatmapController *heatmapController = self.heatmapIdToController[identifier];
  if (heatmapController) {
    return @{
      kHeatmapDataKey : [FGMHeatmapConversions
          arrayFromWeightedData:heatmapController.heatmapTileLayer.weightedData],
      kHeatmapGradientKey : [FGMHeatmapConversions
          dictionaryFromGradient:heatmapController.heatmapTileLayer.gradient],
      kHeatmapOpacityKey : @(heatmapController.heatmapTileLayer.opacity),
      kHeatmapRadiusKey : @(heatmapController.heatmapTileLayer.radius),
      kHeatmapMinimumZoomIntensityKey : @(heatmapController.heatmapTileLayer.minimumZoomIntensity),
      kHeatmapMaximumZoomIntensityKey : @(heatmapController.heatmapTileLayer.maximumZoomIntensity)
    };
  }
  return nil;
}

+ (NSString *)identifierForHeatmap:(NSDictionary<NSString *, id> *)heatmap {
  return heatmap[kHeatmapIdKey];
}
@end
