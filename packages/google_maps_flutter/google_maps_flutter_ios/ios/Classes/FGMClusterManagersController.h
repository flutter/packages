// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// A controller that manages all of the cluster managers on a map.
@interface FGMClusterManagersController : NSObject

/// Initializes cluster manager controller.
///
/// @param callbackHandler A callback handler.
/// @param mapView A map view that will be used to display clustered markers.
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler;

/// Creates cluster managers and initializes them form JSON data.
///
/// @param clusterManagersToAdd Array of cluster managers JSON data to add.
- (void)addJSONClusterManagers:(NSArray<NSDictionary *> *)clusterManagersToAdd;

/// Creates cluster managers and initializes them.
///
/// @param clusterManagersToAdd Array of cluster managers to add.
- (void)addClusterManagers:(NSArray<FGMPlatformClusterManager *> *)clusterManagersToAdd;

/// Removes requested cluster managers from the controller.
///
/// @param identifiers Array of cluster manager IDs to remove.
- (void)removeClusterManagersWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// Returns the cluster managers for the given identifier.
///
/// @param identifier The identifier of the cluster manager.
/// @return A cluster manager if found; otherwise, nil.
- (nullable GMUClusterManager *)clusterManagerWithIdentifier:(NSString *)identifier;

/// Returns an array of clusters managed by the cluster manager.
///
/// @param identifier The identifier of the cluster manager whose clusters are to be retrieved.
/// @return An array of clusters. Returns `nil` only if `error` is populated.
- (nullable NSArray<FGMPlatformCluster *> *)
    clustersWithIdentifier:(NSString *)identifier
                     error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error;

/// Called when a cluster marker is tapped on the map.
///
/// @param cluster The cluster that was tapped on.
- (void)didTapCluster:(GMUStaticCluster *)cluster;

/// Calls the cluster method of all the cluster managers.
- (void)invokeClusteringForEachClusterManager;
@end

NS_ASSUME_NONNULL_END
