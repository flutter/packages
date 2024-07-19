// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>


@interface GoogleMapMarkerIconCache (Test)
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;
@end

@interface GoogleMapMarkerIconCacheTests : XCTestCase
@end

@implementation GoogleMapMarkerIconCacheTests

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
  FLTGoogleMapController *controller = [[FLTGoogleMapController alloc] initWithMapView:mapView
                                                                        viewIdentifier:0
                                                                             arguments:nil
                                                                             registrar:registrar];

  for (NSInteger i = 0; i < 10; ++i) {
    [controller view];
  }
  XCTAssertEqual(mapView.frameObserverCount, 1);

  mapView.frame = frame;
  XCTAssertEqual(mapView.frameObserverCount, 0);
}

@end

