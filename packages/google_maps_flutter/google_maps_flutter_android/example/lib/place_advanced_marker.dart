// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'main.dart' as main;
import 'page.dart';
import 'place_marker.dart';

/// Page demonstrating how to use Advanced [Marker] class
class PlaceAdvancedMarkerPage extends GoogleMapExampleAppPage {
  /// Default constructor
  const PlaceAdvancedMarkerPage({Key? key})
      : super(const Icon(Icons.place_outlined), 'Place advanced marker',
            key: key);

  @override
  Widget build(BuildContext context) {
    return const _PlaceAdvancedMarkerBody();
  }
}

class _PlaceAdvancedMarkerBody extends PlaceMarkerBody {
  const _PlaceAdvancedMarkerBody();

  @override
  State<StatefulWidget> createState() => _PlaceAdvancedMarkerBodyState();
}

class _PlaceAdvancedMarkerBodyState extends PlaceMarkerBodyState {
  @override
  String? get mapId => main.mapId;

  @override
  Marker createMarker({
    required MarkerId markerId,
    required LatLng position,
    required InfoWindow infoWindow,
    required VoidCallback onTap,
    required ValueChanged<LatLng>? onDragEnd,
    required ValueChanged<LatLng>? onDrag,
  }) {
    return AdvancedMarker(
      markerId: markerId,
      position: position,
      infoWindow: infoWindow,
      onTap: onTap,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
      icon: _getMarkerBitmapDescriptor(isSelected: false),
    );
  }

  @override
  Marker getSelectedMarker(Marker marker, bool isSelected) {
    return marker.copyWith(
      iconParam: _getMarkerBitmapDescriptor(isSelected: isSelected),
    );
  }

  BitmapDescriptor _getMarkerBitmapDescriptor({required bool isSelected}) {
    return BitmapDescriptor.pinConfig(
      backgroundColor: isSelected ? Colors.blue : Colors.white,
      borderColor: isSelected ? Colors.white : Colors.blue,
      glyph: Glyph.color(isSelected ? Colors.white : Colors.blue),
    );
  }

  /// Whether map supports advanced markers. Null indicates capability check
  /// is in progress
  bool? _isAdvancedMarkersAvailable;

  @override
  Widget getHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        switch (_isAdvancedMarkersAvailable) {
          null => 'Checking map capabilities…',
          true =>
            'Map capabilities check result:\nthis map supports advanced markers',
          false =>
            "Map capabilities check result:\nthis map doesn't support advanced markers. Please check that map Id is provided and correct map renderer is used",
        },
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: switch (_isAdvancedMarkersAvailable) {
                true => Colors.green.shade700,
                false => Colors.red,
                null => Colors.black,
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if map is capable of showing advanced markers
    if (controller != null) {
      GoogleMapsFlutterPlatform.instance
          .isAdvancedMarkersAvailable(mapId: controller!.mapId)
          .then((bool result) {
        setState(() {
          _isAdvancedMarkersAvailable = result;
        });
      });
    }

    return super.build(context);
  }
}
