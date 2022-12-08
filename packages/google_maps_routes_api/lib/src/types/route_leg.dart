// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'location.dart';
import 'navigation_instruction.dart';
import 'polyline.dart';
import 'routes_request.dart';
import 'travel_advisory.dart';
import 'waypoint.dart';

/// Encapsulates a segment between non-via [Waypoint] objects.
class RouteLeg {
  /// Creates a [RouteLeg].
  const RouteLeg({
    this.distanceMeters,
    this.duration,
    this.staticDuration,
    this.polyline,
    this.startLocation,
    this.endLocation,
    this.steps,
    this.travelAdvisory,
  });

  /// The travel distance of the [RouteLeg], in meters.
  final int? distanceMeters;

  /// The length of time needed to navigate the [RouteLeg] while taking traffic
  /// conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? duration;

  /// The duration of traveling through the [RouteLeg] without taking traffic
  /// conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? staticDuration;

  /// The overall [Polyline] for this [RouteLeg]. This includes the [Polyline]
  /// for each [RouteLegStep].
  final Polyline? polyline;

  /// The start [Location] of this [RouteLeg]. This might be different from the
  /// provided [ComputeRoutesRequest.origin]. For example, when the provided
  /// [ComputeRoutesRequest.origin] is not near a road, this is a point on the
  /// road.
  final Location? startLocation;

  /// The end [Location] of this [RouteLeg]. This might be different from the
  /// provided [ComputeRoutesRequest.destination]. For example, when the provided
  /// [ComputeRoutesRequest.destination] is not near a road, this is a point on
  /// the road.
  final Location? endLocation;

  /// An array of [RouteLegStep] objects denoting segments within this
  /// [RouteLeg]. Each [RouteLegStep] represents one [NavigationInstruction].
  final List<RouteLegStep>? steps;

  /// Encapsulates the additional information that the user should be informed
  /// about, such as possible traffic zone restriction etc. on a [RouteLeg].
  final RouteLegTravelAdvisory? travelAdvisory;

  /// Decodes a JSON object to a [RouteLeg].
  ///
  /// Returns null if [json] is null.
  static RouteLeg? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<RouteLegStep>? steps = data['steps'] != null
        ? List<RouteLegStep>.from(
            (data['steps'] as List<dynamic>).map(
              (dynamic model) => RouteLegStep.fromJson(model),
            ),
          )
        : null;

    return RouteLeg(
      distanceMeters: data['distanceMeters'],
      duration: data['duration'],
      staticDuration: data['staticDuration'],
      polyline:
          data['polyline'] != null ? Polyline.fromJson(data['polyline']) : null,
      startLocation: data['startLocation'] != null
          ? Location.fromJson(data['startLocation'])
          : null,
      endLocation: data['endLocation'] != null
          ? Location.fromJson(data['endLocation'])
          : null,
      steps: steps,
      travelAdvisory: data['travelAdvisory'] != null
          ? RouteLegTravelAdvisory.fromJson(data['travelAdvisory'])
          : null,
    );
  }

  /// Returns a JSON representation of the [RouteLeg].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'distanceMeters': distanceMeters,
      'duration': duration,
      'staticDuration': staticDuration,
      'polyline': polyline?.toJson(),
      'startLocation': startLocation?.toJson(),
      'endLocation': endLocation?.toJson(),
      'steps': steps?.map((RouteLegStep step) => step.toJson()).toList(),
      'travelAdvisory': travelAdvisory?.toJson(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Encapsulates a segment of a [RouteLeg]. A [RouteLegStep] corresponds to a
/// single [NavigationInstruction]. [RouteLeg] objects are made up of
/// [RouteLegStep] objects.
class RouteLegStep {
  /// Creates a [RouteLegStep].
  const RouteLegStep({
    this.distanceMeters,
    this.staticDuration,
    this.polyline,
    this.endLocation,
    this.startLocation,
    this.navigationInstruction,
    this.travelAdvisory,
  });

  /// The travel distance of this [RouteLegStep], in meters.
  /// In some circumstances, this field might not have a value.
  final int? distanceMeters;

  /// The duration of travel through this [RouteLegStep] without taking traffic
  /// conditions into consideration. In some circumstances, this field might
  /// not have a value.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? staticDuration;

  /// The [Polyline] associated with this [RouteLegStep].
  final Polyline? polyline;

  /// The start [Location] of this [RouteLegStep].
  final Location? endLocation;

  /// The end [Location] of this [RouteLegStep].
  final Location? startLocation;

  /// Navigation instructions
  final NavigationInstruction? navigationInstruction;

  /// Encapsulates the additional information that the user should be informed
  /// about, such as possible traffic zone restriction on a [RouteLegStep].
  final RouteLegStepTravelAdvisory? travelAdvisory;

  /// Decodes a JSON object to a [RouteLegStep].
  ///
  /// Returns null if [json] is null.
  static RouteLegStep? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return RouteLegStep(
      distanceMeters: data['distanceMeters'],
      staticDuration: data['staticDuration'],
      polyline:
          data['polyline'] != null ? Polyline.fromJson(data['polyline']) : null,
      startLocation: data['startLocation'] != null
          ? Location.fromJson(data['startLocation'])
          : null,
      endLocation: data['endLocation'] != null
          ? Location.fromJson(data['endLocation'])
          : null,
      navigationInstruction: data['navigationInstruction'] != null
          ? NavigationInstruction.fromJson(data['navigationInstruction'])
          : null,
      travelAdvisory: data['travelAdvisory'] != null
          ? RouteLegStepTravelAdvisory.fromJson(data['travelAdvisory'])
          : null,
    );
  }

  /// Returns a JSON representation of the [RouteLegStep].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'distanceMeters': distanceMeters,
      'staticDuration': staticDuration,
      'polyline': polyline?.toJson(),
      'endLocation': endLocation?.toJson(),
      'startLocation': startLocation?.toJson(),
      'navigationInstruction': navigationInstruction?.toJson(),
      'travelAdvisory': travelAdvisory?.toJson(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
