// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../google_maps_flutter_web.dart';
import 'marker_clustering_js_interop.dart';
import 'types.dart';

/// A controller class for managing marker clustering.
///
/// This class maps [ClusterManager] objects to javascript [MarkerClusterer]
/// objects and provides an interface for adding and removing markers from
/// clusters.
class ClusterManagersController extends GeometryController {
  /// Creates a new [ClusterManagersController] instance.
  ///
  /// The [stream] parameter is a required [StreamController] used for
  /// emitting map events.
  ClusterManagersController(
      {required StreamController<MapEvent<Object?>> stream})
      : _streamController = stream,
        _clusterManagerIdToMarkerClusterer =
            <ClusterManagerId, MarkerClusterer>{};

  // The stream over which cluster managers broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  // A cache of [MarkerClusterer]s indexed by their [ClusterManagerId].
  final Map<ClusterManagerId, MarkerClusterer>
      _clusterManagerIdToMarkerClusterer;

  /// Adds a set of [ClusterManager] objects to the cache.
  void addClusterManagers(Set<ClusterManager> clusterManagersToAdd) {
    clusterManagersToAdd.forEach(_addClusterManager);
  }

  void _addClusterManager(ClusterManager clusterManager) {
    final MarkerClusterer markerClusterer = createMarkerClusterer(
        googleMap,
        (gmaps.MapMouseEvent event, MarkerClustererCluster cluster,
                gmaps.Map map) =>
            _clusterClicked(
                clusterManager.clusterManagerId, event, cluster, map));

    _clusterManagerIdToMarkerClusterer[clusterManager.clusterManagerId] =
        markerClusterer;
    markerClusterer.onAdd();
  }

  /// Removes a set of [ClusterManagerId]s from the cache.
  void removeClusterManagers(Set<ClusterManagerId> clusterManagerIdsToRemove) {
    clusterManagerIdsToRemove.forEach(_removeClusterManager);
  }

  void _removeClusterManager(ClusterManagerId clusterManagerId) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.clearMarkers(true);
      markerClusterer.onRemove();
    }
    _clusterManagerIdToMarkerClusterer.remove(clusterManagerId);
  }

  /// Adds given [gmaps.Marker] to the [MarkerClusterer] with given
  /// [ClusterManagerId].
  void addItem(ClusterManagerId clusterManagerId, gmaps.Marker marker) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.addMarker(marker, true);
      markerClusterer.render();
    }
  }

  /// Removes given [gmaps.Marker] from the [MarkerClusterer] with given
  /// [ClusterManagerId].
  void removeItem(ClusterManagerId clusterManagerId, gmaps.Marker? marker) {
    if (marker != null) {
      final MarkerClusterer? markerClusterer =
          _clusterManagerIdToMarkerClusterer[clusterManagerId];
      if (markerClusterer != null) {
        markerClusterer.removeMarker(marker, true);
        markerClusterer.render();
      }
    }
  }

  /// Returns list of clusters in [MarkerClusterer] with given
  /// [ClusterManagerId].
  List<Cluster> getClusters(ClusterManagerId clusterManagerId) {
    final MarkerClusterer? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      return markerClusterer.clusters
          .map((MarkerClustererCluster cluster) =>
              _convertCluster(clusterManagerId, cluster))
          .toList();
    }
    return <Cluster>[];
  }

  void _clusterClicked(
      ClusterManagerId clusterManagerId,
      gmaps.MapMouseEvent event,
      MarkerClustererCluster markerClustererCluster,
      gmaps.Map map) {
    if (markerClustererCluster.count > 0 &&
        markerClustererCluster.bounds != null) {
      final Cluster cluster =
          _convertCluster(clusterManagerId, markerClustererCluster);
      _streamController.add(ClusterTapEvent(mapId, cluster));
    }
  }

  /// Converts [MarkerClustererCluster] to [Cluster].
  Cluster _convertCluster(ClusterManagerId clusterManagerId,
      MarkerClustererCluster markerClustererCluster) {
    final LatLng position = gmLatLngToLatLng(markerClustererCluster.position);
    final LatLngBounds bounds =
        gmLatLngBoundsTolatLngBounds(markerClustererCluster.bounds!);

    final List<MarkerId> markerIds = markerClustererCluster.markers
        .map<MarkerId>((gmaps.Marker marker) =>
            MarkerId((marker.get('markerId')! as JSString).toDart))
        .toList();
    return Cluster(
      clusterManagerId,
      markerIds,
      position: position,
      bounds: bounds,
    );
  }
}
