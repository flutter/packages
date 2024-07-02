// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMap.h"
#import "PartiallyMockedMarker.h"

@interface GoogleMapsObjectTests : XCTestCase
@end

@implementation GoogleMapsObjectTests

- (void)testMarker {
  PartiallyMockedMarker *marker = [[PartiallyMockedMarker alloc]
    markerWithPosition:position:[[CLLocationCoordinate2D alloc] latitude:0 longitude:0]];

  NSString *identifier = @"TestMarker";

  CGRect frame = CGRectMake(0, 0, 100, 100);
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
    initWithFrame:frame
            camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];

  GoogleMapMarkerController *controller = [[GoogleMapMarkerController alloc] initWithMarker:marker identifier:identifier mapView:mapView];
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  [controller interpretMarkerOptions:marker
                            registrar:registrar
                          screenScale:[controller getScreenScale]];

  XCTAssert(marker.isOrderCorrect);
}

@end
