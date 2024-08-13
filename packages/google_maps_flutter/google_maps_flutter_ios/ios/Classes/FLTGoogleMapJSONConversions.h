// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

#import "messages.g.h"

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

/// Creates a GMSMapViewType from its Pigeon representation.
extern GMSMapViewType FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapType type);

/// Converts a GMUStaticCluster to its Pigeon representation.
extern FGMPlatformCluster *FGMGetPigeonCluster(GMUStaticCluster *cluster,
                                               NSString *clusterManagerIdentifier);

@interface FLTGoogleMapJSONConversions : NSObject

extern NSString *const kHeatmapsToAddKey;
extern NSString *const kHeatmapIdKey;
extern NSString *const kHeatmapDataKey;
extern NSString *const kHeatmapGradientKey;
extern NSString *const kHeatmapOpacityKey;
extern NSString *const kHeatmapRadiusKey;
extern NSString *const kHeatmapMinimumZoomIntensityKey;
extern NSString *const kHeatmapMaximumZoomIntensityKey;
extern NSString *const kHeatmapGradientColorsKey;
extern NSString *const kHeatmapGradientStartPointsKey;
extern NSString *const kHeatmapGradientColorMapSizeKey;

+ (CLLocationCoordinate2D)locationFromLatLong:(NSArray *)latlong;
+ (CGPoint)pointFromArray:(NSArray *)array;
+ (NSArray *)arrayFromLocation:(CLLocationCoordinate2D)location;
+ (UIColor *)colorFromRGBA:(NSNumber *)data;
+ (NSNumber *)RGBAFromColor:(UIColor *)color;
+ (NSArray<CLLocation *> *)pointsFromLatLongs:(NSArray *)data;
+ (NSArray<NSArray<CLLocation *> *> *)holesFromPointsArray:(NSArray *)data;
+ (nullable GMSCameraPosition *)cameraPostionFromDictionary:(nullable NSDictionary *)channelValue;
+ (GMSCoordinateBounds *)coordinateBoundsFromLatLongs:(NSArray *)latlongs;
+ (nullable GMSCameraUpdate *)cameraUpdateFromArray:(NSArray *)channelValue;
+ (nullable GMUWeightedLatLng *)weightedLatLngFromArray:(NSArray<id> *)data;
+ (NSArray<id> *)arrayFromWeightedLatLng:(GMUWeightedLatLng *)weightedLatLng;
+ (NSArray<GMUWeightedLatLng *> *)weightedDataFromArray:(NSArray<NSArray<id> *> *)data;
+ (NSArray<NSArray<id> *> *)arrayFromWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData;
+ (GMUGradient *)gradientFromDictionary:(NSDictionary<NSString *, id> *)data;
+ (NSDictionary<NSString *, id> *)dictionaryFromGradient:(GMUGradient *)gradient;

/// Return GMS strokestyle object array populated using the patterns and stroke colors passed in.
///
/// @param patterns An array of patterns for each stroke in the polyline.
/// @param strokeColor An array of color for each stroke in the polyline.
/// @return An array of GMSStrokeStyle.
+ (NSArray<GMSStrokeStyle *> *)strokeStylesFromPatterns:(NSArray<NSArray<NSObject *> *> *)patterns
                                            strokeColor:(UIColor *)strokeColor;

/// Return GMS strokestyle object array populated using the patterns and stroke colors passed in.
/// Extracts the lengths of each stroke in the polyline from patterns input
///
/// @param patterns An array of object representing the pattern params in the polyline.
/// @return Array of lengths.
+ (NSArray<NSNumber *> *)spanLengthsFromPatterns:(NSArray<NSArray<NSObject *> *> *)patterns;

@end

NS_ASSUME_NONNULL_END
