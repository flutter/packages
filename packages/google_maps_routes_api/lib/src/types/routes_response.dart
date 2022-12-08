// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'fallback_info.dart';
import 'route.dart';
import 'routes_request.dart';

/// v2.computeRoutes response message.
class ComputeRoutesResponse {
  /// Creates a [ComputeRoutesResponse] object.
  const ComputeRoutesResponse({this.routes, this.fallbackInfo});

  /// Contains an array of computed routes (up to three) when you specify
  /// [ComputeRoutesRequest.computeAlternativeRoutes], and contains just one
  /// [Route] when you don't. When this array contains multiple entries, the
  /// first one is the most recommended [Route]. If the array is empty, then
  /// it means no [Route] could be found.
  final List<Route>? routes;

  /// In some cases when the server is not able to compute the route results
  /// with all of the input preferences, it may fallback to using a different
  /// way of computation. When fallback mode is used, this field contains
  /// detailed info about the fallback response. Otherwise this field is unset.
  final FallbackInfo? fallbackInfo;

  /// Decodes a JSON object to a [ComputeRoutesResponse].
  ///
  /// Returns null if [json] is null.
  static ComputeRoutesResponse? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    final List<Route>? routes = data['routes'] != null
        ? List<Route>.from(
            (data['routes'] as List<dynamic>).map(
              (dynamic model) => Route.fromJson(model),
            ),
          )
        : null;

    return ComputeRoutesResponse(
      routes: routes,
      fallbackInfo: data['fallbackInfo'] != null
          ? FallbackInfo.fromJson(
              data['fallbackInfo'],
            )
          : null,
    );
  }

  /// Returns a JSON representation of the [ComputeRoutesResponse].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'routes': routes?.map((Route route) => route.toJson()).toList(),
      'fallbackInfo': fallbackInfo?.toJson(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
