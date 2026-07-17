// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Import private _Test.h headers from the plugin framework
#import <google_maps_flutter_ios_sdk10/FGMCircleController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMGoogleMapController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMGroundOverlayController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMHeatmapController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMMarkerController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMPolygonController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMPolylineController_Test.h>
#import <google_maps_flutter_ios_sdk10/FGMTileOverlayController_Test.h>

@interface FGMGoogleMapFactory (Test)
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;
@end

@interface FGMTileProviderController (Testing)
- (UIImage *)handleResultTile:(nullable UIImage *)tileImage;
@end
