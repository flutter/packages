// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

/// Defines user data object for markers.
@interface FGMMarkerUserData : NSObject

/// The identifier of the marker.
@property(nonatomic, copy) NSString *markerIdentifier;

/// The identifier of the cluster manager.
/// This property is set only if the marker is managed by a cluster manager.
@property(nonatomic, copy, nullable) NSString *clusterManagerIdentifier;

@end

/// Sets MarkerId and optionally ClusterManagerId to GMSMarker UserData.
///
/// @param markerIdentifier Identifier of marker.
/// @param clusterManagerIdentifier Optional identifier of cluster manager.
/// @param marker GMSMarker object.
extern void FGMSetIdentifiersToMarkerUserData(NSString *markerIdentifier,
                                              NSString *_Nullable clusterManagerIdentifier,
                                              GMSMarker *marker);

/// Get MarkerIdentifier from GMSMarker UserData.
///
/// @param marker GMSMarker object.
/// @return NSString if found; otherwise, nil.
extern NSString *_Nullable FGMGetMarkerIdentifierFromMarker(GMSMarker *marker);

/// Get ClusterManagerIdentifier from GMSMarker UserData.
///
/// @param marker GMSMarker object.
/// @return NSString if found; otherwise, nil.
extern NSString *_Nullable FGMGetClusterManagerIdentifierFromMarker(GMSMarker *marker);

NS_ASSUME_NONNULL_END
