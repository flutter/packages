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

@interface FGMClusterManagersControllerTests : XCTestCase
@end

@implementation FGMClusterManagersControllerTests

- (void)testClustering {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  CGRect frame = CGRectMake(0, 0, 100, 100);

  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  id handler = OCMClassMock([FGMMapsCallbackApi class]);

  FGMClusterManagersController *clusterManagersController =
      [[FGMClusterManagersController alloc] initWithMapView:mapView callbackHandler:handler];

  FLTMarkersController *markersController =
      [[FLTMarkersController alloc] initWithMapView:mapView
                                    callbackHandler:handler
                          clusterManagersController:clusterManagersController
                                          registrar:registrar
                                         markerType:FGMPlatformMarkerTypeMarker];

  // Add cluster managers.
  NSString *clusterManagerId = @"cm";
  FGMPlatformClusterManager *clusterManagerToAdd =
      [FGMPlatformClusterManager makeWithIdentifier:clusterManagerId];
  [clusterManagersController addClusterManagers:@[ clusterManagerToAdd ]];

  // Verify that cluster managers are available
  GMUClusterManager *clusterManager =
      [clusterManagersController clusterManagerWithIdentifier:clusterManagerId];
  XCTAssertNotNil(clusterManager, @"Cluster Manager should not be nil");

  // Add markers
  NSString *markerId1 = @"m1";
  NSString *markerId2 = @"m2";

  FGMPlatformPoint *zeroPoint = [FGMPlatformPoint makeWithX:0 y:0];
  FGMPlatformLatLng *zeroLatLng = [FGMPlatformLatLng makeWithLatitude:0 longitude:0];
  FGMPlatformBitmap *bitmap =
      [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:0]];
  FGMPlatformInfoWindow *infoWindow = [FGMPlatformInfoWindow makeWithTitle:@"Info"
                                                                   snippet:NULL
                                                                    anchor:zeroPoint];
  FGMPlatformMarker *marker1 = [FGMPlatformMarker makeWithAlpha:1
                                                         anchor:zeroPoint
                                               consumeTapEvents:NO
                                                      draggable:NO
                                                           flat:NO
                                                           icon:bitmap
                                                     infoWindow:infoWindow
                                                       position:zeroLatLng
                                                       rotation:0
                                                        visible:YES
                                                         zIndex:1
                                                       markerId:markerId1
                                               clusterManagerId:clusterManagerId];
  FGMPlatformMarker *marker2 = [FGMPlatformMarker makeWithAlpha:1
                                                         anchor:zeroPoint
                                               consumeTapEvents:NO
                                                      draggable:NO
                                                           flat:NO
                                                           icon:bitmap
                                                     infoWindow:infoWindow
                                                       position:zeroLatLng
                                                       rotation:0
                                                        visible:YES
                                                         zIndex:1
                                                       markerId:markerId2
                                               clusterManagerId:clusterManagerId];

  [markersController addMarkers:@[ marker1, marker2 ]];

  FlutterError *error = nil;

  // Invoke clustering
  [clusterManagersController invokeClusteringForEachClusterManager];

  // Verify that the markers were added to the cluster manager
  NSArray<FGMPlatformCluster *> *clusters1 =
      [clusterManagersController clustersWithIdentifier:clusterManagerId error:&error];
  XCTAssertNil(error, @"Error should be nil");
  for (FGMPlatformCluster *cluster in clusters1) {
    NSString *cmId = cluster.clusterManagerId;
    XCTAssertNotNil(cmId, @"Cluster Manager Identifier should not be nil");
    if ([cmId isEqualToString:clusterManagerId]) {
      NSArray *markerIds = cluster.markerIds;
      XCTAssertEqual(markerIds.count, 2, @"Cluster should contain two marker");
      XCTAssertTrue([markerIds containsObject:markerId1], @"Cluster should contain markerId1");
      XCTAssertTrue([markerIds containsObject:markerId2], @"Cluster should contain markerId2");
      return;
    }
  }

  [markersController removeMarkersWithIdentifiers:@[ markerId2 ]];

  // Verify that the marker2 is removed from the clusterManager
  NSArray<FGMPlatformCluster *> *clusters2 =
      [clusterManagersController clustersWithIdentifier:clusterManagerId error:&error];
  XCTAssertNil(error, @"Error should be nil");

  for (FGMPlatformCluster *cluster in clusters2) {
    NSString *cmId = cluster.clusterManagerId;
    XCTAssertNotNil(cmId, @"Cluster Manager ID should not be nil");
    if ([cmId isEqualToString:clusterManagerId]) {
      NSArray *markerIds = cluster.markerIds;
      XCTAssertEqual(markerIds.count, 1, @"Cluster should contain one marker");
      XCTAssertTrue([markerIds containsObject:markerId1], @"Cluster should contain markerId1");
      return;
    }
  }

  [markersController removeMarkersWithIdentifiers:@[ markerId1 ]];

  // Verify that all markers are removed from clusterManager
  NSArray<FGMPlatformCluster *> *clusters3 =
      [clusterManagersController clustersWithIdentifier:clusterManagerId error:&error];
  XCTAssertNil(error, @"Error should be nil");
  XCTAssertEqual(clusters3.count, 0, @"Cluster Manager should not contain any clusters");

  // Remove cluster manager
  [clusterManagersController removeClusterManagersWithIdentifiers:@[ clusterManagerId ]];

  // Verify that the cluster manager is removed
  clusterManager = [clusterManagersController clusterManagerWithIdentifier:clusterManagerId];
  XCTAssertNil(clusterManager, @"Cluster Manager should be nil");
}

@end
