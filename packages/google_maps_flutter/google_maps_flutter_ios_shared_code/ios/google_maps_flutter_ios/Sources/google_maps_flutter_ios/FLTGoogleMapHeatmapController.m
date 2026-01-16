// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_maps_flutter_ios/FLTGoogleMapHeatmapController.h"
#import "./include/google_maps_flutter_ios/FLTGoogleMapHeatmapController_Test.h"

@import GoogleMapsUtils;

#import "./include/google_maps_flutter_ios/FGMConversionUtils.h"

@interface FLTGoogleMapHeatmapController ()

/// The heatmap tile layer this controller handles.
@property(nonatomic, strong) GMUHeatmapTileLayer *heatmapTileLayer;

/// The GMSMapView to which the heatmaps are added.
@property(nonatomic, weak) GMSMapView *mapView;

@end

@implementation FLTGoogleMapHeatmapController
- (instancetype)initWithHeatmap:(FGMPlatformHeatmap *)heatmap
                      tileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                        mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _heatmapTileLayer = heatmapTileLayer;
    _mapView = mapView;

    [FLTGoogleMapHeatmapController updateHeatmap:_heatmapTileLayer
                             fromPlatformHeatmap:heatmap
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

- (void)updateFromPlatformHeatmap:(FGMPlatformHeatmap *)platformHeatmap {
  [FLTGoogleMapHeatmapController updateHeatmap:_heatmapTileLayer
                           fromPlatformHeatmap:platformHeatmap
                                   withMapView:_mapView];
}

+ (void)updateHeatmap:(GMUHeatmapTileLayer *)heatmapTileLayer
    fromPlatformHeatmap:(FGMPlatformHeatmap *)platformHeatmap
            withMapView:(GMSMapView *)mapView {
  heatmapTileLayer.weightedData = FGMGetWeightedDataForPigeonWeightedData(platformHeatmap.data);
  if (platformHeatmap.gradient) {
    heatmapTileLayer.gradient = FGMGetGradientForPigeonHeatmapGradient(platformHeatmap.gradient);
  }
  heatmapTileLayer.opacity = platformHeatmap.opacity;
  heatmapTileLayer.radius = platformHeatmap.radius;
  heatmapTileLayer.minimumZoomIntensity = platformHeatmap.minimumZoomIntensity;
  heatmapTileLayer.maximumZoomIntensity = platformHeatmap.maximumZoomIntensity;

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
    GMUHeatmapTileLayer *heatmapTileLayer = [[GMUHeatmapTileLayer alloc] init];
    FLTGoogleMapHeatmapController *controller =
        [[FLTGoogleMapHeatmapController alloc] initWithHeatmap:heatmap
                                                     tileLayer:heatmapTileLayer
                                                       mapView:_mapView];
    _heatmapIdToController[heatmap.heatmapId] = controller;
  }
}

- (void)changeHeatmaps:(NSArray<FGMPlatformHeatmap *> *)heatmapsToChange {
  for (FGMPlatformHeatmap *heatmap in heatmapsToChange) {
    FLTGoogleMapHeatmapController *controller = _heatmapIdToController[heatmap.heatmapId];

    [controller updateFromPlatformHeatmap:heatmap];
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

- (FGMPlatformHeatmap *)heatmapWithIdentifier:(NSString *)identifier {
  GMUHeatmapTileLayer *heatmap = self.heatmapIdToController[identifier].heatmapTileLayer;
  if (!heatmap) {
    return nil;
  }
  return [FGMPlatformHeatmap
         makeWithHeatmapId:identifier
                      data:FGMGetPigeonWeightedDataForWeightedData(heatmap.weightedData)
                  gradient:FGMGetPigeonHeatmapGradientForGradient(heatmap.gradient)
                   opacity:heatmap.opacity
                    radius:heatmap.radius
      minimumZoomIntensity:heatmap.minimumZoomIntensity
      maximumZoomIntensity:heatmap.maximumZoomIntensity];
}
@end
