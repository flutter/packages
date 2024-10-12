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

/// Associates a marker identifier and optionally a cluster manager identifier with a marker's user
/// data.
extern void FGMSetIdentifiersToMarkerUserData(NSString *markerIdentifier,
                                              NSString *_Nullable clusterManagerIdentifier,
                                              GMSMarker *marker);

/// Get the marker identifier from marker's user data.
///
/// @return The marker identifier if found; otherwise, nil.
extern NSString *_Nullable FGMGetMarkerIdentifierFromMarker(GMSMarker *marker);

/// Get the cluster manager identifier from marker's user data.
///
/// @return The cluster manager identifier if found; otherwise, nil.
extern NSString *_Nullable FGMGetClusterManagerIdentifierFromMarker(GMSMarker *marker);

NS_ASSUME_NONNULL_END
