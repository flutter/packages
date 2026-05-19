// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMGroundOverlayController.h"

/// Internal APIs exposed for unit testing
@interface FGMGroundOverlayController (Test)

/// Ground Overlay instance the controller is attached to
@property(strong, nonatomic) GMSGroundOverlay *groundOverlay;

/// Function to update the gms ground overlay from platform ground overlay.
- (void)updateFromPlatformGroundOverlay:(FGMPlatformGroundOverlay *)groundOverlay
                          assetProvider:(NSObject<FGMAssetProvider> *)assetProvider
                            screenScale:(CGFloat)screenScale;

/// Updates the underlying GMSGroundOverlay with the properties from the given
/// FGMPlatformGroundOverlay.
///
/// Setting the ground overlay to visible will set its map to the given mapView.
+ (void)updateGroundOverlay:(GMSGroundOverlay *)groundOverlay
    fromPlatformGroundOverlay:(FGMPlatformGroundOverlay *)groundOverlay
                  withMapView:(GMSMapView *)mapView
                assetProvider:(NSObject<FGMAssetProvider> *)assetProvider
                  screenScale:(CGFloat)screenScale
                  usingBounds:(BOOL)useBounds;

@end
