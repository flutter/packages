// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Serialize [WeightedLatLng]
Object serializeWeightedLatLng(WeightedLatLng wll) {
  return <Object>[serializeLatLng(wll.point), wll.weight];
}

/// Deserialize [WeightedLatLng]
WeightedLatLng? deserializeWeightedLatLng(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is List && json.length == 2);
  final list = json as List<dynamic>;
  final LatLng latLng = deserializeLatLng(list[0])!;
  return WeightedLatLng(latLng, weight: list[1] as double);
}

/// Serialize [LatLng]
Object serializeLatLng(LatLng latLng) {
  return <Object>[latLng.latitude, latLng.longitude];
}

/// Deserialize [LatLng]
LatLng? deserializeLatLng(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is List && json.length == 2);
  final list = json as List<Object?>;
  return LatLng(list[0]! as double, list[1]! as double);
}
