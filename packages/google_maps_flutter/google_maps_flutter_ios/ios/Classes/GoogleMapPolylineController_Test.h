// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"

/// Internal APIs exposed for unit testing
@interface FLTGoogleMapPolylineController (Test)

/// Polyline instance the controller is attached to
@property(strong, nonatomic) GMSPolyline *polyline;

/// Updates the controller's polyline with the properties from the given FGMPlatformPolyline.
///
/// Setting the polyline to visible will set its map to the controller's mapView.
- (void)updateFromPlatformPolyline:(FGMPlatformPolyline *)polyline;

/// Updates the underlying GMSPolyline with the properties from the given FGMPlatformPolyline.
///
/// Setting the polyline to visible will set its map to the given mapView.
+ (void)updatePolyline:(GMSPolyline *)polyline
    fromPlatformPolyline:(FGMPlatformPolyline *)platformPolyline
             withMapView:(GMSMapView *)mapView;

@end
