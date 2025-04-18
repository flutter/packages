// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';

/// Page for demonstrating marker clustering support.
class ClusteringPage extends GoogleMapExampleAppPage {
  /// Default Constructor.
  const ClusteringPage({Key? key})
      : super(const Icon(Icons.place), 'Manage clustering', key: key);

  @override
  Widget build(BuildContext context) {
    return const _ClusteringBody();
  }
}

/// Body of the clustering page.
class _ClusteringBody extends StatefulWidget {
  /// Default Constructor.
  const _ClusteringBody();

  @override
  State<StatefulWidget> createState() => ClusteringBodyState();

  /// Returns selected or unselected state of the given [marker].
  Marker copyWithSelectedState(Marker marker, bool isSelected) {
    return marker.copyWith(
      iconParam: isSelected
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarker,
    );
  }
}

/// State of the clustering page.
class ClusteringBodyState extends State<_ClusteringBody> {
  /// Default Constructor.
  ClusteringBodyState();

  /// Starting point from where markers are added.
  static const LatLng center = LatLng(-33.86, 151.1547171);

  /// Marker offset factor for randomizing marker placing.
  static const double _markerOffsetFactor = 0.05;

  /// Offset for longitude when placing markers to different cluster managers.
  static const double _clusterManagerLongitudeOffset = 0.1;

  /// Maximum amount of cluster managers.
  static const int _clusterManagerMaxCount = 3;

  /// Amount of markers to be added to the cluster manager at once.
  static const int _markersToAddToClusterManagerCount = 10;

  /// Fully visible alpha value.
  static const double _fullyVisibleAlpha = 1.0;

  /// Half visible alpha value.
  static const double _halfVisibleAlpha = 0.5;

  /// Google map controller.
  ExampleGoogleMapController? controller;

  /// Map of clusterManagers with identifier as the key.
  Map<ClusterManagerId, ClusterManager> clusterManagers =
      <ClusterManagerId, ClusterManager>{};

  /// Map of markers with identifier as the key.
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  /// Id of the currently selected marker.
  MarkerId? selectedMarker;

  /// Counter for added cluster manager ids.
  int _clusterManagerIdCounter = 1;

  /// Counter for added markers ids.
  int _markerIdCounter = 1;

  /// Cluster that was tapped most recently.
  Cluster? lastCluster;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(ExampleGoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld =
              widget.copyWithSelectedState(markers[previousMarkerId]!, false);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker =
            widget.copyWithSelectedState(tappedMarker, true);
        markers[markerId] = newMarker;
      });
    }
  }

  void _addClusterManager() {
    if (clusterManagers.length == _clusterManagerMaxCount) {
      return;
    }

    final String clusterManagerIdVal =
        'cluster_manager_id_$_clusterManagerIdCounter';
    _clusterManagerIdCounter++;
    final ClusterManagerId clusterManagerId =
        ClusterManagerId(clusterManagerIdVal);

    final ClusterManager clusterManager = ClusterManager(
      clusterManagerId: clusterManagerId,
      onClusterTap: (Cluster cluster) => setState(() {
        lastCluster = cluster;
      }),
    );

    setState(() {
      clusterManagers[clusterManagerId] = clusterManager;
    });
    _addMarkersToCluster(clusterManager);
  }

  void _removeClusterManager(ClusterManager clusterManager) {
    setState(() {
      // Remove markers managed by cluster manager to be removed.
      markers.removeWhere((MarkerId key, Marker marker) =>
          marker.clusterManagerId == clusterManager.clusterManagerId);
      // Remove cluster manager.
      clusterManagers.remove(clusterManager.clusterManagerId);
    });
  }

  void _addMarkersToCluster(ClusterManager clusterManager) {
    for (int i = 0; i < _markersToAddToClusterManagerCount; i++) {
      final String markerIdVal =
          '${clusterManager.clusterManagerId.value}_marker_id_$_markerIdCounter';
      _markerIdCounter++;
      final MarkerId markerId = MarkerId(markerIdVal);

      final int clusterManagerIndex =
          clusterManagers.values.toList().indexOf(clusterManager);

      // Add additional offset to longitude for each cluster manager to space
      // out markers in different cluster managers.
      final double clusterManagerLongitudeOffset =
          clusterManagerIndex * _clusterManagerLongitudeOffset;

      final Marker marker = Marker(
        clusterManagerId: clusterManager.clusterManagerId,
        markerId: markerId,
        position: LatLng(
          center.latitude + _getRandomOffset(),
          center.longitude + _getRandomOffset() + clusterManagerLongitudeOffset,
        ),
        infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
        onTap: () => _onMarkerTapped(markerId),
      );
      markers[markerId] = marker;
    }
    setState(() {});
  }

  double _getRandomOffset() {
    return (Random().nextDouble() - 0.5) * _markerOffsetFactor;
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }

  void _changeMarkersAlpha() {
    for (final MarkerId markerId in markers.keys) {
      final Marker marker = markers[markerId]!;
      final double current = marker.alpha;
      markers[markerId] = marker.copyWith(
        alphaParam: current == _fullyVisibleAlpha
            ? _halfVisibleAlpha
            : _fullyVisibleAlpha,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MarkerId? selectedId = selectedMarker;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          height: 300.0,
          child: ExampleGoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-33.852, 151.25),
              zoom: 11.0,
            ),
            markers: Set<Marker>.of(markers.values),
            clusterManagers: Set<ClusterManager>.of(clusterManagers.values),
          ),
        ),
        Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: clusterManagers.length >= _clusterManagerMaxCount
                    ? null
                    : () => _addClusterManager(),
                child: const Text('Add cluster manager'),
              ),
              TextButton(
                onPressed: clusterManagers.isEmpty
                    ? null
                    : () => _removeClusterManager(clusterManagers.values.last),
                child: const Text('Remove cluster manager'),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              for (final MapEntry<ClusterManagerId, ClusterManager> clusterEntry
                  in clusterManagers.entries)
                TextButton(
                  onPressed: () => _addMarkersToCluster(clusterEntry.value),
                  child: Text('Add markers to ${clusterEntry.key.value}'),
                ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () {
                        _remove(selectedId);
                        setState(() {
                          selectedMarker = null;
                        });
                      },
                child: const Text('Remove selected marker'),
              ),
              TextButton(
                onPressed: markers.isEmpty ? null : () => _changeMarkersAlpha(),
                child: const Text('Change all markers alpha'),
              ),
            ],
          ),
          if (lastCluster != null)
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Cluster with ${lastCluster!.count} markers clicked at ${lastCluster!.position}')),
        ]),
      ],
    );
  }
}
