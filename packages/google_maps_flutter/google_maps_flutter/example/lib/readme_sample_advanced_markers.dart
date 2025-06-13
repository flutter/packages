// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: AdvancedMarkersSample(),
    );
  }
}

class AdvancedMarkersSample extends StatelessWidget {
  const AdvancedMarkersSample({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
// #docregion AdvancedMarkersSample
      body: GoogleMap(
        // Set your Map ID.
        mapId: 'my-map-id',
        // Enable support for Advanced Markers.
        markerType: GoogleMapMarkerType.advancedMarker,
        initialCameraPosition: _kGooglePlex,
      ),
// #enddocregion AdvancedMarkersSample
    );
  }
}
