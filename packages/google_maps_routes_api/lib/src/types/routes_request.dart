// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'navigation_instruction.dart';
import 'polyline.dart';
import 'route.dart';
import 'route_leg.dart';
import 'route_modifiers.dart';
import 'waypoint.dart';

/// Returns the primary [Route] along with optional alternate routes, given a
/// set of terminal and intermediate [Waypoint] objects.
class ComputeRoutesRequest {
  /// Creates a [ComputeRoutesRequest].
  ComputeRoutesRequest({
    required this.origin,
    required this.destination,
    this.intermediates,
    this.travelMode,
    this.routingPreference,
    this.polylineQuality,
    this.polylineEncoding,
    this.departureTime,
    this.computeAlternativeRoutes,
    this.routeModifiers,
    this.languageCode,
    this.units,
    this.requestedReferenceRoutes,
  });

  /// Origin [Waypoint].
  final Waypoint origin;

  /// Destination [Waypoint].
  final Waypoint destination;

  /// A set of [Waypoint] objects along the [Route] (excluding terminal
  /// points), for either stopping at or passing by. Up to 25
  /// intermediate [Waypoint] objects are supported.
  List<Waypoint>? intermediates;

  /// Specifies the mode of transportation.
  RouteTravelMode? travelMode;

  /// Specifies how to compute the [Route]. The server attempts to use the
  /// selected routing preference to compute the [Route]. If the routing
  /// preference results in an error or an extra long latency, an error is
  /// returned. In the future, we might implement a fallback mechanism to use a
  /// different option when the preferred option does not give a valid result.
  ///
  /// You can specify this option only when the [travelMode] is
  /// [RouteTravelMode.DRIVE] or [RouteTravelMode.TWO_WHEELER], otherwise the
  /// request fails.
  RoutingPreference? routingPreference;

  /// Specifies your preference for the quality of the [Polyline].
  PolylineQuality? polylineQuality;

  /// Specifies the preferred encoding for the [Polyline].
  PolylineEncoding? polylineEncoding;

  /// The departure time. If you don't set this value, then this value
  /// defaults to the time that you made the request. If you set this value to
  /// a time that has already occurred, then the request fails.
  ///
  /// A timestamp in RFC3339 UTC "Zulu" format, with nanosecond resolution and
  /// up to nine fractional digits.
  String? departureTime;

  /// Specifies whether to calculate alternate routes in addition to the route.
  bool? computeAlternativeRoutes;

  /// A set of conditions to satisfy that affect the way routes are calculated.
  RouteModifiers? routeModifiers;

  /// The BCP-47 language code, such as "en-US" or "sr-Latn". For more
  /// information, see
  /// http://www.unicode.org/reports/tr35/#Unicode_locale_identifier.
  ///
  /// When you don't provide this value, the display language is inferred from
  /// the location of the route request.
  String? languageCode;

  /// Specifies the units of measure for the display fields. This includes the
  /// [NavigationInstruction.instructions] field. The units of measure used
  /// for the [Route], [RouteLeg], [RouteLegStep] distance, and duration are
  /// not affected by this value. If you don't provide this value, then the
  /// display units are inferred from the location of the request.
  Units? units;

  /// Specifies what reference routes to calculate as part of the request
  /// in addition to the default route. A reference route is a [Route] with a
  ///  different route calculation objective than the default route.
  ///
  /// For example an [ReferenceRoute.FUEL_EFFICIENT] reference route
  /// calculation takes into account various parameters that would generate an
  /// optimal fuel efficient route.
  ReferenceRoute? requestedReferenceRoutes;

  /// Returns a JSON representation of the [ComputeRoutesRequest].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'intermediates':
          intermediates?.map((Waypoint waypoint) => waypoint.toJson()).toList(),
      'travelMode': travelMode?.name,
      'routingPreference': routingPreference?.name,
      'polylineQuality': polylineQuality?.name,
      'polylineEncoding': polylineEncoding?.name,
      'departureTime': departureTime,
      'computeAlternativeRoutes': computeAlternativeRoutes,
      'routeModifiers': routeModifiers?.toJson(),
      'languageCode': languageCode,
      'units': units?.name,
      'requestedReferenceRoutes': requestedReferenceRoutes?.name
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
