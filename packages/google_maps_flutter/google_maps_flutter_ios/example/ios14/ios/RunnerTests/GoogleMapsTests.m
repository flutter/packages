// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "FGMCATransactionWrapper.h"
#import "PartiallyMockedMapView.h"

@interface FLTGoogleMapFactory (Test)
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;
@end

@interface GoogleMapsTests : XCTestCase
@end

@interface FLTTileProviderController (Testing)
- (UIImage *)handleResultTile:(nullable UIImage *)tileImage;
@end

@implementation GoogleMapsTests

- (void)testPlugin {
  FLTGoogleMapsPlugin *plugin = [[FLTGoogleMapsPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

- (void)testFrameObserver {
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop
  FLTGoogleMapController *controller =
      [[FLTGoogleMapController alloc] initWithMapView:mapView
                                       viewIdentifier:0
                                   creationParameters:[self emptyCreationParameters]
                                            registrar:registrar];

  for (NSInteger i = 0; i < 10; ++i) {
    [controller view];
  }
  XCTAssertEqual(mapView.frameObserverCount, 1);

  mapView.frame = frame;
  XCTAssertEqual(mapView.frameObserverCount, 0);
}

- (void)testMapsServiceSync {
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FLTGoogleMapFactory *factory1 = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  XCTAssertNotNil(factory1.sharedMapServices);
  FLTGoogleMapFactory *factory2 = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  // Test pointer equality, should be same retained singleton +[GMSServices sharedServices] object.
  // Retaining the opaque object should be enough to avoid multiple internal initializations,
  // but don't test the internals of the GoogleMaps API. Assume that it does what is documented.
  // https://developers.google.com/maps/documentation/ios-sdk/reference/interface_g_m_s_services#a436e03c32b1c0be74e072310a7158831
  XCTAssertEqual(factory1.sharedMapServices, factory2.sharedMapServices);
}

- (void)testHandleResultTileDownsamplesWideGamutImages {
  FLTTileProviderController *controller = [[FLTTileProviderController alloc] init];

  NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"widegamut"
                                                                         ofType:@"png"
                                                                    inDirectory:@"assets"];
  UIImage *wideGamutImage = [UIImage imageWithContentsOfFile:imagePath];

  XCTAssertNotNil(wideGamutImage, @"The image should be loaded.");

  UIImage *downsampledImage = [controller handleResultTile:wideGamutImage];

  CGImageRef imageRef = downsampledImage.CGImage;
  size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);

  // non wide gamut images use 8 bit format
  XCTAssertEqual(bitsPerComponent, 8);
  XCTAssertEqual(CGImageGetAlphaInfo(imageRef), kCGImageAlphaPremultipliedLast);
}

- (void)testAnimateCameraWithUpdate {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;

  // Init camera with zero zoom.
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  FLTGoogleMapController *controller =
      [[FLTGoogleMapController alloc] initWithMapView:mapView
                                       viewIdentifier:0
                                   creationParameters:[self emptyCreationParameters]
                                            registrar:registrar];

  id mapViewMock = OCMPartialMock(mapView);
  id mockTransactionWrapper = OCMProtocolMock(@protocol(FGMCATransactionProtocol));
  controller.callHandler.transactionWrapper = mockTransactionWrapper;

  FGMPlatformCameraUpdateZoomTo *zoomTo = [FGMPlatformCameraUpdateZoomTo makeWithZoom:10.0];
  FGMPlatformCameraUpdate *cameraUpdate = [FGMPlatformCameraUpdate makeWithCameraUpdate:zoomTo];
  FlutterError *error = nil;

  OCMReject([mockTransactionWrapper begin]);
  OCMReject([mockTransactionWrapper commit]);
  OCMExpect([mapViewMock animateWithCameraUpdate:[OCMArg any]]);
  [controller.callHandler animateCameraWithUpdate:cameraUpdate duration:nil error:&error];
  OCMVerifyAll(mapViewMock);
  OCMVerifyAll(mockTransactionWrapper);
}

- (void)testAnimateCameraWithUpdateAndDuration {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;

  // Init camera with zero zoom.
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  FLTGoogleMapController *controller =
      [[FLTGoogleMapController alloc] initWithMapView:mapView
                                       viewIdentifier:0
                                   creationParameters:[self emptyCreationParameters]
                                            registrar:registrar];

  id mapViewMock = OCMPartialMock(mapView);
  id mockTransactionWrapper = OCMProtocolMock(@protocol(FGMCATransactionProtocol));
  controller.callHandler.transactionWrapper = mockTransactionWrapper;

  FGMPlatformCameraUpdateZoomTo *zoomTo = [FGMPlatformCameraUpdateZoomTo makeWithZoom:10.0];
  FGMPlatformCameraUpdate *cameraUpdate = [FGMPlatformCameraUpdate makeWithCameraUpdate:zoomTo];
  FlutterError *error = nil;

  NSNumber *durationMilliseconds = @100;
  OCMExpect([mockTransactionWrapper begin]);
  OCMExpect(
      [mockTransactionWrapper setAnimationDuration:[durationMilliseconds doubleValue] / 1000]);
  OCMExpect([mockTransactionWrapper commit]);
  OCMExpect([mapViewMock animateWithCameraUpdate:[OCMArg any]]);
  [controller.callHandler animateCameraWithUpdate:cameraUpdate
                                         duration:durationMilliseconds
                                            error:&error];
  OCMVerifyAll(mapViewMock);
  OCMVerifyAll(mockTransactionWrapper);
}

- (void)testInspectorAPICameraPosition {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;

  // Init camera with specific position.
  GMSCameraPosition *initialCameraPosition = [[GMSCameraPosition alloc] initWithLatitude:37.7749
                                                                               longitude:-122.4194
                                                                                    zoom:10];
  mapViewOptions.camera = initialCameraPosition;

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  FLTGoogleMapController *controller =
      [[FLTGoogleMapController alloc] initWithMapView:mapView
                                       viewIdentifier:0
                                   creationParameters:[self emptyCreationParameters]
                                            registrar:registrar];

  FGMMapInspector *inspector = [[FGMMapInspector alloc] initWithMapController:controller
                                                                    messenger:registrar.messenger
                                                                 pigeonSuffix:@"0"];

  FlutterError *error = nil;
  FGMPlatformCameraPosition *cameraPosition = [inspector cameraPosition:&error];

  XCTAssertEqual(cameraPosition.target.latitude, initialCameraPosition.target.latitude);
  XCTAssertEqual(cameraPosition.target.longitude, initialCameraPosition.target.longitude);
  XCTAssertEqual(cameraPosition.zoom, initialCameraPosition.zoom);
}

/// Creates an empty creation paramaters object for tests where the values don't matter, just that
/// there's a valid object to pass in.
- (FGMPlatformMapViewCreationParams *)emptyCreationParameters {
  return [FGMPlatformMapViewCreationParams
      makeWithInitialCameraPosition:[FGMPlatformCameraPosition
                                        makeWithBearing:0.0
                                                 target:[FGMPlatformLatLng makeWithLatitude:0.0
                                                                                  longitude:0.0]
                                                   tilt:0.0
                                                   zoom:0.0]
                   mapConfiguration:[[FGMPlatformMapConfiguration alloc] init]
                     initialCircles:@[]
                     initialMarkers:@[]
                    initialPolygons:@[]
                   initialPolylines:@[]
                    initialHeatmaps:@[]
                initialTileOverlays:@[]
             initialClusterManagers:@[]
              initialGroundOverlays:@[]];
}

@end
