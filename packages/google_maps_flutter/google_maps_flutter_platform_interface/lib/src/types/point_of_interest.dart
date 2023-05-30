// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'types.dart';

/// A pair of latitude and longitude coordinates, stored as degrees.
@immutable
class PointOfInterest {
  /// Creates a PointOfInterest
  const PointOfInterest(this.position, this.name, this.placeId);

  /// The LatLng of the POI.
  final LatLng position;

  /// The name of the POI.
  final String? name;

  /// The placeId of the POI.
  final String placeId;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('position', position.toJson());
    addIfPresent('name', name);
    addIfPresent('placeId', placeId);

    return json;
  }

  /// Initialize a LatLng from an \[lat, lng\] array.
  static PointOfInterest? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic> && json.length == 3);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    return PointOfInterest(LatLng.fromJson(data['position'])!,
        data['name'].toString(), data['placeId'].toString());
  }

  @override
  String toString() =>
      'Marker(position: $position, name: $name, placeId: $placeId)';

  @override
  bool operator ==(Object other) {
    return other is PointOfInterest &&
        other.position == position &&
        other.name == name &&
        other.placeId == placeId;
  }

  @override
  int get hashCode => Object.hash(position, name, placeId);
}
