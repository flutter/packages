// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/GoogleMapPolylineController_Test.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsPolylinesControllerTests : XCTestCase
@end

@implementation GoogleMapsPolylinesControllerTests

/// Returns GoogleMapPolylineController object instantiated with a mocked map instance
///
///  @return An object of FLTGoogleMapPolylineController
- (FLTGoogleMapPolylineController *)polylineControllerWithMockedMap {
  NSDictionary<NSString *, id> *polyline = @{
    @"points" : @[
      @[ @(52.4816), @(-3.1791) ], @[ @(54.043), @(-2.9925) ], @[ @(54.1396), @(-4.2739) ],
      @[ @(53.4153), @(-4.0829) ]
    ],
    @"polylineId" : @"polyline_id_0",
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = camera;

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  GMSMutablePath *path = [FLTPolylinesController pathForPolyline:polyline];
  NSString *identifier = polyline[@"polylineId"];

  FLTGoogleMapPolylineController *polylineControllerWithMockedMap =
      [[FLTGoogleMapPolylineController alloc] initPolylineWithPath:path
                                                        identifier:identifier
                                                           mapView:mapView];

  return polylineControllerWithMockedMap;
}

- (void)testSetPatterns {
  NSArray<GMSStrokeStyle *> *styles = @[
    [GMSStrokeStyle solidColor:[UIColor clearColor]], [GMSStrokeStyle solidColor:[UIColor redColor]]
  ];

  NSArray<NSNumber *> *lengths = @[ @10, @10 ];

  FLTGoogleMapPolylineController *polylineController = [self polylineControllerWithMockedMap];

  XCTAssertNil(polylineController.polyline.spans);

  [polylineController setPattern:styles lengths:lengths];

  // `GMSStyleSpan` doesn't implement `isEqual` so cannot be compared by value at present.
  XCTAssertNotNil(polylineController.polyline.spans);
}

- (void)testStrokeStylesFromPatterns {
  NSArray<NSArray<id> *> *patterns = @[ @[ @"gap", @10 ], @[ @"dash", @10 ] ];
  UIColor *strokeColor = [UIColor redColor];

  NSArray<GMSStrokeStyle *> *patternStrokeStyle =
      [FLTGoogleMapJSONConversions strokeStylesFromPatterns:patterns strokeColor:strokeColor];

  XCTAssertEqual([patternStrokeStyle count], 2);

  // None of the parameters of `patternStrokeStyle` is observable, so we limit to testing
  // the length of this output array.
}

@end
