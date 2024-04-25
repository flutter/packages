// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <Flutter/Flutter.h>
#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface FLTClusterManagersControllerTests : XCTestCase
@end

@implementation FLTClusterManagersControllerTests

- (void)testClustering {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  CGRect frame = CGRectMake(0, 0, 100, 100);

  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  NSString *channelName = [NSString stringWithFormat:@"plugins.flutter.dev/google_maps_ios_%d", 0];
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:channelName
                                                              binaryMessenger:registrar.messenger];

  NSString *clusterManagerId = @"cm1";

  FLTClusterManagersController *clusterManagersController =
      [[FLTClusterManagersController alloc] initWithMethodChannel:channel mapView:mapView];
  FLTMarkersController *markersController =
      [[FLTMarkersController alloc] initWithClusterManagersController:clusterManagersController
                                                              channel:channel
                                                              mapView:mapView
                                                            registrar:registrar];

  // Add cluster manager
  NSDictionary *clusterManagerToAdd = @{@"clusterManagerId" : clusterManagerId};
  [clusterManagersController addClusterManagers:@[ clusterManagerToAdd ]];

  // Verify that cluster manager is available
  GMUClusterManager *clusterManager =
      [clusterManagersController clusterManagerWithIdentifier:clusterManagerId];
  XCTAssertNotNil(clusterManager, @"Cluster Manager should not be nil");

  // Add markers
  NSString *markerId1 = @"m1";
  NSString *markerId2 = @"m2";

  NSDictionary *marker1 =
      @{@"markerId" : markerId1, @"position" : @[ @0, @0 ], @"clusterManagerId" : clusterManagerId};
  NSDictionary *marker2 =
      @{@"markerId" : markerId2, @"position" : @[ @0, @0 ], @"clusterManagerId" : clusterManagerId};
  [markersController addMarkers:@[ marker1, marker2 ]];

  // Invoke clustering
  [clusterManagersController invokeClusteringForEachClusterManager];

  // Verify that the markers were added to the cluster manager
  FlutterResult resultObject1 = ^(id _Nullable result) {
    NSArray *clusters = (NSArray *)result;
    for (NSDictionary *cluster in clusters) {
      NSString *cmId = cluster[@"clusterManagerId"];
      XCTAssertNotNil(cmId, @"Cluster Manager Identifier should not be nil");
      if ([cmId isEqualToString:clusterManagerId]) {
        NSArray *markerIds = cluster[@"markerIds"];
        XCTAssertEqual(markerIds.count, 2, @"Cluster should contain two marker");
        XCTAssertTrue([markerIds containsObject:markerId1], @"Cluster should contain markerId1");
        XCTAssertTrue([markerIds containsObject:markerId2], @"Cluster should contain markerId2");
        return;
      }
    }
    // Cluster for clustermanager not found, fail the test
    XCTFail(@"Cluster manager not found");
  };
  [clusterManagersController serializeClustersWithIdentifier:clusterManagerId result:resultObject1];

  [markersController removeMarkersWithIdentifiers:@[ markerId2 ]];

  // Verify that the marker2 is removed from the clusterManager
  FlutterResult resultObject2 = ^(id _Nullable result) {
    NSArray *clusters = (NSArray *)result;
    for (NSDictionary *cluster in clusters) {
      NSString *cmId = cluster[@"clusterManagerId"];
      XCTAssertNotNil(cmId, @"Cluster Manager ID should not be nil");
      if ([cmId isEqualToString:clusterManagerId]) {
        NSArray *markerIds = cluster[@"markerIds"];
        XCTAssertEqual(markerIds.count, 1, @"Cluster should contain one marker");
        XCTAssertTrue([markerIds containsObject:markerId1], @"Cluster should contain markerId1");
        return;
      }
    }
    // Cluster for clustermanager not found, fail the test
    XCTFail(@"Cluster manager not found");
  };
  [clusterManagersController serializeClustersWithIdentifier:clusterManagerId result:resultObject2];

  [markersController removeMarkersWithIdentifiers:@[ markerId1 ]];

  // Verify that all markers are removed from clusterManager
  FlutterResult resultObject3 = ^(id _Nullable result) {
    NSArray *clusters = (NSArray *)result;
    XCTAssertEqual(clusters.count, 0, @"Cluster Manager should not contain any clusters");
  };
  [clusterManagersController serializeClustersWithIdentifier:clusterManagerId result:resultObject3];

  // Remove cluster manager
  [clusterManagersController removeClusterManagersWithIdentifiers:@[ clusterManagerId ]];

  // Verify that the cluster manager is removed
  clusterManager = [clusterManagersController clusterManagerWithIdentifier:clusterManagerId];
  XCTAssertNil(clusterManager, @"Cluster Manager should be nil");
}

@end
