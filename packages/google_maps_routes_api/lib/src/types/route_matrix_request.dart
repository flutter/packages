// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'route_modifiers.dart';
import 'waypoint.dart';

/// Takes in a list of [origins] and [destinations] and returns route
/// information for each combination of origin and destination.
class ComputeRouteMatrixRequest {
  /// Creates a [ComputeRouteMatrixRequest].
  ComputeRouteMatrixRequest({
    required this.origins,
    required this.destinations,
    this.travelMode,
    this.routingPreference,
    this.departureTime,
  });

  /// Array of [origins], which determines the rows of the response matrix.
  /// Several size restrictions apply to the cardinality of [origins] and
  /// [destinations].
  ///
  /// The number of elements ([origins] × [destinations]) must be no greater
  /// than 625 in any case.
  ///
  /// The number of elements ([origins] × [destinations]) must be no greater
  /// than 100 if [routingPreference] is set to
  /// [RoutingPreference.TRAFFIC_AWARE_OPTIMAL].
  ///
  /// The number of [Waypoint] objects ([origins] + [destinations]) specified
  /// as [Waypoint.placeId] must be no greater than 50.
  final List<RouteMatrixOrigin> origins;

  /// Array of destinations, which determines the columns of the response
  /// matrix.
  final List<RouteMatrixDestination> destinations;

  /// Specifies the mode of transportation.
  RouteTravelMode? travelMode;

  /// Specifies how to compute the route. The server attempts to use the
  /// selected routing preference to compute the route. If the routing
  /// preference results in an error or an extra long latency, an error is
  /// returned. In the future, we might implement a fallback mechanism to use a
  /// different option when the preferred option does not give a valid result.
  ///
  /// You can specify this option only when the [travelMode] is
  /// [RouteTravelMode.DRIVE] or [RouteTravelMode.TWO_WHEELER], otherwise the
  /// request fails.
  RoutingPreference? routingPreference;

  /// The departure time. If you don't set this value, this defaults to the
  /// time that you made the request. If you set this value to a time that has
  /// already occurred, the request fails.
  ///
  /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and
  /// up to nine fractional digits.
  String? departureTime;

  /// Returns a JSON representation of the [ComputeRouteMatrixRequest].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'origins':
          origins.map((RouteMatrixOrigin origin) => origin.toJson()).toList(),
      'destinations': destinations
          .map((RouteMatrixDestination destination) => destination.toJson())
          .toList(),
      'travelMode': travelMode?.name,
      'routingPreference': routingPreference?.name,
      'departureTime': departureTime,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// A single origin for [ComputeRouteMatrixRequest].
class RouteMatrixOrigin {
  /// Creates a [RouteMatrixOrigin].
  RouteMatrixOrigin({
    required this.waypoint,
    this.routeModifiers,
  });

  /// Origin [Waypoint].
  final Waypoint waypoint;

  /// Modifiers for every route that takes this as the origin.
  RouteModifiers? routeModifiers;

  /// Returns a JSON representation of the [RouteMatrixOrigin].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'waypoint': waypoint.toJson(),
      'routeModifiers': routeModifiers?.toJson(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// A single destination for [ComputeRouteMatrixRequest].
class RouteMatrixDestination {
  /// Creates a [RouteMatrixDestination].
  RouteMatrixDestination({
    required this.waypoint,
  });

  /// Destination [Waypoint].
  final Waypoint waypoint;

  /// Returns a JSON representation of the [RouteMatrixDestination].
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'waypoint': waypoint.toJson(),
    };
  }
}
