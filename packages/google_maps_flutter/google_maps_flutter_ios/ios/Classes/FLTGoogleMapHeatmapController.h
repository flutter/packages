// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Controller of a single Heatmap on the map.
@interface FLTGoogleMapHeatmapController : NSObject

/// Initializes an instance of this class with a heatmap tile layer, a map view, and additional
/// configuration options.
///
/// @param heatmapTileLayer The heatmap tile layer (of type GMUHeatmapTileLayer) that will be used
/// to display heatmap data on the map.
/// @param mapView The map view (of type GMSMapView) where the heatmap layer will be overlaid.
/// @param options A dictionary (NSDictionary) containing any additional options or configuration
/// settings for customizing the heatmap layer. The options dictionary is expected to have the
/// following structure:
///
/// @code
/// {
///   "heatmapId": NSString,
///   "data": NSArray, // Array of serialized weighted lat/lng
///   "gradient": NSDictionary?, // Serialized heatmap gradient
///   "opacity": NSNumber,
///   "radius": NSNumber,
///   "minimumZoomIntensity": NSNumber,
///   "maximumZoomIntensity": NSNumber
/// }
/// @endcode
///
/// @return An initialized instance of this class, configured with the specified heatmap tile layer,
/// map view, and additional options.
- (instancetype)initWithHeatmapTileLayer:(GMUHeatmapTileLayer *)heatmapTileLayer
                                 mapView:(GMSMapView *)mapView
                                 options:(NSDictionary<NSString *, id> *)options;

/// Removes this heatmap from the map.
- (void)removeHeatmap;

/// Clears the tile cache in order to visually udpate this heatmap.
- (void)clearTileCache;
@end

/// Controller of multiple Heatmaps on the map.
@interface FLTHeatmapsController : NSObject

/// Initializes the controller with a GMSMapView.
- (instancetype)initWithMapView:(GMSMapView *)mapView;

/// Adds heatmaps to the map.
- (void)addHeatmaps:(NSArray<FGMPlatformHeatmap *> *)heatmapsToAdd;

/// Updates heatmaps on the map.
- (void)changeHeatmaps:(NSArray<FGMPlatformHeatmap *> *)heatmapsToChange;

/// Removes heatmaps from the map.
- (void)removeHeatmapsWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// Returns true if a heatmap with the given identifier exists on the map.
- (BOOL)hasHeatmapWithIdentifier:(NSString *)identifier;

/// Returns the JSON data of the heatmap with the given identifier. The JSON structure is equivalent
/// to the `options` parameter above.
- (nullable NSDictionary<NSString *, id> *)heatmapInfoWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
