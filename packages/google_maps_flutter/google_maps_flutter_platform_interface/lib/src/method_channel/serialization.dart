// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../google_maps_flutter_platform_interface.dart';

String _objectsToAddKey(String name) => '${name}sToAdd';
String _objectsToChangeKey(String name) => '${name}sToChange';
String _objectIdsToRemoveKey(String name) => '${name}IdsToRemove';
const String _heatmapIdKey = 'heatmapId';
const String _heatmapDataKey = 'data';
const String _heatmapDissipatingKey = 'dissipating';
const String _heatmapGradientKey = 'gradient';
const String _heatmapMaxIntensityKey = 'maxIntensity';
const String _heatmapOpacityKey = 'opacity';
const String _heatmapRadiusKey = 'radius';
const String _heatmapMinimumZoomIntensityKey = 'minimumZoomIntensity';
const String _heatmapMaximumZoomIntensityKey = 'maximumZoomIntensity';
const String _heatmapGradientColorsKey = 'colors';
const String _heatmapGradientStartPointsKey = 'startPoints';
const String _heatmapGradientColorMapSizeKey = 'colorMapSize';

void _addIfNonNull(Map<String, Object?> map, String fieldName, Object? value) {
  if (value != null) {
    map[fieldName] = value;
  }
}

/// Serialize [MapsObjectUpdates]
Object serializeMapsObjectUpdates<T extends MapsObject<T>>(
  MapsObjectUpdates<T> updates,
  Object Function(T) serialize,
) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(
    json,
    _objectsToAddKey(updates.objectName),
    updates.objectsToAdd.map(serialize).toList(),
  );
  _addIfNonNull(
    json,
    _objectsToChangeKey(updates.objectName),
    updates.objectsToChange.map(serialize).toList(),
  );
  _addIfNonNull(
    json,
    _objectIdsToRemoveKey(updates.objectName),
    updates.objectIdsToRemove
        .map<String>((MapsObjectId<T> m) => m.value)
        .toList(),
  );

  return json;
}

/// Serialize [Heatmap]
Object serializeHeatmap(Heatmap heatmap) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(json, _heatmapIdKey, heatmap.heatmapId.value);
  _addIfNonNull(
    json,
    _heatmapDataKey,
    heatmap.data.map(serializeWeightedLatLng).toList(),
  );
  _addIfNonNull(json, _heatmapDissipatingKey, heatmap.dissipating);

  final HeatmapGradient? gradient = heatmap.gradient;
  if (gradient != null) {
    _addIfNonNull(
        json, _heatmapGradientKey, serializeHeatmapGradient(gradient));
  }
  _addIfNonNull(json, _heatmapMaxIntensityKey, heatmap.maxIntensity);
  _addIfNonNull(json, _heatmapOpacityKey, heatmap.opacity);
  _addIfNonNull(json, _heatmapRadiusKey, heatmap.radius.radius);
  _addIfNonNull(
      json, _heatmapMinimumZoomIntensityKey, heatmap.minimumZoomIntensity);
  _addIfNonNull(
      json, _heatmapMaximumZoomIntensityKey, heatmap.maximumZoomIntensity);

  return json;
}

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
  final List<dynamic> list = json as List<dynamic>;
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
  final List<Object?> list = json as List<Object?>;
  return LatLng(list[0]! as double, list[1]! as double);
}

/// Serialize [HeatmapGradient]
Object serializeHeatmapGradient(HeatmapGradient gradient) {
  final Map<String, Object> json = <String, Object>{};

  _addIfNonNull(
    json,
    _heatmapGradientColorsKey,
    gradient.colors.map((HeatmapGradientColor e) => e.color.value).toList(),
  );
  _addIfNonNull(
    json,
    _heatmapGradientStartPointsKey,
    gradient.colors.map((HeatmapGradientColor e) => e.startPoint).toList(),
  );
  _addIfNonNull(json, _heatmapGradientColorMapSizeKey, gradient.colorMapSize);

  return json;
}

/// Deserialize [HeatmapGradient]
HeatmapGradient? deserializeHeatmapGradient(Object? json) {
  if (json == null) {
    return null;
  }
  assert(json is Map);
  final Map<String, Object?> map = (json as Map<Object?, Object?>).cast();
  final List<Color> colors = (map[_heatmapGradientColorsKey]! as List<Object?>)
      .whereType<int>()
      .map((int e) => Color(e))
      .toList();
  final List<double> startPoints =
      (map[_heatmapGradientStartPointsKey]! as List<Object?>)
          .whereType<double>()
          .toList();
  final List<HeatmapGradientColor> gradientColors = <HeatmapGradientColor>[];
  for (int i = 0; i < colors.length; i++) {
    gradientColors.add(HeatmapGradientColor(colors[i], startPoints[i]));
  }
  return HeatmapGradient(
    gradientColors,
    colorMapSize: map[_heatmapGradientColorMapSizeKey] as int? ?? 256,
  );
}
