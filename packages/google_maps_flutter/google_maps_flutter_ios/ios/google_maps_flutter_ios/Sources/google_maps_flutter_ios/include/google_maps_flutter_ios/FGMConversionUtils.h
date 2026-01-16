// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import Foundation;
@import GoogleMaps;
@import GoogleMapsUtils;

#import "google_maps_flutter_pigeon_messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Returns dict[key], or nil if dict[key] is NSNull.
extern id _Nullable FGMGetValueOrNilFromDict(NSDictionary *dict, NSString *key);

/// Creates a CGPoint from its Pigeon equivalent.
extern CGPoint FGMGetCGPointForPigeonPoint(FGMPlatformPoint *point);

/// Converts a CGPoint to its Pigeon equivalent.
extern FGMPlatformPoint *FGMGetPigeonPointForCGPoint(CGPoint point);

/// Creates a CLLocationCoordinate2D from its Pigeon representation.
extern CLLocationCoordinate2D FGMGetCoordinateForPigeonLatLng(FGMPlatformLatLng *latLng);

/// Converts a CLLocationCoordinate2D to its Pigeon representation.
extern FGMPlatformLatLng *FGMGetPigeonLatLngForCoordinate(CLLocationCoordinate2D coord);

/// Creates a GMSCoordinateBounds from its Pigeon representation.
extern GMSCoordinateBounds *FGMGetCoordinateBoundsForPigeonLatLngBounds(
    FGMPlatformLatLngBounds *bounds);

/// Converts a GMSCoordinateBounds to its Pigeon representation.
extern FGMPlatformLatLngBounds *FGMGetPigeonLatLngBoundsForCoordinateBounds(
    GMSCoordinateBounds *bounds);

/// Converts a GMSCameraPosition to its Pigeon representation.
extern FGMPlatformCameraPosition *FGMGetPigeonCameraPositionForPosition(
    GMSCameraPosition *position);

/// Creates a GMSCameraPosition from its Pigeon representation.
extern GMSCameraPosition *FGMGetCameraPositionForPigeonCameraPosition(
    FGMPlatformCameraPosition *position);

/// Creates a CLLocation array from its Pigeon equivalent.
extern NSArray<CLLocation *> *FGMGetPointsForPigeonLatLngs(NSArray<FGMPlatformLatLng *> *points);

/// Creates a CLLocation arary array, representing a set of holes, from its Pigeon equivalent.
extern NSArray<NSArray<CLLocation *> *> *FGMGetHolesForPigeonLatLngArrays(
    NSArray<NSArray<FGMPlatformLatLng *> *> *points);

extern GMSMutablePath *FGMGetPathFromPoints(NSArray<CLLocation *> *points);

/// Creates a GMSMapViewType from its Pigeon representation.
extern GMSMapViewType FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapType type);

/// Converts a GMUStaticCluster to its Pigeon representation.
extern FGMPlatformCluster *FGMGetPigeonCluster(GMUStaticCluster *cluster,
                                               NSString *clusterManagerIdentifier);

/// Converts a GMSGroundOverlay to its Pigeon representation.
extern FGMPlatformGroundOverlay *FGMGetPigeonGroundOverlay(GMSGroundOverlay *groundOverlay,
                                                           NSString *overlayId,
                                                           BOOL isCreatedWithBounds,
                                                           NSNumber *_Nullable zoomLevel);

extern GMUGradient *FGMGetGradientForPigeonHeatmapGradient(FGMPlatformHeatmapGradient *gradient);

extern FGMPlatformHeatmapGradient *FGMGetPigeonHeatmapGradientForGradient(GMUGradient *gradient);

/// Creates a GMUWeightedLatLng array from its Pigeon equivalent.
extern NSArray<GMUWeightedLatLng *> *FGMGetWeightedDataForPigeonWeightedData(
    NSArray<FGMPlatformWeightedLatLng *> *weightedLatLngs);

/// Converts a GMUWeightedLatLng array to its Pigeon equivalent.
extern NSArray<FGMPlatformWeightedLatLng *> *FGMGetPigeonWeightedDataForWeightedData(
    NSArray<GMUWeightedLatLng *> *weightedLatLngs);

/// Creates a GMSCameraUpdate from its Pigeon equivalent.
extern GMSCameraUpdate *_Nullable FGMGetCameraUpdateForPigeonCameraUpdate(
    FGMPlatformCameraUpdate *update);

/// Creates a UIColor from its Pigeon representation.
extern UIColor *FGMGetColorForPigeonColor(FGMPlatformColor *color);

/// Converts a UIColor to its Pigeon representation.
extern FGMPlatformColor *FGMGetPigeonColorForColor(UIColor *color);

/// Creates an array of GMSStrokeStyles using the given patterns and stroke color.
extern NSArray<GMSStrokeStyle *> *FGMGetStrokeStylesFromPatterns(
    NSArray<FGMPlatformPatternItem *> *patterns, UIColor *strokeColor);

/// Creates an array of span lengths using the given patterns.
extern NSArray<NSNumber *> *FGMGetSpanLengthsFromPatterns(
    NSArray<FGMPlatformPatternItem *> *patterns);

NS_ASSUME_NONNULL_END
