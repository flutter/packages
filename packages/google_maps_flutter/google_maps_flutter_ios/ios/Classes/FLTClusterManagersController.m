// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTClusterManagersController.h"

#import "FLTGoogleMapJSONConversions.h"
#import "GoogleMarkerUtilities.h"

@interface FLTClusterManagersController ()

/// A dictionary that cluster managers unique identifiers to GMUClusterManager instances.
@property(strong, nonatomic)
    NSMutableDictionary<NSString *, GMUClusterManager *> *clusterManagerIdentifierToManagers;

/// The method channel that is used to communicate with the Flutter implementation.
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;

/// The current GMSMapView instance on which the cluster managers are operating.
@property(strong, nonatomic) GMSMapView *mapView;

@end

@implementation FLTClusterManagersController
- (instancetype)initWithCallbackHandler:(FGMMapsCallbackApi *)callbackHandler
                                mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _clusterManagerIdentifierToManagers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addJSONClusterManagers:(NSArray<NSDictionary *> *)clusterManagersToAdd {
  for (NSDictionary *clusterDict in clusterManagersToAdd) {
    NSString *identifier = clusterDict[@"clusterManagerId"];
    [self addClusterManager:identifier];
  }
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
  GMUClusterManager *clusterManager = [[GMUClusterManager alloc] initWithMap:self.mapView
                                                                   algorithm:algorithm
                                                                    renderer:renderer];
  self.clusterManagerIdentifierToManagers[identifier] = clusterManager;
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
    getClustersWithIdentifier:(NSString *)identifier
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

  NSMutableArray<FGMPlatformCluster *> *response = [[NSMutableArray alloc] init];

  // Ref:
  // https://github.com/googlemaps/google-maps-ios-utils/blob/0e7ed81f1bbd9d29e4529c40ae39b0791b0a0eb8/src/Clustering/GMUClusterManager.m#L94.
  NSUInteger integralZoom = (NSUInteger)floorf(_mapView.camera.zoom + 0.5f);
  NSArray<id<GMUCluster>> *clusters = [clusterManager.algorithm clustersAtZoom:integralZoom];
  for (id<GMUCluster> cluster in clusters) {
    FGMPlatformCluster *platFormCluster = FGMGetPigeonCluster(cluster, identifier);
    [response addObject:platFormCluster];
  }
  return response;
}

- (void)didTapOnCluster:(GMUStaticCluster *)cluster {
  NSString *clusterManagerId = [self clusterManagerIdentifierForCluster:cluster];
  if (!clusterManagerId) {
    return;
  }
  if (cluster) {
    FGMPlatformCluster *platFormCluster = FGMGetPigeonCluster(cluster, clusterManagerId);
    [self.callbackHandler onClusterTapCluster:platFormCluster
                                   completion:^(FlutterError *_Nullable _){
                                   }];
  }
}

#pragma mark - Private methods

/// Returns the cluster manager id for given cluster.
///
/// @param cluster identifier of the ClusterManager.
/// @return id NSString if found; otherwise, nil.
- (nullable NSString *)clusterManagerIdentifierForCluster:(GMUStaticCluster *)cluster {
  if ([cluster.items count] == 0) {
    return nil;
  }

  if ([cluster.items.firstObject isKindOfClass:[GMSMarker class]]) {
    GMSMarker *firstMarker = (GMSMarker *)cluster.items.firstObject;
    return [GoogleMarkerUtilities getClusterManagerIdentifierFrom:firstMarker];
  }

  return nil;
}

@end
