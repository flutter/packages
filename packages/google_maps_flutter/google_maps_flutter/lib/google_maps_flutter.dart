// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_maps_flutter;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

export 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    show
        ArgumentCallback,
        ArgumentCallbacks,
        AssetMapBitmap,
        BitmapDescriptor,
        BytesMapBitmap,
        CameraPosition,
        CameraPositionCallback,
        CameraTargetBounds,
        CameraUpdate,
        Cap,
        Circle,
        CircleId,
        Cluster,
        ClusterManager,
        ClusterManagerId,
        Heatmap,
        HeatmapGradient,
        HeatmapGradientColor,
        HeatmapId,
        HeatmapRadius,
        InfoWindow,
        JointType,
        LatLng,
        LatLngBounds,
        MapBitmapScaling,
        MapStyleException,
        MapType,
        Marker,
        MarkerId,
        MinMaxZoomPreference,
        PatternItem,
        Polygon,
        PolygonId,
        Polyline,
        PolylineId,
        ScreenCoordinate,
        Tile,
        TileOverlay,
        TileOverlayId,
        TileProvider,
        WebGestureHandling,
        WeightedLatLng;

part 'src/controller.dart';
part 'src/google_map.dart';
