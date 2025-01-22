// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolylineController.h"

/// Internal APIs exposed for unit testing
@interface FLTGoogleMapPolylineController (Test)

/// Polyline instance the controller is attached to
@property(strong, nonatomic) GMSPolyline *polyline;

@end
