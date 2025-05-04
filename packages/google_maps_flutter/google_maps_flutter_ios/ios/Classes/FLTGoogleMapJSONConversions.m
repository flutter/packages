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

NSArray<CLLocation *> *FGMGetPointsForPigeonLatLngs(NSArray<FGMPlatformLatLng *> *pigeonPoints) {
  NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:pigeonPoints.count];
  for (FGMPlatformLatLng *point in pigeonPoints) {
    [points addObject:[[CLLocation alloc] initWithLatitude:point.latitude
                                                 longitude:point.longitude]];
  }
  return points;
}

NSArray<NSArray<CLLocation *> *> *FGMGetHolesForPigeonLatLngArrays(
    NSArray<NSArray<FGMPlatformLatLng *> *> *pigeonHolePoints) {
  NSMutableArray<NSArray<CLLocation *> *> *holes =
      [[NSMutableArray alloc] initWithCapacity:pigeonHolePoints.count];
  for (NSArray<FGMPlatformLatLng *> *holePoints in pigeonHolePoints) {
    [holes addObject:FGMGetPointsForPigeonLatLngs(holePoints)];
  }
  return holes;
}

GMSMutablePath *FGMGetPathFromPoints(NSArray<CLLocation *> *points) {
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in points) {
    [path addCoordinate:location.coordinate];
  }
  return path;
}

GMSMapViewType FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapType type) {
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

FGMPlatformGroundOverlay *FGMGetPigeonGroundOverlay(GMSGroundOverlay *groundOverlay,
                                                    NSString *overlayId, BOOL isCreatedWithBounds,
                                                    NSNumber *zoomLevel) {
  // Image is mandatory field on FGMPlatformGroundOverlay (and it should be kept
  // non-nullable), therefore image must be set for the object. The image is
  // description either contains set of bytes, or path to asset. This info is
  // converted to format google maps uses (BitmapDescription), and the original
  // data is not stored on native code. Therefore placeholder image is used for
  // the image field.
  FGMPlatformBitmap *placeholderImage =
      [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:0]];
  if (isCreatedWithBounds) {
    return [FGMPlatformGroundOverlay
        makeWithGroundOverlayId:overlayId
                          image:placeholderImage
                       position:nil
                         bounds:[FGMPlatformLatLngBounds
                                    makeWithNortheast:[FGMPlatformLatLng
                                                          makeWithLatitude:groundOverlay.bounds
                                                                               .northEast.latitude
                                                                 longitude:groundOverlay.bounds
                                                                               .northEast.longitude]
                                            southwest:[FGMPlatformLatLng
                                                          makeWithLatitude:groundOverlay.bounds
                                                                               .southWest.latitude
                                                                 longitude:groundOverlay.bounds
                                                                               .southWest
                                                                               .longitude]]
                         anchor:[FGMPlatformPoint makeWithX:groundOverlay.anchor.x
                                                          y:groundOverlay.anchor.y]
                   transparency:1.0f - groundOverlay.opacity
                        bearing:groundOverlay.bearing
                         zIndex:groundOverlay.zIndex
                        visible:groundOverlay.map != nil
                      clickable:groundOverlay.isTappable
                      zoomLevel:zoomLevel];
  } else {
    return [FGMPlatformGroundOverlay
        makeWithGroundOverlayId:overlayId
                          image:placeholderImage
                       position:[FGMPlatformLatLng
                                    makeWithLatitude:groundOverlay.position.latitude
                                           longitude:groundOverlay.position.longitude]
                         bounds:nil
                         anchor:[FGMPlatformPoint makeWithX:groundOverlay.anchor.x
                                                          y:groundOverlay.anchor.y]
                   transparency:1.0f - groundOverlay.opacity
                        bearing:groundOverlay.bearing
                         zIndex:groundOverlay.zIndex
                        visible:groundOverlay.map != nil
                      clickable:groundOverlay.isTappable
                      zoomLevel:zoomLevel];
  }
}

GMSCameraUpdate *FGMGetCameraUpdateForPigeonCameraUpdate(FGMPlatformCameraUpdate *cameraUpdate) {
  // See note in messages.dart for why this is so loosely typed.
  id update = cameraUpdate.cameraUpdate;
  if ([update isKindOfClass:[FGMPlatformCameraUpdateNewCameraPosition class]]) {
    return [GMSCameraUpdate
        setCamera:FGMGetCameraPositionForPigeonCameraPosition(
                      ((FGMPlatformCameraUpdateNewCameraPosition *)update).cameraPosition)];
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateNewLatLng class]]) {
    return [GMSCameraUpdate setTarget:FGMGetCoordinateForPigeonLatLng(
                                          ((FGMPlatformCameraUpdateNewLatLng *)update).latLng)];
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateNewLatLngBounds class]]) {
    FGMPlatformCameraUpdateNewLatLngBounds *typedUpdate =
        (FGMPlatformCameraUpdateNewLatLngBounds *)update;
    return
        [GMSCameraUpdate fitBounds:FGMGetCoordinateBoundsForPigeonLatLngBounds(typedUpdate.bounds)
                       withPadding:typedUpdate.padding];
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateNewLatLngZoom class]]) {
    FGMPlatformCameraUpdateNewLatLngZoom *typedUpdate =
        (FGMPlatformCameraUpdateNewLatLngZoom *)update;
    return [GMSCameraUpdate setTarget:FGMGetCoordinateForPigeonLatLng(typedUpdate.latLng)
                                 zoom:typedUpdate.zoom];
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateScrollBy class]]) {
    FGMPlatformCameraUpdateScrollBy *typedUpdate = (FGMPlatformCameraUpdateScrollBy *)update;
    return [GMSCameraUpdate scrollByX:typedUpdate.dx Y:typedUpdate.dy];
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateZoomBy class]]) {
    FGMPlatformCameraUpdateZoomBy *typedUpdate = (FGMPlatformCameraUpdateZoomBy *)update;
    if (typedUpdate.focus) {
      return [GMSCameraUpdate zoomBy:typedUpdate.amount
                             atPoint:FGMGetCGPointForPigeonPoint(typedUpdate.focus)];
    } else {
      return [GMSCameraUpdate zoomBy:typedUpdate.amount];
    }
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateZoom class]]) {
    if (((FGMPlatformCameraUpdateZoom *)update).out) {
      return [GMSCameraUpdate zoomOut];
    } else {
      return [GMSCameraUpdate zoomIn];
    }
  } else if ([update isKindOfClass:[FGMPlatformCameraUpdateZoomTo class]]) {
    return [GMSCameraUpdate zoomTo:((FGMPlatformCameraUpdateZoomTo *)update).zoom];
  }
  return nil;
}

UIColor *FGMGetColorForRGBA(NSInteger rgba) {
  return [UIColor colorWithRed:((CGFloat)((rgba & 0xFF0000) >> 16)) / 255.0
                         green:((CGFloat)((rgba & 0xFF00) >> 8)) / 255.0
                          blue:((CGFloat)(rgba & 0xFF)) / 255.0
                         alpha:((CGFloat)((rgba & 0xFF000000) >> 24)) / 255.0];
}

NSArray<GMSStrokeStyle *> *FGMGetStrokeStylesFromPatterns(
    NSArray<FGMPlatformPatternItem *> *patterns, UIColor *strokeColor) {
  NSMutableArray *strokeStyles = [[NSMutableArray alloc] initWithCapacity:[patterns count]];
  for (FGMPlatformPatternItem *pattern in patterns) {
    UIColor *color =
        pattern.type == FGMPlatformPatternItemTypeGap ? UIColor.clearColor : strokeColor;
    [strokeStyles addObject:[GMSStrokeStyle solidColor:color]];
  }
  return strokeStyles;
}

NSArray<NSNumber *> *FGMGetSpanLengthsFromPatterns(NSArray<FGMPlatformPatternItem *> *patterns) {
  NSMutableArray *lengths = [[NSMutableArray alloc] initWithCapacity:[patterns count]];
  for (FGMPlatformPatternItem *pattern in patterns) {
    NSNumber *length = pattern.length ?: @0;
    [lengths addObject:length];
  }
  return lengths;
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
  return FGMGetColorForRGBA(numberColor.unsignedLongValue);
}

+ (NSNumber *)RGBAFromColor:(UIColor *)color {
  CGFloat red, green, blue, alpha;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  unsigned long value = ((unsigned long)(alpha * 255) << 24) | ((unsigned long)(red * 255) << 16) |
                        ((unsigned long)(green * 255) << 8) | ((unsigned long)(blue * 255));
  return @(value);
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
