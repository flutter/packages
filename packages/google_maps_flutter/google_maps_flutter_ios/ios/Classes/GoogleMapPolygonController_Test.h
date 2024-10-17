// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapPolygonController.h"

@interface FLTGoogleMapPolygonController (Test)
- (instancetype)initWithPolygon:(GMSPolygon *)polygon
                     identifier:(NSString *)identifier
                        mapView:(GMSMapView *)mapView;
@end
