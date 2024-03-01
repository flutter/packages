// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

NS_ASSUME_NONNULL_BEGIN

// Defines cluster managers controller interface which
// is responsible for adding/removing/returning one or more cluster managers.
@interface FLTClusterManagersController : NSObject

/// Initializes FLTClusterManagersController.
///
/// @param methodChannel A Flutter method channel used to send events.
/// @param mapView A map view that will be used to display clustered markers.
- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)methodChannel
                              mapView:(GMSMapView *)mapView;

/// Creates ClusterManagers and initializes them.
///
/// @param clusterManagersToAdd List of clustermanager object data.
- (void)addClusterManagers:(NSArray<NSDictionary *> *)clusterManagersToAdd;

/// Removes requested ClusterManagers from the controller.
///
/// @param identifiers List of clusterManagerIds to remove.

- (void)removeClusterManagersWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// Returns the ClusterManager for the given identifier.
///
/// @param identifier identifier of the ClusterManager.
/// @return GMUClusterManager if found otherwise nil.
- (GMUClusterManager *)clusterManagerWithIdentifier:(NSString *)identifier;

/// Converts all clusters from the specific ClusterManager to result object response
/// and updates that to the provided result object.
///
/// @param identifier identifier of the ClusterManager.
/// @param result FlutterResult object to be updated with cluster data.
- (void)clustersWithIdentifier:(NSString *)identifier result:(FlutterResult)result;

/// Called when cluster marker is tapped on the map.
///
/// @param cluster GMUStaticCluster object.
- (void)didTapOnCluster:(GMUStaticCluster *)cluster;

/// Calls cluster method of all ClusterManagers.
- (void)clusterAll;
@end

NS_ASSUME_NONNULL_END
