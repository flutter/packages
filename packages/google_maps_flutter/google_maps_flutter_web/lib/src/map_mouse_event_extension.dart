// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library;

import 'dart:js_interop';

import 'package:google_maps/google_maps.dart' as gmaps;

/// Exposes the `placeId` property on map click events.
///
/// [gmaps.MapMouseEventOrIconMouseEvent] only binds `latLng` upstream. POI
/// clicks are [gmaps.IconMouseEvent]s and carry a `placeId`; this extension
/// reads that property without `dart:js_interop_unsafe`. Prefer adding
/// `placeId` to the upstream binding when possible.
extension PlaceIdExtension on gmaps.MapMouseEventOrIconMouseEvent {
  /// The place ID of a tapped point of interest, if this event is an icon
  /// mouse event. Otherwise `null`.
  external String? placeId;
}
