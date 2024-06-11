// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class GroundOverlayPage extends GoogleMapExampleAppPage {
  const GroundOverlayPage({Key? key})
      : super(const Icon(Icons.map), 'Ground overlay', key: key);

  @override
  Widget build(BuildContext context) {
    return const GroundOverlayBody();
  }
}

class GroundOverlayBody extends StatefulWidget {
  const GroundOverlayBody({super.key});

  @override
  State<StatefulWidget> createState() => GroundOverlayBodyState();
}

class GroundOverlayBodyState extends State<GroundOverlayBody> {
  GroundOverlayBodyState();

  GoogleMapController? controller;
  BitmapDescriptor? _overlayImage;
  double _bearing = 0;
  double _opacity = 1.0;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeGroundOverlay() {
    setState(() {
      _overlayImage = null;
    });
  }

  void _addGroundOverlay() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/red_square.png',
    ).then((BitmapDescriptor bitmap) {
      setState(() {
        _overlayImage = bitmap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<GroundOverlay> overlays = <GroundOverlay>{
      if (_overlayImage != null)
        GroundOverlay(
          groundOverlayId: const GroundOverlayId('ground_overlay_1'),
          bitmap: _overlayImage,
          location: const LatLng(59.935460, 30.325177),
          width: 200,
          bearing: _bearing,
          opacity: _opacity,
        ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 500.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(59.935460, 30.325177),
                zoom: 15.0,
              ),
              groundOverlays: overlays,
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        ...<Widget>[
          if (overlays.isEmpty)
            TextButton(
              onPressed: _addGroundOverlay,
              child: const Text('Add ground overlay'),
            ),
          if (overlays.isNotEmpty)
            TextButton(
              onPressed: _removeGroundOverlay,
              child: const Text('Remove ground overlay'),
            ),
          if (overlays.isNotEmpty)
            const Padding(padding: EdgeInsets.all(8), child: Text('Bearing')),
          if (overlays.isNotEmpty)
            Slider(
              label: 'Bearing',
              value: _bearing,
              max: 360,
              onChanged: (double value) {
                setState(() {
                  _bearing = value;
                });
              },
            ),
          if (overlays.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Opacity'),
            ),
          if (overlays.isNotEmpty)
            Slider(
              label: 'Opacity',
              value: _opacity * 100,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _opacity = value / 100.0;
                });
              },
            ),
        ],
      ],
    );
  }
}
