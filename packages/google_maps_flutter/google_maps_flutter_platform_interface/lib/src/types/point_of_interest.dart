// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// A point of interest (POI) on the map, such as a park, school, or business.
///
/// This object is returned when a user taps on a POI on the map.
@immutable
class PointOfInterest {
  /// Creates an immutable representation of a point of interest.
  const PointOfInterest({required this.position, required this.placeId});

  /// The geographical location of the POI.
  final LatLng position;

  /// The unique Place ID defined by Google (e.g., "ChIJj61dQgK6j4AR4GeTYWZsKWw").
  final String placeId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PointOfInterest &&
        position == other.position &&
        placeId == other.placeId;
  }

  @override
  int get hashCode => Object.hash(position, placeId);

  @override
  String toString() {
    return 'PointOfInterest{position: $position, placeId: $placeId}';
  }
}
