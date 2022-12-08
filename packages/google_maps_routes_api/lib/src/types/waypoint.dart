// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'location.dart';
import 'route.dart';
import 'route_leg.dart';

/// Encapsulates a [Waypoint], which mark both the beginning and end of a
/// [Route], and include intermediate stops along the [Route].
class Waypoint {
  /// Creates a [Waypoint].
  const Waypoint({
    this.via,
    this.vehicleStopover,
    this.sideOfRoad,
    this.location,
    this.placeId,
  });

  /// Marks this [Waypoint] as a milestone rather a stopping point. For each
  /// non-via [Waypoint] in the request, the response appends an entry to the
  /// [Route.legs] array to provide the details for stopovers on that
  /// [RouteLeg] of the trip. Set this value to true when you want the [Route]
  /// to pass through this [Waypoint] without stopping over.
  ///
  /// Via [Waypoint] objects don't cause an entry to be added to the
  /// [Route.legs] array, but they do route the journey through the [Waypoint].
  final bool? via;

  /// Indicates that the [Waypoint] is meant for vehicles to stop at, where the
  /// intention is to either pickup or drop-off. When you set this value,
  /// the calculated [Route] won't include non-via waypoints on roads that are
  /// unsuitable for pickup and drop-off.
  ///
  /// This option works only for [RouteTravelMode.DRIVE] and
  /// [RouteTravelMode.TWO_WHEELER] travel modes
  final bool? vehicleStopover;

  /// Indicates that the [Location] of this [Waypoint] is meant to have a
  /// preference for the vehicle to stop at a particular side of road.
  /// When you set this value, the [Route] will pass through the [Location] so
  /// that the vehicle can stop at the side of road that the [Location]
  /// is biased towards from the center of the road.
  ///
  /// This option works only for [RouteTravelMode.DRIVE] and
  /// [RouteTravelMode.TWO_WHEELER] travel modes
  final bool? sideOfRoad;

  /// A point specified using geographic coordinates, including an optional
  /// [Location.heading]
  final Location? location;

  /// The POI Place ID associated with the [Waypoint].
  final String? placeId;

  /// Returns a JSON representation of the [Waypoint].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'via': via,
      'vehicleStopover': vehicleStopover,
      'sideOfRoad': sideOfRoad,
      'location': location?.toJson(),
      'placeId': placeId,
    };
    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
