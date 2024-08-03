// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

// Defines cluster managers controller interface which
// is responsible for adding/removing/returning one or more cluster managers.
@interface FLTClusterManagersController : NSObject

/// Initializes FLTClusterManagersController.
///
/// @param callbackHandler A callback handler.
/// @param mapView A map view that will be used to display clustered markers.
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler;

/// Creates ClusterManagers and initializes them form JSON data.
///
/// @param clusterManagersToAdd List of clustermanager object data.
- (void)addJSONClusterManagers:(NSArray<NSDictionary *> *)clusterManagersToAdd;

/// Creates ClusterManagers and initializes them.
///
/// @param clusterManagersToAdd List of clustermanager object data.
- (void)addClusterManagers:(NSArray<FGMPlatformClusterManager *> *)clusterManagersToAdd;

/// Removes requested ClusterManagers from the controller.
///
/// @param identifiers List of clusterManagerIds to remove.

- (void)removeClusterManagersWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// Returns the ClusterManager for the given identifier.
///
/// @param identifier identifier of the ClusterManager.
/// @return GMUClusterManager if found; otherwise, nil.
- (nullable GMUClusterManager *)clusterManagerWithIdentifier:(NSString *)identifier;

/// Converts clusters managed by the specified ClusterManager to
/// a serializable array of clusters.
///
/// This method fetches and serializes clusters at the current zoom
/// level from the ClusterManager identified by the given identifier.
/// If the specified ClusterManager identifier does not exist, an empty
/// array is returned.
///
/// @param identifier The identifier of the ClusterManager to serialize.
/// @return An array of FGMPlatformCluster objects representing the clusters. `nil` is returned only
/// when `error != nil`.
- (nullable NSArray<FGMPlatformCluster *> *)
    clustersWithIdentifier:(NSString *)identifier
                     error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error;

/// Called when cluster marker is tapped on the map.
///
/// @param cluster GMUStaticCluster object.
- (void)didTapCluster:(GMUStaticCluster *)cluster;

/// Calls cluster method of all ClusterManagers.
- (void)invokeClusteringForEachClusterManager;
@end

NS_ASSUME_NONNULL_END
