// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';

/// Information related to how and why a fallback result was used. If this
/// field is set, then it means the server used a different routing mode from
/// your preferred mode as fallback.
class FallbackInfo {
  /// Creates a [FallbackInfo] object.
  const FallbackInfo({this.routingMode, this.reason});

  /// Routing mode used for the response. If fallback was triggered, the mode
  /// may be different from routing preference set in the original client
  /// request.
  final FallbackRoutingMode? routingMode;

  /// The reason why fallback response was used instead of the original
  /// response. This field is only populated when the fallback mode is
  /// triggered and the fallback response is returned.
  final FallbackReason? reason;

  /// Decodes a JSON object to a [FallbackInfo] object.
  ///
  /// Returns null if [json] is null.
  static FallbackInfo? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return FallbackInfo(
      routingMode: data['routingMode'] != null
          ? FallbackRoutingMode.values.byName(data['routingMode'])
          : null,
      reason: data['reason'] != null
          ? FallbackReason.values.byName(
              data['reason'],
            )
          : null,
    );
  }

  /// Returns a JSON representation of the [FallbackInfo].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'routingMode': routingMode?.name,
      'reason': reason?.name,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Actual routing mode used for returned fallback response.
enum FallbackRoutingMode {
  /// Not used.
  FALLBACK_ROUTING_MODE_UNSPECIFIED,

  /// Indicates the [RoutingPreference.TRAFFIC_UNAWARE] routing mode was used
  /// to compute the response.
  FALLBACK_TRAFFIC_UNAWARE,

  /// Indicates the [RoutingPreference.TRAFFIC_AWARE] routing mode was used to
  /// compute the response.
  FALLBACK_TRAFFIC_AWARE,
}

/// Reasons for using fallback response.
enum FallbackReason {
  /// NO fallback reason specified.
  FALLBACK_REASON_UNSPECIFIED,

  /// A server error happened while calculating routes with your preferred
  /// routing mode, but we were able to return a result calculated by an alternative mode.
  SERVER_ERROR,

  /// We were not able to finish the calculation with your preferred routing
  /// mode on time, but we were able to return a result calculated by an
  /// alternative mode.
  LATENCY_EXCEEDED,
}
