// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class AnimateCameraPage extends GoogleMapExampleAppPage {
  const AnimateCameraPage({Key? key})
      : super(const Icon(Icons.map), 'Camera control, animated', key: key);

  @override
  Widget build(BuildContext context) {
    return const AnimateCamera();
  }
}

class AnimateCamera extends StatefulWidget {
  const AnimateCamera({super.key});
  @override
  State createState() => AnimateCameraState();
}

// Duration for camera animation in seconds.
const int _durationSeconds = 10;

class AnimateCameraState extends State<AnimateCamera> {
  GoogleMapController? mapController;
  Duration? _cameraUpdateAnimationDuration;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleAnimationDuration() {
    setState(() {
      _cameraUpdateAnimationDuration = _cameraUpdateAnimationDuration != null
          ? null
          : const Duration(seconds: _durationSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          bearing: 270.0,
                          target: LatLng(51.5160895, -0.1294527),
                          tilt: 30.0,
                          zoom: 17.0,
                        ),
                      ),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('newCameraPosition'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        const LatLng(56.1725505, 10.1850512),
                      ),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('newLatLng'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(
                        LatLngBounds(
                          southwest: const LatLng(-38.483935, 113.248673),
                          northeast: const LatLng(-8.982446, 153.823821),
                        ),
                        10.0,
                      ),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('newLatLngBounds'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(37.4231613, -122.087159),
                        11.0,
                      ),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('newLatLngZoom'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.scrollBy(150.0, -225.0),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('scrollBy'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.zoomBy(
                        -0.5,
                        const Offset(30.0, 20.0),
                      ),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('zoomBy with focus'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.zoomBy(-0.5),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('zoomBy'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.zoomIn(),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('zoomIn'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.zoomOut(),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('zoomOut'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.animateCamera(
                      CameraUpdate.zoomTo(16.0),
                      duration: _cameraUpdateAnimationDuration,
                    );
                  },
                  child: const Text('zoomTo'),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'With 10 second duration',
              textAlign: TextAlign.right,
            ),
            const SizedBox(width: 5),
            Switch(
              value: _cameraUpdateAnimationDuration != null,
              onChanged: kIsWeb
                  ? null
                  : (bool value) {
                      _toggleAnimationDuration();
                    },
            ),
          ],
        ),
      ],
    );
  }
}
