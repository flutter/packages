// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'route.dart';
import 'route_leg.dart';
import 'toll_info.dart';

/// Encapsulates the additional information that the user should be informed
/// about, such as possible traffic zone restriction etc.
class RouteTravelAdvisory {
  /// Creates a [RouteTravelAdvisory]
  const RouteTravelAdvisory({
    this.tollInfo,
    this.speedReadingIntervals,
    this.fuelConsumptionMicroliters,
  });

  /// Encapsulates information about tolls on the [Route]. This field is only
  /// populated if we expect there are tolls on the [Route]. If this field is
  /// set but the [TollInfo.estimatedPrice] subfield is not populated, we
  /// expect that road contains tolls but we do not know an estimated price.
  /// If this field is not set, then we expect there is no toll on the [Route].
  final TollInfo? tollInfo;

  /// Speed reading intervals detailing traffic density for the [Route].
  /// Applicable in case of [RoutingPreference.TRAFFIC_AWARE] and
  /// [RoutingPreference.TRAFFIC_AWARE_OPTIMAL] routing preferences.
  final List<SpeedReadingInterval>? speedReadingIntervals;

  /// The fuel consumption prediction in microliters.
  final String? fuelConsumptionMicroliters;

  /// Decodes a JSON object to a [RouteTravelAdvisory].
  ///
  /// Returns null if [json] is null.
  static RouteTravelAdvisory? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<SpeedReadingInterval>? speedReadingIntervals =
        data['speedReadingIntervals'] != null
            ? List<SpeedReadingInterval>.from(
                (data['speedReadingIntervals'] as List<dynamic>).map(
                  (dynamic model) => SpeedReadingInterval.fromJson(model),
                ),
              )
            : null;

    return RouteTravelAdvisory(
      tollInfo:
          data['tollInfo'] != null ? TollInfo.fromJson(data['tollInfo']) : null,
      speedReadingIntervals: speedReadingIntervals,
      fuelConsumptionMicroliters: data['fuelConsumptionMicroliters'],
    );
  }

  /// Returns a JSON representation of the [RouteTravelAdvisory].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'tollInfo': tollInfo?.toJson(),
      'speedReadingIntervals': speedReadingIntervals
          ?.map((SpeedReadingInterval interval) => interval.toJson())
          .toList(),
      'fuelConsumptionMicroliters': fuelConsumptionMicroliters,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Encapsulates the additional information that the user should be informed
/// about, such as possible traffic zone restriction etc. on a [RouteLeg].
class RouteLegTravelAdvisory {
  /// Creates a [RouteLegTravelAdvisory].
  const RouteLegTravelAdvisory({this.tollInfo, this.speedReadingIntervals});

  /// Encapsulates information about tolls on the specific [RouteLeg].
  /// This field is only populated if we expect there are tolls on the
  /// [RouteLeg]. If this field is set but the [TollInfo.estimatedPrice]
  /// subfield is not populated, we expect that road contains tolls but we do
  /// not know an estimated price. If this field does not exist, then there is
  /// no toll on the [RouteLeg].
  final TollInfo? tollInfo;

  /// Speed reading intervals detailing traffic density for the [RouteLeg].
  /// Applicable in case of [RoutingPreference.TRAFFIC_AWARE] and
  /// [RoutingPreference.TRAFFIC_AWARE_OPTIMAL] routing preferences.
  final List<SpeedReadingInterval>? speedReadingIntervals;

  /// Decodes a JSON object to a [RouteLegTravelAdvisory].
  ///
  /// Returns null if [json] is null.
  static RouteLegTravelAdvisory? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<SpeedReadingInterval>? speedReadingIntervals =
        data['speedReadingIntervals'] != null
            ? List<SpeedReadingInterval>.from(
                (data['speedReadingIntervals'] as List<dynamic>).map(
                  (dynamic model) => SpeedReadingInterval.fromJson(model),
                ),
              )
            : null;

    return RouteLegTravelAdvisory(
      tollInfo:
          data['tollInfo'] != null ? TollInfo.fromJson(data['tollInfo']) : null,
      speedReadingIntervals: speedReadingIntervals,
    );
  }

  /// Returns a JSON representation of the [RouteLegTravelAdvisory].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'tollInfo': tollInfo?.toJson(),
      'speedReadingIntervals': speedReadingIntervals
          ?.map((SpeedReadingInterval interval) => interval.toJson())
          .toList(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Encapsulates the additional information that the user should be informed
/// about, such as possible traffic zone restriction etc. on a [RouteLegStep].
class RouteLegStepTravelAdvisory {
  /// Creates a [RouteLegStepTravelAdvisory]
  const RouteLegStepTravelAdvisory({required this.speedReadingIntervals});

  /// Speed reading intervals detailing traffic density for the [RouteLegStep].
  /// Applicable in case of [RoutingPreference.TRAFFIC_AWARE] and
  /// [RoutingPreference.TRAFFIC_AWARE_OPTIMAL] routing preferences.
  final List<SpeedReadingInterval> speedReadingIntervals;

  /// Decodes a JSON object to a [RouteLegStepTravelAdvisory].
  ///
  /// Returns null if [json] is null.
  static RouteLegStepTravelAdvisory? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<SpeedReadingInterval> speedReadingIntervals =
        List<SpeedReadingInterval>.from(
      (data['speedReadingIntervals'] as List<dynamic>).map(
        (dynamic model) => SpeedReadingInterval.fromJson(model),
      ),
    );

    return RouteLegStepTravelAdvisory(
      speedReadingIntervals: speedReadingIntervals,
    );
  }

  /// Returns a JSON representation of the [RouteLegStepTravelAdvisory].
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'speedReadingIntervals': speedReadingIntervals
          .map((SpeedReadingInterval interval) => interval.toJson())
          .toList(),
    };
  }
}

/// Traffic density indicator on a contiguous segment of a [Polyline].
/// Given a path with points P_0, P_1, ... , P_N (zero-based index),
/// the [SpeedReadingInterval] defines an interval and describes its traffic.
class SpeedReadingInterval {
  /// Creates a [SpeedReadingInterval].
  const SpeedReadingInterval({
    this.speed,
    this.startPolylinePointIndex,
    this.endPolylinePointIndex,
  });

  /// Traffic speed in this interval.
  final Speed? speed;

  /// The starting index of this interval in the [Polyline].
  final int? startPolylinePointIndex;

  /// The ending index of this interval in the [Polyline].
  final int? endPolylinePointIndex;

  /// Decodes a JSON object to a [SpeedReadingInterval].
  ///
  /// Returns null if [json] is null.
  static SpeedReadingInterval? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return SpeedReadingInterval(
      speed: data['speed'] != null ? Speed.values.byName(data['speed']) : null,
      startPolylinePointIndex: data['startPolylinePointIndex'],
      endPolylinePointIndex: data['endPolylinePointIndex'],
    );
  }

  /// Returns a JSON representation of the [SpeedReadingInterval].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'speed': speed?.name,
      'startPolylinePointIndex': startPolylinePointIndex,
      'endPolylinePointIndex': endPolylinePointIndex,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
