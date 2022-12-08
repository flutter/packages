// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'location.dart';
import 'polyline.dart';
import 'route_leg.dart';
import 'travel_advisory.dart';
import 'waypoint.dart';

/// Encapsulates a [Route], which consists of a series of connected road segments
/// that join beginning, ending, and intermediate [Waypoint] points.
class Route {
  /// Creates a [Route].
  const Route({
    this.routeLabels,
    this.legs,
    this.distanceMeters,
    this.duration,
    this.staticDuration,
    this.polyline,
    this.description,
    this.warnings,
    this.viewport,
    this.travelAdvisory,
    this.routeToken,
  });

  /// Labels for the Route that are useful to identify specific properties of
  /// the route to compare against others.
  final List<RouteLabel>? routeLabels;

  /// A collection of [RouteLeg] objects (path segments between [Waypoint]
  /// points) that make-up the [Route]. [RouteLeg] corresponds to the trip
  /// between two non-via [Waypoint] points.
  final List<RouteLeg>? legs;

  /// The travel distance of the [Route], in meters.
  final int? distanceMeters;

  /// The length of time needed to navigate the [Route] while taking traffic
  /// conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? duration;

  /// The duration of traveling through the [Route] without taking traffic
  /// conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? staticDuration;

  /// The overall route [Polyline]. This will be the combined [Polyline]
  /// of all [RouteLeg] objects.
  final Polyline? polyline;

  /// A description of the route.
  final String? description;

  /// An array of warnings to show when displaying the [Route].
  final List<String>? warnings;

  /// The [Viewport] bounding box of the [Polyline].
  final Viewport? viewport;

  /// Additional information of the [Route].
  final RouteTravelAdvisory? travelAdvisory;

  /// Web-safe base64 encoded [Route] token that can be passed to
  /// NavigationSDK, which allows the Navigation SDK to reconstruct the [Route]
  /// during navigation, and in the event of rerouting honor the original
  /// intention when Routes v2.computeRoutes is called. Customers should treat
  /// this token as an opaque blob.
  final String? routeToken;

  /// Decodes a JSON object to a [Route].
  ///
  /// Returns null if [json] is null.
  static Route? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<RouteLabel>? routeLabels = data['routeLabels'] != null
        ? List<RouteLabel>.from(
            List<String>.from(data['routeLabels']).map(
              (String label) => RouteLabel.values.byName(label),
            ),
          )
        : null;

    final List<RouteLeg>? legs = data['legs'] != null
        ? List<RouteLeg>.from(
            (data['legs'] as List<dynamic>).map(
              (dynamic model) => RouteLeg.fromJson(model),
            ),
          )
        : null;

    return Route(
      routeLabels: routeLabels,
      legs: legs,
      distanceMeters: data['distanceMeters'],
      duration: data['duration'],
      staticDuration: data['staticDuration'],
      polyline:
          data['polyline'] != null ? Polyline.fromJson(data['polyline']) : null,
      description: data['description'],
      warnings: data['warnings'] != null
          ? (data['warnings'] as List<dynamic>).cast<String>()
          : null,
      viewport:
          data['viewport'] != null ? Viewport.fromJson(data['viewport']) : null,
      travelAdvisory: data['travelAdvisory'] == null
          ? null
          : RouteTravelAdvisory.fromJson(data['travelAdvisory']),
      routeToken: data['routeToken'],
    );
  }

  /// Returns a JSON representation of the [Route].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'routeLabels':
          routeLabels?.map((RouteLabel label) => label.name).toList(),
      'legs': legs?.map((RouteLeg leg) => leg.toJson()).toList(),
      'distanceMeters': distanceMeters,
      'duration': duration,
      'staticDuration': staticDuration,
      'polyline': polyline?.toJson(),
      'description': description,
      'warnings': warnings,
      'viewport': viewport?.toJson(),
      'travelAdvisory': travelAdvisory?.toJson(),
      'routeToken': routeToken,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// [Route] objects have a [Viewport] property.
///
/// A latitude-longitude [LatLng] viewport, represented as two diagonally
/// opposite [low] and [high] points. A viewport is considered a
/// closed region, i.e. it includes its boundary.
///
/// The latitude bounds must range between -90 to 90 degrees
///  inclusive, and the longitude bounds must range between
/// -180 to 180 degrees inclusive.
///
/// * If [low] = [high], the viewport consists of that single point.
///
/// * If [low.longitude] > [high.longitude], the longitude range is
///   inverted (the viewport crosses the 180 degree longitude line).
///
/// * If [low.longitude] = -180 degrees and [high.longitude] = 180 degrees,
///   the viewport includes all longitudes.
///
/// * If [low.longitude] = 180 degrees and [high.longitude] = -180 degrees,
///   the longitude range is empty.
///
/// * If [low.latitude] > [high.latitude], the latitude range is empty.
///
/// Both [low] and [high] must be populated, and the represented box cannot
/// be empty (as specified by the definitions above).
class Viewport {
  /// Creates a [Viewport].
  const Viewport({required this.low, required this.high});

  /// The low point of the [Viewport].
  final LatLng low;

  /// The high point of the [Viewport].
  final LatLng high;

  /// Decodes a JSON object to a [Viewport].
  ///
  /// Returns null if [json] is null.
  static Viewport? fromJson(Object? json) {
    if (json == null) {
      return null;
    }

    assert(json is Map<String, dynamic>);

    final Map<String, dynamic> data = json as Map<String, dynamic>;

    assert(data['low'] != null);
    assert(data['high'] != null);

    final LatLng low = LatLng.fromMap(data['low'])!;
    final LatLng high = LatLng.fromMap(data['high'])!;

    assert(low.latitude >= -90 && low.latitude <= 90);
    assert(high.latitude >= -90 && high.latitude <= 90);
    assert(low.longitude >= -180 && low.longitude <= 180);
    assert(high.longitude >= -180 && high.longitude <= 180);

    return Viewport(
      low: low,
      high: high,
    );
  }

  /// Returns a JSON representation of the [Viewport].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'low': low.toMap(),
      'high': high.toMap(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
