// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TestUtils/PartiallyMockedMapView.h"
#import "TestUtils/TestAssetProvider.h"
#import "TestUtils/TestMapEventHandler.h"

// Import private _Test.h headers from the plugin framework
#import <google_maps_flutter_ios/FGMCircleController_Test.h>
#import <google_maps_flutter_ios/FGMGoogleMapController_Test.h>
#import <google_maps_flutter_ios/FGMGroundOverlayController_Test.h>
#import <google_maps_flutter_ios/FGMHeatmapController_Test.h>
#import <google_maps_flutter_ios/FGMMarkerController_Test.h>
#import <google_maps_flutter_ios/FGMPolygonController_Test.h>
#import <google_maps_flutter_ios/FGMPolylineController_Test.h>
#import <google_maps_flutter_ios/FGMTileOverlayController_Test.h>

@interface FGMGoogleMapFactory (Test)
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;
@end

@interface FGMTileProviderController (Testing)
- (UIImage *)handleResultTile:(nullable UIImage *)tileImage;
@end
