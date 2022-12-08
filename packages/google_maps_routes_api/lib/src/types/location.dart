// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';

// Types copied from https://github.com/flutter/plugins/tree/main/packages/google_maps_flutter/google_maps_flutter_platform_interface

/// Encapsulates a location (a geographic point [LatLng], and an optional [heading]).
class Location {
  /// Creates a [Location].
  const Location({this.latLng, this.heading});

  /// The waypoint's geographic coordinates
  final LatLng? latLng;

  /// The compass heading associated with the direction of the flow of traffic.
  /// This value is used to specify the side of the road to use for pickup and
  /// drop-off. The [heading] values can be from 0 to 360, where 0 specifies a
  /// [heading] of due North, 90 specifies a [heading] of due East, etc.
  /// You can use this field only for [RouteTravelMode.DRIVE] and
  /// [RouteTravelMode.TWO_WHEELER] travel modes.
  final int? heading;

  /// Decodes a JSON object to a [Location].
  ///
  /// Returns null if [json] is null.
  static Location? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> map = json as Map<String, dynamic>;

    return Location(
        latLng: LatLng.fromMap(map['latLng']), heading: map['heading']);
  }

  /// Returns a JSON representation of the [Location].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'latLng': latLng?.toMap(),
      'heading': heading,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive).
  const LatLng(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude),
        // Avoids normalization if possible to prevent unnecessary loss of precision
        longitude = longitude >= -180 && longitude < 180
            ? longitude
            : (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    return <double>[latitude, longitude];
  }

  /// Converts this object to a serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'latitude': latitude, 'longitude': longitude};
  }

  /// Initializes a [LatLng] from a dynamic map.
  static LatLng? fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    return LatLng(map['latitude'], map['longitude']);
  }

  /// Initialize a [LatLng] from an \[lat, lng\] array.
  static LatLng? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is List && json.length == 2);
    final List<Object?> list = json as List<Object?>;
    return LatLng(list[0]! as double, list[1]! as double);
  }

  /// Initialize a [LatLng] from an \[lng, lat\] array.
  static LatLng? fromReversedJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is List && json.length == 2);
    final List<Object?> list = json as List<Object?>;
    return LatLng(list[1]! as double, list[0]! as double);
  }
}
