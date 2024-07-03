// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'custom_marker_icon.dart';
import 'example_google_map.dart';
import 'page.dart';

class PlaceGroundOverlayPage extends GoogleMapExampleAppPage {
  const PlaceGroundOverlayPage({Key? key})
      : super(const Icon(Icons.place), 'Place ground overlay', key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceGroundOverlayBody();
  }
}

class PlaceGroundOverlayBody extends StatefulWidget {
  const PlaceGroundOverlayBody({super.key});

  @override
  State<PlaceGroundOverlayBody> createState() => PlaceGroundOverlayBodyState();
}

typedef GroundOverlayUpdateAction = GroundOverlay Function(
    GroundOverlay groundOverlay);

class PlaceGroundOverlayBodyState extends State<PlaceGroundOverlayBody> {
  PlaceGroundOverlayBodyState();
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  ExampleGoogleMapController? controller;
  Map<GroundOverlayId, GroundOverlay> groundOverlays =
      <GroundOverlayId, GroundOverlay>{};
  GroundOverlayId? selectedGroundOverlay;
  int _groundOverlayIdCounter = 1;
  LatLng? groundOverlayPosition;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(ExampleGoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onGroundOverlayTapped(GroundOverlayId groundOverlayId) {
    final GroundOverlay? tappedGroundOverlay = groundOverlays[groundOverlayId];
    if (tappedGroundOverlay != null) {
      setState(() {
        final GroundOverlayId? previousGroundOverlayId = selectedGroundOverlay;
        if (previousGroundOverlayId != null &&
            groundOverlays.containsKey(previousGroundOverlayId)) {
          final GroundOverlay resetOld =
              groundOverlays[previousGroundOverlayId]!
                  .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          groundOverlays[previousGroundOverlayId] = resetOld;
        }
        selectedGroundOverlay = groundOverlayId;
        final GroundOverlay newGroundOverlay = tappedGroundOverlay.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        groundOverlays[groundOverlayId] = newGroundOverlay;

        groundOverlayPosition = null;
      });
    }
  }

  void _add() {
    final int groundOverlayCount = groundOverlays.length;

    if (groundOverlayCount == 12) {
      return;
    }

    final String groundOverlayIdVal =
        'ground_overlay_id_$_groundOverlayIdCounter';
    _groundOverlayIdCounter++;
    final GroundOverlayId groundOverlayId = GroundOverlayId(groundOverlayIdVal);

    final LatLng centerPosition = LatLng(
      center.latitude + sin(_groundOverlayIdCounter * pi / 6.0) / 20.0,
      center.longitude + cos(_groundOverlayIdCounter * pi / 6.0) / 20.0,
    );
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
          centerPosition.latitude - 0.01, centerPosition.longitude - 0.01),
      northeast: LatLng(
          centerPosition.latitude + 0.01, centerPosition.longitude + 0.01),
    );

    final GroundOverlay groundOverlay = GroundOverlay(
      groundOverlayId: groundOverlayId,
      bounds: bounds,
      consumeTapEvents: true,
      onTap: () => _onGroundOverlayTapped(groundOverlayId),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay;
    });
  }

  void _remove(GroundOverlayId groundOverlayId) {
    setState(() {
      if (groundOverlays.containsKey(groundOverlayId)) {
        groundOverlays.remove(groundOverlayId);
      }
    });
  }

  void _changePosition(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    final LatLngBounds current = groundOverlay.bounds!;
    final LatLng centerOfBounds = LatLng(
      (current.northeast.latitude + current.southwest.latitude) / 2,
      (current.northeast.longitude + current.southwest.longitude) / 2,
    );
    final Offset offset = Offset(
      center.latitude - centerOfBounds.latitude,
      center.longitude - centerOfBounds.longitude,
    );
    final LatLngBounds newBounds = LatLngBounds(
      southwest: LatLng(centerOfBounds.latitude + offset.dy - 0.01,
          centerOfBounds.longitude + offset.dx - 0.01),
      northeast: LatLng(centerOfBounds.latitude + offset.dy + 0.01,
          centerOfBounds.longitude + offset.dx + 0.01),
    );

    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        boundsParam: newBounds,
      );
    });
  }

  void _changeAnchor(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    final Offset currentAnchor = groundOverlay.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        anchorParam: newAnchor,
      );
    });
  }

  void _changeOpacity(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    final double current = groundOverlay.opacity;
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        opacityParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  void _changeBearing(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    final double current = groundOverlay.bearing;
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        bearingParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }

  void _toggleVisible(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        visibleParam: !groundOverlay.visible,
      );
    });
  }

  void _changeZIndex(GroundOverlayId groundOverlayId) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    final int current = groundOverlay.zIndex;
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        zIndexParam: current == 12 ? 0 : current + 1,
      );
    });
  }

  void _setGroundOverlayIcon(
      GroundOverlayId groundOverlayId, BitmapDescriptor assetIcon) {
    final GroundOverlay groundOverlay = groundOverlays[groundOverlayId]!;
    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay.copyWith(
        iconParam: assetIcon,
      );
    });
  }

  Future<BitmapDescriptor> _getGroundOverlayIcon(BuildContext context) async {
    const Size canvasSize = Size(48, 48);
    final ByteData bytes = await createCustomMarkerIconImage(size: canvasSize);
    return BytesMapBitmap(bytes.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final GroundOverlayId? selectedId = selectedGroundOverlay;
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ExampleGoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
              groundOverlays: Set<GroundOverlay>.of(groundOverlays.values),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: _add,
                child: const Text('Add'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _remove(selectedId),
                child: const Text('Remove'),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _changeOpacity(selectedId),
                child: const Text('change opacity'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _changeAnchor(selectedId),
                child: const Text('change anchor'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _changePosition(selectedId),
                child: const Text('change position'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _changeBearing(selectedId),
                child: const Text('change bearing'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _toggleVisible(selectedId),
                child: const Text('toggle visible'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _changeZIndex(selectedId),
                child: const Text('change zIndex'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () {
                        _getGroundOverlayIcon(context).then(
                          (BitmapDescriptor icon) {
                            _setGroundOverlayIcon(selectedId, icon);
                          },
                        );
                      },
                child: const Text('set ground overlay icon'),
              ),
            ],
          ),
        ],
      ),
      Visibility(
        visible: groundOverlayPosition != null,
        child: Container(
          color: Colors.white70,
          height: 30,
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              if (groundOverlayPosition == null)
                Container()
              else
                Expanded(
                    child: Text('lat: ${groundOverlayPosition!.latitude}')),
              if (groundOverlayPosition == null)
                Container()
              else
                Expanded(
                    child: Text('lng: ${groundOverlayPosition!.longitude}')),
            ],
          ),
        ),
      ),
    ]);
  }
}
