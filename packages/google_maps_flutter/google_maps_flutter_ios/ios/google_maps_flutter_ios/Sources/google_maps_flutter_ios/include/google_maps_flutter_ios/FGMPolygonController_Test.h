// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMPolygonController.h"

/// Methods exposed for unit testing.
@interface FGMPolygonController (Test)

/// Updates the underlying GMSPolygon with the properties from the given FGMPlatformPolygon.
///
/// Setting the polygon to visible will set its map to the given mapView.
+ (void)updatePolygon:(GMSPolygon *)polygon
    fromPlatformPolygon:(FGMPlatformPolygon *)polygon
            withMapView:(GMSMapView *)mapView;

@end
