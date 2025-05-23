// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';
import 'place_advanced_marker.dart';

/// Page that demonstrates how to use custom [AdvanceMarker] icons.
class AdvancedMarkerIconsPage extends GoogleMapExampleAppPage {
  /// Default constructor.
  const AdvancedMarkerIconsPage({
    required this.mapId,
    Key? key,
  }) : super(
          key: key,
          const Icon(Icons.image_outlined),
          'Advanced marker icons',
        );

  /// Map ID to use for the GoogleMap.
  final String? mapId;

  @override
  Widget build(BuildContext context) {
    return _AdvancedMarkerIconsBody(mapId: mapId);
  }
}

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

class _AdvancedMarkerIconsBody extends StatefulWidget {
  const _AdvancedMarkerIconsBody({required this.mapId});

  /// Map ID to use for the GoogleMap.
  final String? mapId;

  @override
  State<_AdvancedMarkerIconsBody> createState() =>
      _AdvancedMarkerIconsBodyState();
}

class _AdvancedMarkerIconsBodyState extends State<_AdvancedMarkerIconsBody> {
  final Set<AdvancedMarker> _markers = <AdvancedMarker>{};

  ExampleGoogleMapController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AdvancedMarkersCapabilityStatus(controller: controller),
        Expanded(
          child: ExampleGoogleMap(
            mapId: widget.mapId,
            markerType: MarkerType.advancedMarker,
            initialCameraPosition: const CameraPosition(
              target: _kMapCenter,
              zoom: 7.0,
            ),
            markers: _markers,
            onMapCreated: (ExampleGoogleMapController controller) {
              setState(() {
                this.controller = controller;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: _markers.isNotEmpty
                ? null
                : () async {
                    final AssetMapBitmap asset = await BitmapDescriptor.asset(
                      const ImageConfiguration(
                        size: Size(12, 12),
                      ),
                      'assets/red_square.png',
                    );
                    final AssetMapBitmap largeAsset =
                        await BitmapDescriptor.asset(
                      const ImageConfiguration(
                        size: Size(36, 36),
                      ),
                      'assets/red_square.png',
                    );

                    setState(() {
                      _markers.addAll(<AdvancedMarker>[
                        // Default icon
                        AdvancedMarker(
                          markerId: const MarkerId('1'),
                          position: LatLng(
                            _kMapCenter.latitude + 1,
                            _kMapCenter.longitude + 1,
                          ),
                        ),
                        // Custom pin colors
                        AdvancedMarker(
                          markerId: const MarkerId('2'),
                          position: LatLng(
                            _kMapCenter.latitude - 1,
                            _kMapCenter.longitude - 1,
                          ),
                          icon: BitmapDescriptor.pinConfig(
                            borderColor: Colors.red,
                            backgroundColor: Colors.black,
                            glyph: const CircleGlyph(color: Colors.red),
                          ),
                        ),
                        // Pin with text
                        AdvancedMarker(
                          markerId: const MarkerId('3'),
                          position: LatLng(
                            _kMapCenter.latitude - 1,
                            _kMapCenter.longitude + 1,
                          ),
                          icon: BitmapDescriptor.pinConfig(
                            borderColor: Colors.blue,
                            backgroundColor: Colors.white,
                            glyph: const TextGlyph(
                              text: 'Hi!',
                              textColor: Colors.blue,
                            ),
                          ),
                        ),
                        // Pin with bitmap
                        AdvancedMarker(
                          markerId: const MarkerId('4'),
                          position: LatLng(
                            _kMapCenter.latitude + 1,
                            _kMapCenter.longitude - 1,
                          ),
                          icon: BitmapDescriptor.pinConfig(
                            borderColor: Colors.red,
                            backgroundColor: Colors.white,
                            glyph: BitmapGlyph(bitmap: asset),
                          ),
                        ),
                        // Custom marker icon
                        AdvancedMarker(
                          markerId: const MarkerId('5'),
                          position: LatLng(
                            _kMapCenter.latitude,
                            _kMapCenter.longitude,
                          ),
                          icon: largeAsset,
                        ),
                      ]);
                    });
                  },
            child: const Text('Add advanced markers'),
          ),
        ),
      ],
    );
  }
}
