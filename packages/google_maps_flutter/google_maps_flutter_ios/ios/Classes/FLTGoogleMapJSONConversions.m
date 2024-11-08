// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapJSONConversions.h"
#import "FGMMarkerUserData.h"

/// Returns dict[key], or nil if dict[key] is NSNull.
id FGMGetValueOrNilFromDict(NSDictionary *dict, NSString *key) {
  id value = dict[key];
  return value == [NSNull null] ? nil : value;
}

CGPoint FGMGetCGPointForPigeonPoint(FGMPlatformPoint *point) {
  return CGPointMake(point.x, point.y);
}

FGMPlatformPoint *FGMGetPigeonPointForCGPoint(CGPoint point) {
  return [FGMPlatformPoint makeWithX:point.x y:point.y];
}

CLLocationCoordinate2D FGMGetCoordinateForPigeonLatLng(FGMPlatformLatLng *latLng) {
  return CLLocationCoordinate2DMake(latLng.latitude, latLng.longitude);
}

FGMPlatformLatLng *FGMGetPigeonLatLngForCoordinate(CLLocationCoordinate2D coord) {
  return [FGMPlatformLatLng makeWithLatitude:coord.latitude longitude:coord.longitude];
}

GMSCoordinateBounds *FGMGetCoordinateBoundsForPigeonLatLngBounds(FGMPlatformLatLngBounds *bounds) {
  return [[GMSCoordinateBounds alloc]
      initWithCoordinate:FGMGetCoordinateForPigeonLatLng(bounds.northeast)
              coordinate:FGMGetCoordinateForPigeonLatLng(bounds.southwest)];
}

FGMPlatformLatLngBounds *FGMGetPigeonLatLngBoundsForCoordinateBounds(GMSCoordinateBounds *bounds) {
  return
      [FGMPlatformLatLngBounds makeWithNortheast:FGMGetPigeonLatLngForCoordinate(bounds.northEast)
                                       southwest:FGMGetPigeonLatLngForCoordinate(bounds.southWest)];
}

FGMPlatformCameraPosition *FGMGetPigeonCameraPositionForPosition(GMSCameraPosition *position) {
  return [FGMPlatformCameraPosition makeWithBearing:position.bearing
                                             target:FGMGetPigeonLatLngForCoordinate(position.target)
                                               tilt:position.viewingAngle
                                               zoom:position.zoom];
}

GMSCameraPosition *FGMGetCameraPositionForPigeonCameraPosition(
    FGMPlatformCameraPosition *position) {
  return [GMSCameraPosition cameraWithTarget:FGMGetCoordinateForPigeonLatLng(position.target)
                                        zoom:position.zoom
                                     bearing:position.bearing
                                viewingAngle:position.tilt];
}

extern GMSMapViewType FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapType type) {
  switch (type) {
    case FGMPlatformMapTypeNone:
      return kGMSTypeNone;
    case FGMPlatformMapTypeNormal:
      return kGMSTypeNormal;
    case FGMPlatformMapTypeSatellite:
      return kGMSTypeSatellite;
    case FGMPlatformMapTypeTerrain:
      return kGMSTypeTerrain;
    case FGMPlatformMapTypeHybrid:
      return kGMSTypeHybrid;
  }
}

FGMPlatformCluster *FGMGetPigeonCluster(GMUStaticCluster *cluster,
                                        NSString *clusterManagerIdentifier) {
  NSMutableArray *markerIDs = [[NSMutableArray alloc] initWithCapacity:cluster.items.count];
  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];

  for (GMSMarker *marker in cluster.items) {
    [markerIDs addObject:FGMGetMarkerIdentifierFromMarker(marker)];
    bounds = [bounds includingCoordinate:marker.position];
  }

  return [FGMPlatformCluster
      makeWithClusterManagerId:clusterManagerIdentifier
                      position:FGMGetPigeonLatLngForCoordinate(cluster.position)
                        bounds:FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
                     markerIds:markerIDs];
}

@implementation FLTGoogleMapJSONConversions

// These constants must match the corresponding constants in serialization.dart
NSString *const kHeatmapsToAddKey = @"heatmapsToAdd";
NSString *const kHeatmapIdKey = @"heatmapId";
NSString *const kHeatmapDataKey = @"data";
NSString *const kHeatmapGradientKey = @"gradient";
NSString *const kHeatmapOpacityKey = @"opacity";
NSString *const kHeatmapRadiusKey = @"radius";
NSString *const kHeatmapMinimumZoomIntensityKey = @"minimumZoomIntensity";
NSString *const kHeatmapMaximumZoomIntensityKey = @"maximumZoomIntensity";
NSString *const kHeatmapGradientColorsKey = @"colors";
NSString *const kHeatmapGradientStartPointsKey = @"startPoints";
NSString *const kHeatmapGradientColorMapSizeKey = @"colorMapSize";

+ (CLLocationCoordinate2D)locationFromLatLong:(NSArray *)latlong {
  return CLLocationCoordinate2DMake([latlong[0] doubleValue], [latlong[1] doubleValue]);
}

+ (CGPoint)pointFromArray:(NSArray *)array {
  return CGPointMake([array[0] doubleValue], [array[1] doubleValue]);
}

+ (NSArray *)arrayFromLocation:(CLLocationCoordinate2D)location {
  return @[ @(location.latitude), @(location.longitude) ];
}

+ (UIColor *)colorFromRGBA:(NSNumber *)numberColor {
  unsigned long value = [numberColor unsignedLongValue];
  return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                         green:((float)((value & 0xFF00) >> 8)) / 255.0
                          blue:((float)(value & 0xFF)) / 255.0
                         alpha:((float)((value & 0xFF000000) >> 24)) / 255.0];
}

+ (NSNumber *)RGBAFromColor:(UIColor *)color {
  CGFloat red, green, blue, alpha;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  unsigned long value = ((unsigned long)(alpha * 255) << 24) | ((unsigned long)(red * 255) << 16) |
                        ((unsigned long)(green * 255) << 8) | ((unsigned long)(blue * 255));
  return @(value);
}

+ (NSArray<CLLocation *> *)pointsFromLatLongs:(NSArray *)data {
  NSMutableArray *points = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber *latitude = data[i][0];
    NSNumber *longitude = data[i][1];
    CLLocation *point = [[CLLocation alloc] initWithLatitude:[latitude doubleValue]
                                                   longitude:[longitude doubleValue]];
    [points addObject:point];
  }

  return points;
}

+ (NSArray<NSArray<CLLocation *> *> *)holesFromPointsArray:(NSArray *)data {
  NSMutableArray<NSArray<CLLocation *> *> *holes = [[[NSMutableArray alloc] init] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSArray<CLLocation *> *points = [FLTGoogleMapJSONConversions pointsFromLatLongs:data[i]];
    [holes addObject:points];
  }

  return holes;
}

+ (nullable GMSCameraPosition *)cameraPostionFromDictionary:(nullable NSDictionary *)data {
  if (!data) {
    return nil;
  }
  return [GMSCameraPosition
      cameraWithTarget:[FLTGoogleMapJSONConversions locationFromLatLong:data[@"target"]]
                  zoom:[data[@"zoom"] floatValue]
               bearing:[data[@"bearing"] doubleValue]
          viewingAngle:[data[@"tilt"] doubleValue]];
}

+ (GMSCoordinateBounds *)coordinateBoundsFromLatLongs:(NSArray *)latlongs {
  return [[GMSCoordinateBounds alloc]
      initWithCoordinate:[FLTGoogleMapJSONConversions locationFromLatLong:latlongs[0]]
              coordinate:[FLTGoogleMapJSONConversions locationFromLatLong:latlongs[1]]];
}

+ (nullable GMSCameraUpdate *)cameraUpdateFromArray:(NSArray *)channelValue {
  NSString *update = channelValue[0];
  if ([update isEqualToString:@"newCameraPosition"]) {
    return [GMSCameraUpdate
        setCamera:[FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue[1]]];
  } else if ([update isEqualToString:@"newLatLng"]) {
    return [GMSCameraUpdate
        setTarget:[FLTGoogleMapJSONConversions locationFromLatLong:channelValue[1]]];
  } else if ([update isEqualToString:@"newLatLngBounds"]) {
    return [GMSCameraUpdate
          fitBounds:[FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:channelValue[1]]
        withPadding:[channelValue[2] doubleValue]];
  } else if ([update isEqualToString:@"newLatLngZoom"]) {
    return
        [GMSCameraUpdate setTarget:[FLTGoogleMapJSONConversions locationFromLatLong:channelValue[1]]
                              zoom:[channelValue[2] floatValue]];
  } else if ([update isEqualToString:@"scrollBy"]) {
    return [GMSCameraUpdate scrollByX:[channelValue[1] doubleValue]
                                    Y:[channelValue[2] doubleValue]];
  } else if ([update isEqualToString:@"zoomBy"]) {
    if (channelValue.count == 2) {
      return [GMSCameraUpdate zoomBy:[channelValue[1] floatValue]];
    } else {
      return [GMSCameraUpdate zoomBy:[channelValue[1] floatValue]
                             atPoint:[FLTGoogleMapJSONConversions pointFromArray:channelValue[2]]];
    }
  } else if ([update isEqualToString:@"zoomIn"]) {
    return [GMSCameraUpdate zoomIn];
  } else if ([update isEqualToString:@"zoomOut"]) {
    return [GMSCameraUpdate zoomOut];
  } else if ([update isEqualToString:@"zoomTo"]) {
    return [GMSCameraUpdate zoomTo:[channelValue[1] floatValue]];
  }
  return nil;
}

+ (NSArray<GMSStrokeStyle *> *)strokeStylesFromPatterns:(NSArray<NSArray<NSObject *> *> *)patterns
                                            strokeColor:(UIColor *)strokeColor {
  NSMutableArray *strokeStyles = [[NSMutableArray alloc] initWithCapacity:[patterns count]];
  for (NSArray *pattern in patterns) {
    NSString *patternType = pattern[0];
    UIColor *color = [patternType isEqualToString:@"gap"] ? [UIColor clearColor] : strokeColor;
    [strokeStyles addObject:[GMSStrokeStyle solidColor:color]];
  }

  return strokeStyles;
}

+ (NSArray<NSNumber *> *)spanLengthsFromPatterns:(NSArray<NSArray<NSObject *> *> *)patterns {
  NSMutableArray *lengths = [[NSMutableArray alloc] initWithCapacity:[patterns count]];
  for (NSArray *pattern in patterns) {
    NSNumber *length = [pattern count] > 1 ? pattern[1] : @0;
    [lengths addObject:length];
  }

  return lengths;
}

+ (GMUWeightedLatLng *)weightedLatLngFromArray:(NSArray<id> *)data {
  NSAssert(data.count == 2, @"WeightedLatLng data must have length of 2");
  if (data.count != 2) {
    return nil;
  }
  return [[GMUWeightedLatLng alloc]
      initWithCoordinate:[FLTGoogleMapJSONConversions locationFromLatLong:data[0]]
               intensity:[data[1] doubleValue]];
}

+ (NSArray<id> *)arrayFromWeightedLatLng:(GMUWeightedLatLng *)weightedLatLng {
  GMSMapPoint point = {weightedLatLng.point.x, weightedLatLng.point.y};
  return @[
    [FLTGoogleMapJSONConversions arrayFromLocation:GMSUnproject(point)], @(weightedLatLng.intensity)
  ];
}

+ (NSArray<GMUWeightedLatLng *> *)weightedDataFromArray:(NSArray<NSArray<id> *> *)data {
  NSMutableArray<GMUWeightedLatLng *> *weightedData =
      [[NSMutableArray alloc] initWithCapacity:data.count];
  for (NSArray<id> *item in data) {
    GMUWeightedLatLng *weightedLatLng = [FLTGoogleMapJSONConversions weightedLatLngFromArray:item];
    if (weightedLatLng == nil) continue;
    [weightedData addObject:weightedLatLng];
  }

  return weightedData;
}

+ (NSArray<NSArray<id> *> *)arrayFromWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData {
  NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:weightedData.count];
  for (GMUWeightedLatLng *weightedLatLng in weightedData) {
    [data addObject:[FLTGoogleMapJSONConversions arrayFromWeightedLatLng:weightedLatLng]];
  }

  return data;
}

+ (GMUGradient *)gradientFromDictionary:(NSDictionary<NSString *, id> *)data {
  NSArray *colorData = data[kHeatmapGradientColorsKey];
  NSMutableArray<UIColor *> *colors = [[NSMutableArray alloc] initWithCapacity:colorData.count];
  for (NSNumber *colorCode in colorData) {
    [colors addObject:[FLTGoogleMapJSONConversions colorFromRGBA:colorCode]];
  }

  return [[GMUGradient alloc] initWithColors:colors
                                 startPoints:data[kHeatmapGradientStartPointsKey]
                                colorMapSize:[data[kHeatmapGradientColorMapSizeKey] intValue]];
}

+ (NSDictionary<NSString *, id> *)dictionaryFromGradient:(GMUGradient *)gradient {
  NSMutableArray<NSNumber *> *colorCodes =
      [[NSMutableArray alloc] initWithCapacity:gradient.colors.count];
  for (UIColor *color in gradient.colors) {
    [colorCodes addObject:[FLTGoogleMapJSONConversions RGBAFromColor:color]];
  }

  return @{
    kHeatmapGradientColorsKey : colorCodes,
    kHeatmapGradientStartPointsKey : gradient.startPoints,
    kHeatmapGradientColorMapSizeKey : @(gradient.mapSize)
  };
}

@end
