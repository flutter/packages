// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import GoogleMaps;
@import google_maps_flutter_ios;

@interface StubTileReceiver : NSObject <GMSTileReceiver>
@end

@implementation StubTileReceiver
- (void)receiveTileWithX:(NSUInteger)x
                       y:(NSUInteger)y
                    zoom:(NSUInteger)zoom
                   image:(nullable UIImage *)image {
  // No-op.
}
@end

@interface TestTileProvider : NSObject <FGMTileProviderDelegate>
@property(nonatomic) XCTestExpectation *expectation;
@end

// A tile provider that expects a single call to
// tileWithOverlayIdentifier:location:zoom:completion: on the main thread,
// and then fulfills the expectation.
@implementation TestTileProvider
- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
  if (self = [super init]) {
    _expectation = expectation;
  }
  return self;
}

- (void)tileWithOverlayIdentifier:(NSString *)tileOverlayId
                         location:(FGMPlatformPoint *)location
                             zoom:(NSInteger)zoom
                       completion:(void (^)(FGMPlatformTile *_Nullable,
                                            FlutterError *_Nullable))completion {
  XCTAssertTrue([[NSThread currentThread] isMainThread]);
  [self.expectation fulfill];
}
@end

#pragma mark -

@interface FLTTileProviderControllerTests : XCTestCase
@end

@implementation FLTTileProviderControllerTests

- (void)testCallChannelOnPlatformThread {
  XCTestExpectation *expectation = [self expectationWithDescription:@"invokeMethod"];
  TestTileProvider *tileProvider = [[TestTileProvider alloc] initWithExpectation:expectation];
  FLTTileProviderController *controller =
      [[FLTTileProviderController alloc] initWithTileOverlayIdentifier:@"foo"
                                                          tileProvider:tileProvider];
  XCTAssertNotNil(controller);
  [controller requestTileForX:0 y:0 zoom:0 receiver:[[StubTileReceiver alloc] init]];
  [self waitForExpectations:@[ expectation ] timeout:10.0];
}

@end
