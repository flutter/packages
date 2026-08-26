// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Import private _Test.h headers from the plugin framework
#import <google_maps_flutter_ios_objc/FGMCircleController_Test.h>
#import <google_maps_flutter_ios_objc/FGMGroundOverlayController_Test.h>
#import <google_maps_flutter_ios_objc/FGMHeatmapController_Test.h>
#import <google_maps_flutter_ios_objc/FGMMarkerController_Test.h>
#import <google_maps_flutter_ios_objc/FGMPolygonController_Test.h>
#import <google_maps_flutter_ios_objc/FGMPolylineController_Test.h>
#import <google_maps_flutter_ios_objc/FGMTileOverlayController_Test.h>

@interface FGMTileProviderController (Testing)
- (UIImage *)handleResultTile:(nullable UIImage *)tileImage;
@end
