// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapCircleController.h"

NS_ASSUME_NONNULL_BEGIN

/// Private methods exposed for testing.
@interface FLTGoogleMapCircleController (Test)

/// Updates the underlying GMSCircle with the properties from the given FGMPlatformCircle.
///
/// Setting the circle to visible will set its map to the given mapView.
+ (void)updateCircle:(GMSCircle *)circle
    fromPlatformCircle:(FGMPlatformCircle *)platformCircle
           withMapView:(GMSMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
