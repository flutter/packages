// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMClusterManagersController.h"

#import "FGMMarkerUserData.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FGMClusterManagersController ()

/// A dictionary mapping unique cluster manager identifiers to their corresponding cluster managers.
@property(strong, nonatomic)
    NSMutableDictionary<NSString *, GMUClusterManager *> *clusterManagerIdentifierToManagers;

/// The callback handler interface for calls to Flutter.
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;

/// The current map instance on which the cluster managers are operating.
@property(strong, nonatomic) GMSMapView *mapView;

@end

@implementation FGMClusterManagersController
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _clusterManagerIdentifierToManagers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addClusterManagers:(NSArray<FGMPlatformClusterManager *> *)clusterManagersToAdd {
  for (FGMPlatformClusterManager *clusterManager in clusterManagersToAdd) {
    NSString *identifier = clusterManager.identifier;
    [self addClusterManager:identifier];
  }
}

- (void)addClusterManager:(NSString *)identifier {
  id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
  id<GMUClusterRenderer> renderer =
      [[GMUDefaultClusterRenderer alloc] initWithMapView:self.mapView
                                    clusterIconGenerator:iconGenerator];
  self.clusterManagerIdentifierToManagers[identifier] =
      [[GMUClusterManager alloc] initWithMap:self.mapView algorithm:algorithm renderer:renderer];
  ;
}

- (void)removeClusterManagersWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    GMUClusterManager *clusterManager =
        [self.clusterManagerIdentifierToManagers objectForKey:identifier];
    if (!clusterManager) {
      continue;
    }
    [clusterManager clearItems];
    [self.clusterManagerIdentifierToManagers removeObjectForKey:identifier];
  }
}

- (nullable GMUClusterManager *)clusterManagerWithIdentifier:(NSString *)identifier {
  return [self.clusterManagerIdentifierToManagers objectForKey:identifier];
}

- (void)invokeClusteringForEachClusterManager {
  for (GMUClusterManager *clusterManager in [self.clusterManagerIdentifierToManagers allValues]) {
    [clusterManager cluster];
  }
}

- (nullable NSArray<FGMPlatformCluster *> *)
    clustersWithIdentifier:(NSString *)identifier
                     error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMUClusterManager *clusterManager =
      [self.clusterManagerIdentifierToManagers objectForKey:identifier];

  if (!clusterManager) {
    *error = [FlutterError
        errorWithCode:@"Invalid clusterManagerId"
              message:@"getClusters called with invalid clusterManagerId"
              details:[NSString stringWithFormat:@"clusterManagerId was: '%@'", identifier]];
    return nil;
  }

  // Ref:
  // https://github.com/googlemaps/google-maps-ios-utils/blob/0e7ed81f1bbd9d29e4529c40ae39b0791b0a0eb8/src/Clustering/GMUClusterManager.m#L94.
  NSUInteger integralZoom = (NSUInteger)floorf(_mapView.camera.zoom + 0.5f);
  NSArray<id<GMUCluster>> *clusters = [clusterManager.algorithm clustersAtZoom:integralZoom];
  NSMutableArray<FGMPlatformCluster *> *response =
      [[NSMutableArray alloc] initWithCapacity:clusters.count];
  for (id<GMUCluster> cluster in clusters) {
    FGMPlatformCluster *platFormCluster = FGMGetPigeonCluster(cluster, identifier);
    [response addObject:platFormCluster];
  }
  return response;
}

- (void)didTapCluster:(GMUStaticCluster *)cluster {
  NSString *clusterManagerId = [self clusterManagerIdentifierForCluster:cluster];
  if (!clusterManagerId) {
    return;
  }
  FGMPlatformCluster *platFormCluster = FGMGetPigeonCluster(cluster, clusterManagerId);
  [self.callbackHandler didTapCluster:platFormCluster
                           completion:^(FlutterError *_Nullable _){
                           }];
}

#pragma mark - Private methods

/// Returns the cluster manager identifier for given cluster.
///
/// @return The cluster manager identifier if found; otherwise, nil.
- (nullable NSString *)clusterManagerIdentifierForCluster:(GMUStaticCluster *)cluster {
  if ([cluster.items.firstObject isKindOfClass:[GMSMarker class]]) {
    GMSMarker *firstMarker = (GMSMarker *)cluster.items.firstObject;
    return FGMGetClusterManagerIdentifierFromMarker(firstMarker);
  }

  return nil;
}

@end
