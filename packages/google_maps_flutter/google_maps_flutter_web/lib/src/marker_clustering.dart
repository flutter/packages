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
class ClusterManagersController<T> extends GeometryController {
  /// Creates a new [ClusterManagersController] instance.
  ///
  /// The [stream] parameter is a required [StreamController] used for
  /// emitting map events.
  ClusterManagersController(
      {required StreamController<MapEvent<Object?>> stream})
      : _streamController = stream,
        _clusterManagerIdToMarkerClusterer =
            <ClusterManagerId, MarkerClusterer<T>>{};

  // The stream over which cluster managers broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  // A cache of [MarkerClusterer]s indexed by their [ClusterManagerId].
  final Map<ClusterManagerId, MarkerClusterer<T>>
      _clusterManagerIdToMarkerClusterer;

  /// Adds a set of [ClusterManager] objects to the cache.
  void addClusterManagers(Set<ClusterManager> clusterManagersToAdd) {
    clusterManagersToAdd.forEach(_addClusterManager);
  }

  void _addClusterManager(ClusterManager clusterManager) {
    final MarkerClusterer<T> markerClusterer = createMarkerClusterer<T>(
      googleMap,
      (gmaps.MapMouseEvent event, MarkerClustererCluster<T> cluster,
              gmaps.Map map) =>
          _clusterClicked(clusterManager.clusterManagerId, event, cluster, map),
    );

    _clusterManagerIdToMarkerClusterer[clusterManager.clusterManagerId] =
        markerClusterer;
    markerClusterer.onAdd();
  }

  /// Removes a set of [ClusterManagerId]s from the cache.
  void removeClusterManagers(Set<ClusterManagerId> clusterManagerIdsToRemove) {
    clusterManagerIdsToRemove.forEach(_removeClusterManager);
  }

  void _removeClusterManager(ClusterManagerId clusterManagerId) {
    final MarkerClusterer<T>? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.clearMarkers(true);
      markerClusterer.onRemove();
    }
    _clusterManagerIdToMarkerClusterer.remove(clusterManagerId);
  }

  /// Adds given markers to the [MarkerClusterer] with given [ClusterManagerId].
  void addItem(
    ClusterManagerId clusterManagerId,
    T marker,
  ) {
    final MarkerClusterer<T>? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      markerClusterer.addMarker(marker, true);
      markerClusterer.render();
    }
  }

  /// Removes given marker from the [MarkerClusterer] with
  /// given [ClusterManagerId].
  void removeItem(
    ClusterManagerId clusterManagerId,
    T? marker,
  ) {
    if (marker != null) {
      final MarkerClusterer<T>? markerClusterer =
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
    final MarkerClusterer<T>? markerClusterer =
        _clusterManagerIdToMarkerClusterer[clusterManagerId];
    if (markerClusterer != null) {
      return markerClusterer.clusters
          .map((MarkerClustererCluster<T> cluster) =>
              _convertCluster(clusterManagerId, cluster))
          .toList();
    }
    return <Cluster>[];
  }

  void _clusterClicked(
      ClusterManagerId clusterManagerId,
      gmaps.MapMouseEvent event,
      MarkerClustererCluster<T> markerClustererCluster,
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
      MarkerClustererCluster<T> markerClustererCluster) {
    final LatLng position = gmLatLngToLatLng(markerClustererCluster.position);
    final LatLngBounds bounds =
        gmLatLngBoundsToLatLngBounds(markerClustererCluster.bounds!);

    final List<MarkerId> markerIds =
        markerClustererCluster.markers.map<MarkerId>((T marker) {
      return getOnMarkerType(
        marker: marker,
        legacy: (gmaps.Marker marker) {
          return MarkerId((marker.get('markerId')! as JSString).toDart);
        },
        advanced: (gmaps.AdvancedMarkerElement marker) {
          return MarkerId((marker.getAttribute('id')! as JSString).toDart);
        },
      );
    }).toList();

    return Cluster(
      clusterManagerId,
      markerIds,
      position: position,
      bounds: bounds,
    );
  }
}
