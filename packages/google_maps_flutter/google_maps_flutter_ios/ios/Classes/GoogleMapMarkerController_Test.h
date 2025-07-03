// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"

/// Methods exposed for unit testing.
@interface FLTGoogleMapMarkerController (Test)

/// The underlying controlled GMSMarker.
@property(strong, nonatomic, readonly) GMSMarker *marker;

@end

/// Methods exposed for unit testing.
@interface FLTMarkersController (Test)

/// A mapping from marker identifiers to corresponding marker controllers.
@property(strong, nonatomic, readonly) NSMutableDictionary *markerIdentifierToController;

@end
