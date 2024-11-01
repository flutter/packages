// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'main.dart' as main;
import 'marker_icons.dart';
import 'page.dart';

/// Page that demonstrates how to use custom [AdvanceMarker] icons
class AdvancedMarkerIconsPage extends GoogleMapExampleAppPage {
  /// Default constructor
  const AdvancedMarkerIconsPage({Key? key})
      : super(
          key: key,
          const Icon(Icons.image_outlined),
          'Advanced marker icons',
        );

  @override
  Widget build(BuildContext context) {
    return const _AdvancedMarkerIconsBody();
  }
}

class _AdvancedMarkerIconsBody extends MarkerIconsBody {
  const _AdvancedMarkerIconsBody();

  @override
  String? get mapId => main.mapId;

  @override
  Marker createMarker(
    MarkerId markerId,
    LatLng position,
    BitmapDescriptor icon,
  ) {
    return AdvancedMarker(
      markerId: markerId,
      position: position,
      icon: icon,
    );
  }
}
