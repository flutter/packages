// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMarkerUtilities : NSObject

/// Sets MarkerId to GMSMarker UserData.
///
/// @param markerIdentifier Identifier of the marker.
/// @param marker GMSMarker object.
+ (void)setMarkerIdentifier:(NSString *)markerIdentifier for:(GMSMarker*)marker;

/// Sets MarkerId and ClusterManagerId to GMSMarker UserData.
///
/// @param markerIdentifier Identifier of marker.
/// @param clusterManagerIdentifier Identifier of cluster manager.
/// @param marker GMSMarker object.
+ (void)setMarkerIdentifier:(NSString *)markerIdentifier andClusterManagerIdentifier:(NSString *)clusterManagerIdentifier for:(GMSMarker*)marker;

/// Get MarkerIdentifier from GMSMarker UserData.
///
/// @param marker GMSMarker object.
/// @return NSString if found; otherwise, nil.
+ (nullable NSString *)getMarkerIdentifierFrom:(GMSMarker *)marker;

/// Get ClusterManagerIdentifier from GMSMarker UserData.
///
/// @param marker GMSMarker object.
/// @return NSString if found; otherwise, nil.
+ (nullable NSString *)getClusterManagerIdentifierFrom:(GMSMarker *)marker;

@end

NS_ASSUME_NONNULL_END
