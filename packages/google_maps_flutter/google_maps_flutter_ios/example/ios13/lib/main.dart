// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:maps_example_dart/animate_camera.dart';
import 'package:maps_example_dart/lite_mode.dart';
import 'package:maps_example_dart/map_click.dart';
import 'package:maps_example_dart/map_coordinates.dart';
import 'package:maps_example_dart/map_ui.dart';
import 'package:maps_example_dart/maps_demo.dart';
import 'package:maps_example_dart/marker_icons.dart';
import 'package:maps_example_dart/move_camera.dart';
import 'package:maps_example_dart/padding.dart';
import 'package:maps_example_dart/page.dart';
import 'package:maps_example_dart/place_circle.dart';
import 'package:maps_example_dart/place_marker.dart';
import 'package:maps_example_dart/place_polygon.dart';
import 'package:maps_example_dart/place_polyline.dart';
import 'package:maps_example_dart/scrolling_map.dart';
import 'package:maps_example_dart/snapshot.dart';
import 'package:maps_example_dart/tile_overlay.dart';

void main() {
  runApp(const MaterialApp(
      home: MapsDemo(<GoogleMapExampleAppPage>[
    MapUiPage(),
    MapCoordinatesPage(),
    MapClickPage(),
    AnimateCameraPage(),
    MoveCameraPage(),
    PlaceMarkerPage(),
    MarkerIconsPage(),
    ScrollingMapPage(),
    PlacePolylinePage(),
    PlacePolygonPage(),
    PlaceCirclePage(),
    PaddingPage(),
    SnapshotPage(),
    LiteModePage(),
    TileOverlayPage(),
  ])));
}
