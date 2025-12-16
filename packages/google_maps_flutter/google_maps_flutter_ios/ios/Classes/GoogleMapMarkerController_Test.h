// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"

/// Methods exposed for unit testing.
@interface FLTGoogleMapMarkerController (Test)

/// The underlying controlled GMSMarker.
@property(strong, nonatomic, readonly) GMSMarker *marker;

/// Updates the underlying GMSMarker with the properties from the given FGMPlatformMarker.
///
/// Setting the marker to visible will set its map to the given mapView.
+ (void)updateMarker:(GMSMarker *)marker
           fromPlatformMarker:(FGMPlatformMarker *)platformMarker
                  withMapView:(GMSMapView *)mapView
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                  screenScale:(CGFloat)screenScale
    usingOpacityForVisibility:(BOOL)useOpacityForVisibility;

@end

/// Methods exposed for unit testing.
@interface FLTMarkersController (Test)

/// A mapping from marker identifiers to corresponding marker controllers.
@property(strong, nonatomic, readonly) NSMutableDictionary *markerIdentifierToController;

@end
