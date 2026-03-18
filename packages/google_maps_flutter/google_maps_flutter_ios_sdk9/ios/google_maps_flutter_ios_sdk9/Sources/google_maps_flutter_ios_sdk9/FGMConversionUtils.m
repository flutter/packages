// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMConversionUtils.h"

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

GMSCollisionBehavior FGMGetCollisionBehaviorForPigeonCollisionBehavior(
    FGMPlatformMarkerCollisionBehavior collisionBehavior) {
  switch (collisionBehavior) {
    case FGMPlatformMarkerCollisionBehaviorRequiredDisplay:
      return GMSCollisionBehaviorRequired;
    case FGMPlatformMarkerCollisionBehaviorOptionalAndHidesLowerPriority:
      return GMSCollisionBehaviorOptionalAndHidesLowerPriority;
    case FGMPlatformMarkerCollisionBehaviorRequiredAndHidesOptional:
      return GMSCollisionBehaviorRequiredAndHidesOptional;
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

GMUGradient *FGMGetGradientForPigeonHeatmapGradient(FGMPlatformHeatmapGradient *gradient) {
  NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:gradient.colors.count];
  for (FGMPlatformColor *color in gradient.colors) {
    [colors addObject:FGMGetColorForPigeonColor(color)];
  }
  return [[GMUGradient alloc] initWithColors:colors
                                 startPoints:gradient.startPoints
                                colorMapSize:gradient.colorMapSize];
}

FGMPlatformHeatmapGradient *FGMGetPigeonHeatmapGradientForGradient(GMUGradient *gradient) {
  NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:gradient.colors.count];
  for (UIColor *color in gradient.colors) {
    [colors addObject:FGMGetPigeonColorForColor(color)];
  }
  return [FGMPlatformHeatmapGradient makeWithColors:colors
                                        startPoints:gradient.startPoints
                                       colorMapSize:gradient.mapSize];
}

NSArray<GMUWeightedLatLng *> *FGMGetWeightedDataForPigeonWeightedData(
    NSArray<FGMPlatformWeightedLatLng *> *weightedLatLngs) {
  NSMutableArray *weightedData = [[NSMutableArray alloc] initWithCapacity:weightedLatLngs.count];
  for (FGMPlatformWeightedLatLng *weightedLatLng in weightedLatLngs) {
    [weightedData
        addObject:[[GMUWeightedLatLng alloc]
                      initWithCoordinate:FGMGetCoordinateForPigeonLatLng(weightedLatLng.point)
                               intensity:weightedLatLng.weight]];
  }
  return weightedData;
}

NSArray<FGMPlatformWeightedLatLng *> *FGMGetPigeonWeightedDataForWeightedData(
    NSArray<GMUWeightedLatLng *> *weightedLatLngs) {
  NSMutableArray *weightedData = [[NSMutableArray alloc] initWithCapacity:weightedLatLngs.count];
  for (GMUWeightedLatLng *weightedLatLng in weightedLatLngs) {
    GMSMapPoint point = {weightedLatLng.point.x, weightedLatLng.point.y};
    [weightedData addObject:[FGMPlatformWeightedLatLng
                                makeWithPoint:FGMGetPigeonLatLngForCoordinate(GMSUnproject(point))
                                       weight:weightedLatLng.intensity]];
  }
  return weightedData;
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

UIColor *FGMGetColorForPigeonColor(FGMPlatformColor *color) {
  return [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:color.alpha];
}

FGMPlatformColor *FGMGetPigeonColorForColor(UIColor *color) {
  double red, green, blue, alpha;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  return [FGMPlatformColor makeWithRed:red green:green blue:blue alpha:alpha];
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
