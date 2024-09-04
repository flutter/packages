// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"

/// Internal APIs exposed for unit testing
@interface FLTGoogleMapPolylineController (Test)

/// Polyline instance the controller is attached to
@property(strong, nonatomic) GMSPolyline *polyline;

@end

/// Internal APIs explosed for unit testing
@interface FLTPolylinesController (Test)

/// Returns the path for polyline based on the points(locations) the polyline has.
///
/// @param polyline The polyline instance for which path is calculated.
/// @return An instance of GMSMutablePath.
+ (GMSMutablePath *)pathForPolyline:(NSDictionary *)polyline;

@end
