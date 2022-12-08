// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'fallback_info.dart';
import 'travel_advisory.dart';

/// Encapsulates route information computed for an origin/destination pair in
/// the v2.computeRouteMatrix API.
class RouteMatrixElement {
  /// Creates a RouteMatrixElement.
  const RouteMatrixElement({
    this.status,
    this.condition,
    this.distanceMeters,
    this.duration,
    this.staticDuration,
    this.travelAdvisory,
    this.fallbackInfo,
    this.originIndex,
    this.destinationIndex,
  });

  /// Error status code for this element.
  final Status? status;

  /// Indicates whether the route was found or not. Independent of status.
  final RouteMatrixElementCondition? condition;

  /// The travel distance of the route, in meters.
  final int? distanceMeters;

  /// The length of time needed to navigate the [RouteMatrixElement] while taking
  /// traffic conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? duration;

  /// The duration of traveling through the [RouteMatrixElement] without taking
  /// traffic conditions into consideration.
  ///
  /// A duration in seconds with up to nine fractional digits, ending with 's'.
  final String? staticDuration;

  /// Additional information about the [RouteMatrixElement]. For example:
  /// restriction information and toll information
  final RouteTravelAdvisory? travelAdvisory;

  /// In some cases when the server is not able to compute the route with the
  /// given preferences for this particular origin/destination pair, it may
  /// fall back to using a different mode of computation. When fallback mode
  /// is used, this field contains detailed information about the fallback
  /// response. Otherwise this field is unset.
  final FallbackInfo? fallbackInfo;

  /// Zero-based index of the origin in the request.
  final int? originIndex;

  /// Zero-based index of the destination in the request.
  final int? destinationIndex;

  /// Decodes a JSON object to a [RouteMatrixElement].
  ///
  /// Returns null if [json] is null.
  static RouteMatrixElement? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return RouteMatrixElement(
      status: Status.fromJson(data['status']),
      condition: data['condition'] != null
          ? RouteMatrixElementCondition.values.byName(data['condition'])
          : null,
      distanceMeters: data['distanceMeters'],
      duration: data['duration'],
      staticDuration: data['staticDuration'],
      travelAdvisory: RouteTravelAdvisory.fromJson(data['travelAdvisory']),
      fallbackInfo: FallbackInfo.fromJson(data['fallbackInfo']),
      originIndex: data['originIndex'],
      destinationIndex: data['destinationIndex'],
    );
  }

  /// Returns a JSON representation of the [RouteMatrixElement].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'status': status?.toJson(),
      'condition': condition?.name,
      'distanceMeters': distanceMeters,
      'duration': duration,
      'staticDuration': staticDuration,
      'travelAdvisory': travelAdvisory?.toJson(),
      'fallbackInfo': fallbackInfo?.toJson(),
      'originIndex': originIndex,
      'destinationIndex': destinationIndex,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// The Status type defines a logical error model that is suitable for
/// different programming environments, including REST APIs and RPC APIs.
/// Each Status message contains three pieces of data: error code, error
/// message, and error details.
///
/// You can find out more about this error model and how to work with it in the
/// API Design Guide.
/// https://cloud.google.com/apis/design/errors
class Status {
  /// Creates a [Status] object.
  const Status({this.code, this.message, this.details});

  /// The status code, which should be an enum value of google.rpc.Code.
  final int? code;

  /// A developer-facing error message, which should be in English. Any
  /// user-facing error message should be localized and sent in the
  /// google.rpc.Status.details field, or localized by the client.
  final String? message;

  /// A list of messages that carry the error details. There is a common set of
  /// message types for APIs to use.
  final List<Map<String, dynamic>>? details;

  /// Decodes a JSON object to a [Status].
  ///
  /// Returns null if [json] is null.
  static Status? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return Status(
        code: data['code'], message: data['message'], details: data['details']);
  }

  /// Returns a JSON representation of the [Status].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'code': code,
      'message': message,
      'details': details,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
