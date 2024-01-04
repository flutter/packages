@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsPolylinesControllerTests : XCTestCase
@property(strong, atomic) FLTGoogleMapPolylineController *polylineController;
@end

@implementation GoogleMapsPolylinesControllerTests

- (void)setUp {
  NSDictionary *polyline = @{
    @"points" : @[
      @[ @(52.4816), @(-3.1791) ], @[ @(54.043), @(-2.9925) ], @[ @(54.1396), @(-4.2739) ],
      @[ @(53.4153), @(-4.0829) ]
    ],
    @"polylineId" : @"polyline_id_0",

  };

  GMSMutablePath *path = [FLTPolylinesController getPath:polyline];
  NSString *identifier = polyline[@"polylineId"];

  CGRect frame = CGRectMake(0, 0, 100, 100);
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];

  self.polylineController = [[FLTGoogleMapPolylineController alloc] initPolylineWithPath:path
                                                                              identifier:identifier
                                                                                 mapView:mapView];
}

- (void)testSetPatterns {
  NSArray<GMSStrokeStyle *> *styles = @[
    [GMSStrokeStyle solidColor:[UIColor clearColor]], [GMSStrokeStyle solidColor:[UIColor redColor]]
  ];

  NSArray<NSNumber *> *lengths = @[ @10, @10 ];

  XCTAssertNil(self.polylineController.polyline.spans);

  [self.polylineController setPattern:styles lengths:lengths];

  XCTAssertNotNil(self.polylineController.polyline.spans);
}

@end
