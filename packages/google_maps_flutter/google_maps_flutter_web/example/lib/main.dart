// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  const double latitude = -28.4503081;
  const double longitude = -52.1976798;
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: const CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            zoom: 18.742,
          ),
          markers: <Marker>{
            const Marker(
              markerId: MarkerId('Objetiva Software'),
              position: LatLng(
                latitude,
                longitude,
              ),
            ),
          },
        ),
      ),
    ),
  );
}
