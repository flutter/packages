// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTGoogleMapJSONConversions : NSObject

+ (CLLocationCoordinate2D)locationFromLatLong:(NSArray *)latlong;
+ (CGPoint)pointFromArray:(NSArray *)array;
+ (NSArray *)arrayFromLocation:(CLLocationCoordinate2D)location;
+ (UIColor *)colorFromRGBA:(NSNumber *)data;
+ (NSArray<CLLocation *> *)pointsFromLatLongs:(NSArray *)data;
+ (NSArray<NSArray<CLLocation *> *> *)holesFromPointsArray:(NSArray *)data;
+ (nullable NSDictionary<NSString *, id> *)dictionaryFromPosition:
    (nullable GMSCameraPosition *)position;
+ (NSDictionary<NSString *, NSNumber *> *)dictionaryFromPoint:(CGPoint)point;
+ (nullable NSDictionary *)dictionaryFromCoordinateBounds:(nullable GMSCoordinateBounds *)bounds;
+ (nullable GMSCameraPosition *)cameraPostionFromDictionary:(nullable NSDictionary *)channelValue;
+ (CGPoint)pointFromDictionary:(NSDictionary *)dictionary;
+ (GMSCoordinateBounds *)coordinateBoundsFromLatLongs:(NSArray *)latlongs;
+ (GMSMapViewType)mapViewTypeFromTypeValue:(NSNumber *)value;
+ (nullable GMSCameraUpdate *)cameraUpdateFromChannelValue:(NSArray *)channelValue;

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
