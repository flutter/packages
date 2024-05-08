// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

NS_ASSUME_NONNULL_BEGIN

// Defines heatmap controllable by Flutter.
@interface FLTGoogleMapHeatmapController : NSObject

/**
 Initializes an instance of this class with a heatmap tile layer, a map view, and additional configuration options.

 @param heatmapTileLayer The heatmap tile layer (of type GMUHeatmapTileLayer) that will be used to display heatmap data on the map.
 @param mapView The map view (of type GMSMapView) where the heatmap layer will be overlaid.
 @param options A dictionary (NSDictionary) containing any additional options or configuration settings for customizing the heatmap layer.

 @return An initialized instance of this class, configured with the specified heatmap tile layer, map view, and additional options.
 */
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary<NSString *, id> *)options;

// Removes this heatmap from the map.
- (void)removeHeatmap;

// Clears the tile cache in order to visually udpate this heatmap.
- (void)clearTileCache;

// Reads heatmap data from a dictionary and configures the heatmapTileLayer accordingly.
- (void)interpretHeatmapOptions:(NSDictionary<NSString *, id> *)data;
@end

// Defines an interface for controlling heatmaps from Flutter.
@interface FLTHeatmapsController : NSObject

// Initializes the controller with a GMSMapView.
- (instancetype)initWithMapView:(GMSMapView *)mapView;

// Adds heatmaps to the map.
- (void)addHeatmaps:(NSArray<NSDictionary<NSString *, id> *> *)heatmapsToAdd;

// Updates heatmaps on the map.
- (void)changeHeatmaps:(NSArray<NSDictionary<NSString *, id> *> *)heatmapsToChange;

// Removes heatmaps from the map.
- (void)removeHeatmapsWithIdentifiers:(NSArray<NSString *> *)identifiers;

// Returns true if a heatmap with the given identifier exists on the map.
- (bool)hasHeatmapWithIdentifier:(NSString *)identifier;

// Returns the data of the heatmap with the given identifier.
- (nullable NSDictionary<NSString *, id> *)heatmapInfoWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
