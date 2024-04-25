// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_util' as js_util;

import 'package:google_maps/google_maps.dart' as gmaps;

/// A typedef representing a callback function for handling cluster tap events.
typedef ClusterClickHandler = void Function(
    gmaps.MapMouseEvent, MarkerClustererCluster, gmaps.GMap);

/// The [MarkerClustererOptions] object used to initialize [MarkerClusterer].
@JS()
@anonymous
extension type MarkerClustererOptions._(JSObject _) implements JSObject {
  /// Constructs a new [MarkerClustererOptions] object.
  external factory MarkerClustererOptions();

  /// Returns the [gmaps.GMap] object.
  external gmaps.GMap? get map;

  /// Sets the [gmaps.GMap] object.
  external set map(gmaps.GMap? map);

  /// Returns the list of [gmaps.Marker] objects.
  external List<gmaps.Marker> get markers;

  /// Sets the list of [gmaps.Marker] objects.
  external set markers(List<gmaps.Marker>? markers);

  /// Returns the onClusterClick handler.
  external ClusterClickHandler? get onClusterClick;

  /// Sets the onClusterClick.
  external set onClusterClick(ClusterClickHandler? handler);
}

/// The cluster object handled by the [MarkerClusterer].
@JS('markerClusterer.Cluster')
extension type MarkerClustererCluster._(JSObject _) implements JSObject {
  /// Getter for the cluster marker.
  external gmaps.Marker get marker;

  /// List of markers in the cluster.
  external List<gmaps.Marker> get markers;

  /// The bounds of the cluster.
  external gmaps.LatLngBounds? get bounds;

  /// The position of the cluster marker.
  external gmaps.LatLng get position;

  /// Get the count of **visible** markers.
  external int get count;

  /// Deletes the cluster.
  external void delete();

  /// Adds a marker to the cluster.
  external void push(gmaps.Marker marker);
}

/// The [MarkerClusterer] object used to cluster markers on the map.
@JS('markerClusterer.MarkerClusterer')
extension type MarkerClusterer._(JSObject _) implements JSObject {
  /// Constructs a new [MarkerClusterer] object.
  external MarkerClusterer(MarkerClustererOptions options);

  /// Adds a marker to be clustered by the [MarkerClusterer].
  external void addMarker(gmaps.Marker marker, bool? noDraw);

  /// Adds a list of markers to be clustered by the [MarkerClusterer].
  external void addMarkers(List<gmaps.Marker>? markers, bool? noDraw);

  /// Removes a marker from the [MarkerClusterer].
  external bool removeMarker(gmaps.Marker marker, bool? noDraw);

  /// Removes a list of markers from the [MarkerClusterer].
  external bool removeMarkers(List<gmaps.Marker>? markers, bool? noDraw);

  /// Clears all the markers from the [MarkerClusterer].
  external void clearMarkers(bool? noDraw);

  /// Called when the [MarkerClusterer] is added to the map.
  external void onAdd();

  /// Called when the [MarkerClusterer] is removed from the map.
  external void onRemove();

  /// Returns the list of clusters.
  external List<MarkerClustererCluster> get clusters;

  /// Recalculates and draws all the marker clusters.
  external void render();
}

/// Creates [MarkerClusterer] object with given [gmaps.GMap] and
/// [ClusterClickHandler].
MarkerClusterer createMarkerClusterer(
    gmaps.GMap map, ClusterClickHandler onClusterClickHandler) {
  return MarkerClusterer(_createClusterOptions(map, onClusterClickHandler));
}

/// Creates [MarkerClustererOptions] object with given [gmaps.GMap] and
/// [ClusterClickHandler].
MarkerClustererOptions _createClusterOptions(
    gmaps.GMap map, ClusterClickHandler onClusterClickHandler) {
  final MarkerClustererOptions options = MarkerClustererOptions()
    ..map = map
    ..onClusterClick = js_util.allowInterop(onClusterClickHandler);

  return options;
}
