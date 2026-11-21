// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'advanced_marker_icons.dart';
import 'advanced_markers_clustering.dart';
import 'animate_camera.dart';
import 'clustering.dart';
import 'collision_behavior.dart';
import 'ground_overlay.dart';
import 'lite_mode.dart';
import 'map_click.dart';
import 'map_coordinates.dart';
import 'map_map_id.dart';
import 'map_ui.dart';
import 'maps_demo.dart';
import 'marker_icons.dart';
import 'move_camera.dart';
import 'padding.dart';
import 'page.dart';
import 'place_advanced_marker.dart';
import 'place_circle.dart';
import 'place_marker.dart';
import 'place_polygon.dart';
import 'place_polyline.dart';
import 'scrolling_map.dart';
import 'snapshot.dart';
import 'tile_overlay.dart';

/// Place your map ID here. Map ID is required for pages that use advanced
/// markers.
const String? _mapId = null;

void main() {
  runApp(
    const MaterialApp(
      home: MapsDemo(<GoogleMapExampleAppPage>[
        MapUiPage(),
        MapCoordinatesPage(),
        MapClickPage(),
        AnimateCameraPage(),
        MoveCameraPage(),
        PlaceMarkerPage(),
        PlaceAdvancedMarkerPage(mapId: _mapId),
        MarkerIconsPage(),
        AdvancedMarkerIconsPage(mapId: _mapId),
        ScrollingMapPage(),
        PlacePolylinePage(),
        PlacePolygonPage(),
        PlaceCirclePage(),
        PaddingPage(),
        SnapshotPage(),
        LiteModePage(),
        TileOverlayPage(),
        GroundOverlayPage(),
        ClusteringPage(),
        AdvancedMarkersClusteringPage(mapId: _mapId),
        MapIdPage(),
        AdvancedMarkerCollisionBehaviorPage(mapId: _mapId),
      ]),
    ),
  );
}
