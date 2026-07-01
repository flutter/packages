// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unnecessary_statements

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as main_file;

void main() {
  group('google_maps_flutter exports', () {
    test(
      'ensure google_maps_flutter.dart exports classes from platform interface',
      () {
        main_file.AdvancedMarker;
        main_file.AdvancedMarkerGlyph;
        main_file.ArgumentCallback;
        main_file.ArgumentCallbacks;
        main_file.AssetMapBitmap;
        main_file.BitmapDescriptor;
        main_file.BitmapGlyph;
        main_file.BytesMapBitmap;
        main_file.CameraPosition;
        main_file.CameraPositionCallback;
        main_file.CameraTargetBounds;
        main_file.CameraUpdate;
        main_file.Cap;
        main_file.Circle;
        main_file.CircleGlyph;
        main_file.CircleId;
        main_file.Cluster;
        main_file.ClusterManager;
        main_file.ClusterManagerId;
        main_file.GroundOverlay;
        main_file.GroundOverlayId;
        main_file.Heatmap;
        main_file.HeatmapGradient;
        main_file.HeatmapGradientColor;
        main_file.HeatmapId;
        main_file.HeatmapRadius;
        main_file.InfoWindow;
        main_file.JointType;
        main_file.LatLng;
        main_file.LatLngBounds;
        main_file.MapBitmapScaling;
        main_file.MapColorScheme;
        main_file.MapStyleException;
        main_file.MapType;
        main_file.Marker;
        main_file.MarkerCollisionBehavior;
        main_file.MarkerId;
        main_file.MinMaxZoomPreference;
        main_file.PatternItem;
        main_file.PinConfig;
        main_file.Polygon;
        main_file.PolygonId;
        main_file.Polyline;
        main_file.PolylineId;
        main_file.ScreenCoordinate;
        main_file.TextGlyph;
        main_file.Tile;
        main_file.TileOverlay;
        main_file.TileOverlayId;
        main_file.TileProvider;
        main_file.WebCameraControlPosition;
        main_file.WebGestureHandling;
        main_file.WeightedLatLng;
      },
    );
  });
}
