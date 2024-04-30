// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(srujzs): Needed for https://github.com/dart-lang/sdk/issues/54801. Once
// we publish a version with a min SDK constraint that contains this fix,
// remove.
@JS()
library;

import 'dart:js_interop';

import 'package:google_maps/google_maps.dart' as gmaps;

/// A typedef representing a callback function for handling cluster tap events.
typedef ClusterClickHandler = void Function(
  gmaps.MapMouseEvent,
  MarkerClustererCluster,
  gmaps.GMap,
);

/// The [MarkerClustererOptions] object used to initialize [MarkerClusterer].
///
/// See: https://googlemaps.github.io/js-markerclusterer/interfaces/MarkerClustererOptions.html
@JS()
@anonymous
extension type MarkerClustererOptions._(JSObject _) implements JSObject {
  /// Constructs a new [MarkerClustererOptions] object.
  factory MarkerClustererOptions({
    gmaps.GMap? map,
    List<gmaps.Marker>? markers,
    ClusterClickHandler? onClusterClick,
  }) =>
      MarkerClustererOptions._js(
        map: map as JSAny?,
        markers: markers?.cast<JSAny>().toJS ?? JSArray<JSAny>(),
        onClusterClick: onClusterClick != null
            ? ((JSAny event, MarkerClustererCluster cluster, JSAny map) =>
                onClusterClick(event as gmaps.MapMouseEvent, cluster,
                    map as gmaps.GMap)).toJS
            : null,
      );

  external factory MarkerClustererOptions._js({
    JSAny? map,
    JSArray<JSAny> markers,
    JSFunction? onClusterClick,
  });

  /// Returns the [gmaps.GMap] object.
  gmaps.GMap? get map => _map as gmaps.GMap?;
  @JS('map')
  external JSAny? get _map;

  /// Returns the list of [gmaps.Marker] objects.
  List<gmaps.Marker>? get markers => _markers?.toDart.cast<gmaps.Marker>();
  @JS('markers')
  external JSArray<JSAny>? get _markers;

  /// Returns the onClusterClick handler.
  ClusterClickHandler? get onClusterClick =>
      _onClusterClick?.toDart as ClusterClickHandler?;
  @JS('onClusterClick')
  external JSExportedDartFunction? get _onClusterClick;
}

/// The cluster object handled by the [MarkerClusterer].
///
/// https://googlemaps.github.io/js-markerclusterer/classes/Cluster.html
@JS('markerClusterer.Cluster')
extension type MarkerClustererCluster._(JSObject _) implements JSObject {
  /// Getter for the cluster marker.
  gmaps.Marker get marker => _marker as gmaps.Marker;
  @JS('marker')
  external JSAny get _marker;

  /// List of markers in the cluster.
  List<gmaps.Marker> get markers => _markers.toDart.cast<gmaps.Marker>();
  @JS('markers')
  external JSArray<JSAny> get _markers;

  /// The bounds of the cluster.
  gmaps.LatLngBounds? get bounds => _bounds as gmaps.LatLngBounds?;
  @JS('bounds')
  external JSAny? get _bounds;

  /// The position of the cluster marker.
  gmaps.LatLng get position => _position as gmaps.LatLng;
  @JS('position')
  external JSAny get _position;

  /// Get the count of **visible** markers.
  external int get count;

  /// Deletes the cluster.
  external void delete();

  /// Adds a marker to the cluster.
  void push(gmaps.Marker marker) => _push(marker as JSAny);
  @JS('push')
  external void _push(JSAny marker);
}

/// The [MarkerClusterer] object used to cluster markers on the map.
///
/// https://googlemaps.github.io/js-markerclusterer/classes/MarkerClusterer.html
@JS('markerClusterer.MarkerClusterer')
extension type MarkerClusterer._(JSObject _) implements JSObject {
  /// Constructs a new [MarkerClusterer] object.
  external MarkerClusterer(MarkerClustererOptions options);

  /// Adds a marker to be clustered by the [MarkerClusterer].
  void addMarker(gmaps.Marker marker, bool? noDraw) =>
      _addMarker(marker as JSAny, noDraw);
  @JS('addMarker')
  external void _addMarker(JSAny marker, bool? noDraw);

  /// Adds a list of markers to be clustered by the [MarkerClusterer].
  void addMarkers(List<gmaps.Marker>? markers, bool? noDraw) =>
      _addMarkers(markers?.cast<JSAny>().toJS, noDraw);
  @JS('addMarkers')
  external void _addMarkers(JSArray<JSAny>? markers, bool? noDraw);

  /// Removes a marker from the [MarkerClusterer].
  bool removeMarker(gmaps.Marker marker, bool? noDraw) =>
      _removeMarker(marker as JSAny, noDraw);
  @JS('removeMarker')
  external bool _removeMarker(JSAny marker, bool? noDraw);

  /// Removes a list of markers from the [MarkerClusterer].
  bool removeMarkers(List<gmaps.Marker>? markers, bool? noDraw) =>
      _removeMarkers(markers?.cast<JSAny>().toJS, noDraw);
  @JS('removeMarkers')
  external bool _removeMarkers(JSArray<JSAny>? markers, bool? noDraw);

  /// Clears all the markers from the [MarkerClusterer].
  external void clearMarkers(bool? noDraw);

  /// Called when the [MarkerClusterer] is added to the map.
  external void onAdd();

  /// Called when the [MarkerClusterer] is removed from the map.
  external void onRemove();

  /// Returns the list of clusters.
  List<MarkerClustererCluster> get clusters =>
      _clusters.toDart.cast<MarkerClustererCluster>();
  @JS('clusters')
  external JSArray<JSAny> get _clusters;

  /// Recalculates and draws all the marker clusters.
  external void render();
}

/// Creates [MarkerClusterer] object with given [gmaps.GMap] and
/// [ClusterClickHandler].
MarkerClusterer createMarkerClusterer(
    gmaps.GMap map, ClusterClickHandler onClusterClickHandler) {
  final MarkerClustererOptions options = MarkerClustererOptions(
    map: map,
    onClusterClick: onClusterClickHandler,
  );
  return MarkerClusterer(options);
}
