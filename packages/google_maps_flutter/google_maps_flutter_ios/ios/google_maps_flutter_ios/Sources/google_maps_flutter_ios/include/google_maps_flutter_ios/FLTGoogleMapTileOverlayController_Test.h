// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapTileOverlayController.h"

/// Internal APIs exposed for unit testing
@interface FLTGoogleMapTileOverlayController (Test)

/// Updates the underlying GMSTileLayer with the properties from the given FGMPlatformTileOverlay.
///
/// Setting the tile overlay to visible will set its map to the given mapView.
+ (void)updateTileLayer:(GMSTileLayer *)tileLayer
    fromPlatformTileOverlay:(FGMPlatformTileOverlay *)platformOverlay
                withMapView:(GMSMapView *)mapView;

@end
