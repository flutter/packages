// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'page.dart';
import 'place_advanced_marker.dart';

/// Page demonstrating how to use AdvancedMarker's collision behavior.
class AdvancedMarkerCollisionBehaviorPage extends GoogleMapExampleAppPage {
  /// Default constructor.
  const AdvancedMarkerCollisionBehaviorPage({
    Key? key,
    required this.mapId,
  }) : super(const Icon(Icons.not_listed_location),
            'Advanced marker collision behavior',
            key: key);

  /// Map ID to use for the GoogleMap.
  final String? mapId;

  @override
  Widget build(BuildContext context) {
    return _CollisionBehaviorPageBody(mapId: mapId);
  }
}

class _CollisionBehaviorPageBody extends StatefulWidget {
  const _CollisionBehaviorPageBody({required this.mapId});

  final String? mapId;

  @override
  State<_CollisionBehaviorPageBody> createState() =>
      _CollisionBehaviorPageBodyState();
}

class _CollisionBehaviorPageBodyState
    extends State<_CollisionBehaviorPageBody> {
  static const LatLng center = LatLng(-33.86711, 151.1947171);
  static const double zoomOutLevel = 9;
  static const double zoomInLevel = 12;

  MarkerCollisionBehavior markerCollisionBehavior =
      MarkerCollisionBehavior.optionalAndHidesLowerPriority;

  GoogleMapController? controller;
  final List<AdvancedMarker> markers = <AdvancedMarker>[];

  void _addMarkers() {
    final List<AdvancedMarker> newMarkers = <AdvancedMarker>[
      for (int i = 0; i < 12; i++)
        AdvancedMarker(
          markerId: MarkerId('marker_${i}_$markerCollisionBehavior'),
          position: LatLng(
            center.latitude + sin(i * pi / 6.0) / 20.0,
            center.longitude + cos(i * pi / 6.0) / 20.0,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          collisionBehavior: markerCollisionBehavior,
        ),
    ];

    markers.clear();
    markers.addAll(newMarkers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AdvancedMarkersCapabilityStatus(controller: controller),
        Expanded(
          child: GoogleMap(
            mapId: widget.mapId,
            markerType: GoogleMapMarkerType.advancedMarker,
            initialCameraPosition: const CameraPosition(
              target: center,
              zoom: zoomInLevel,
            ),
            markers: Set<AdvancedMarker>.of(markers),
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                this.controller = controller;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Current collision behavior: ${markerCollisionBehavior.name}',
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _addMarkers();
                });
              },
              child: const Text('Add markers'),
            ),
            TextButton(
              onPressed: () {
                controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: center,
                      zoom: zoomOutLevel,
                    ),
                  ),
                );
              },
              child: const Text('Zoom out'),
            ),
            TextButton(
              onPressed: () {
                controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: center,
                      zoom: zoomInLevel,
                    ),
                  ),
                );
              },
              child: const Text('Zoom in'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  markerCollisionBehavior = markerCollisionBehavior ==
                          MarkerCollisionBehavior.optionalAndHidesLowerPriority
                      ? MarkerCollisionBehavior.requiredDisplay
                      : MarkerCollisionBehavior.optionalAndHidesLowerPriority;
                  _addMarkers();
                });
              },
              child: const Text('Toggle collision behavior'),
            ),
          ],
        ),
      ],
    );
  }
}
