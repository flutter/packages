// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapHeatmapController.h"

/// Internal APIs exposed for unit testing
@interface FLTGoogleMapHeatmapController (Test)

/// Updates the underlying GMUHeatmapTileLayer with the properties from the given options.
///
/// Setting the heatmap to visible will set its map to the given mapView.
+ (void)updateHeatmap:(GMUHeatmapTileLayer *)heatmapTileLayer
          fromOptions:(NSDictionary<NSString *, id> *)options
          withMapView:(GMSMapView *)mapView;

@end
