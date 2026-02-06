// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

/// Page for demonstrating Point of Interest (POI) tapping.
class PlacePoiPage extends GoogleMapExampleAppPage {
  /// Default constructor.
  const PlacePoiPage({super.key})
      : super(const Icon(Icons.business), 'Place POI');

  @override
  Widget build(BuildContext context) {
    return const PlacePoiBody();
  }
}

/// Body of the POI page.
class PlacePoiBody extends StatefulWidget {
  /// Default constructor.
  const PlacePoiBody({super.key});

  @override
  State<StatefulWidget> createState() => PlacePoiBodyState();
}

/// State for [PlacePoiBody].
class PlacePoiBodyState extends State<PlacePoiBody> {
  /// The controller for the map.
  /// 
  /// This is public to match the example pattern, but marked with a doc comment.
  GoogleMapController? controller;
  PointOfInterest? _lastPoi;

  final CameraPosition _kKolkata = const CameraPosition(
    target: LatLng(22.54222641620606, 88.34560669761545),
    zoom: 16.0,
  );

  // ignore: use_setters_to_change_properties
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  void _onPoiTap(PointOfInterest poi) {
    setState(() {
      _lastPoi = poi;
    });

    controller?.animateCamera(CameraUpdate.newLatLng(poi.position));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kKolkata,
            onPoiTap: _onPoiTap,
            myLocationButtonEnabled: false,
          ),
        ),
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Last Tapped POI:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_lastPoi != null) ...<Widget>[
                Text('Name: ${_lastPoi!.name}'),
                Text('Place ID: ${_lastPoi!.placeId}'),
                Text(
                  'Lat/Lng: ${_lastPoi!.position.latitude.toStringAsFixed(5)}, ${_lastPoi!.position.longitude.toStringAsFixed(5)}',
                ),
              ] else
                const Text('Tap on a business or landmark icon...'),
            ],
          ),
        ),
      ],
    );
  }
}
