// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"

@interface FLTGoogleMapMarkerController (Test)

/// Extracts an icon image from the iconData array.
///
/// @param iconData An array containing the data for the icon image.
/// @param iconCache An icon cache that stores the UI images that are unique across all markers.
/// @return A UIImage object created from the icon data.
/// @note Assert unless screenScale is greater than 0.
- (UIImage *)extractIconFromData:(NSArray *)iconData
                       iconCache:(GoogleMapMarkerIconCache *)iconCache;
@end
