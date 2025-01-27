// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'custom_marker_icon.dart';
import 'example_google_map.dart';
import 'page.dart';

class PlaceMarkerPage extends GoogleMapExampleAppPage {
  const PlaceMarkerPage({Key? key})
      : super(const Icon(Icons.place), 'Place marker', key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceMarkerBody();
  }
}

class PlaceMarkerBody extends StatefulWidget {
  const PlaceMarkerBody({super.key});

  @override
  State<StatefulWidget> createState() => PlaceMarkerBodyState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  PlaceMarkerBodyState();
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  ExampleGoogleMapController? controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(ExampleGoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  Future<void> _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      markerPosition = newPosition;
    });
  }

  Future<void> _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        markerPosition = null;
      });
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () => _onMarkerTapped(markerId),
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }

  void _changePosition(MarkerId markerId) {
    final Marker marker = markers[markerId]!;
    final LatLng current = marker.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      markers[markerId] = marker.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  void _changeAnchor(MarkerId markerId) {
    final Marker marker = markers[markerId]!;
    final Offset currentAnchor = marker.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      markers[markerId] = marker.copyWith(
        anchorParam: newAnchor,
      );
    });
  }

  Future<void> _changeInfoAnchor(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final Offset currentAnchor = marker.infoWindow.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      markers[markerId] = marker.copyWith(
        infoWindowParam: marker.infoWindow.copyWith(
          anchorParam: newAnchor,
        ),
      );
    });
  }

  Future<void> _toggleDraggable(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        draggableParam: !marker.draggable,
      );
    });
  }

  Future<void> _toggleFlat(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        flatParam: !marker.flat,
      );
    });
  }

  Future<void> _changeInfo(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final String newSnippet = '${marker.infoWindow.snippet!}*';
    setState(() {
      markers[markerId] = marker.copyWith(
        infoWindowParam: marker.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.alpha;
    setState(() {
      markers[markerId] = marker.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _changeRotation(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.rotation;
    setState(() {
      markers[markerId] = marker.copyWith(
        rotationParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }

  Future<void> _toggleVisible(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        visibleParam: !marker.visible,
      );
    });
  }

  Future<void> _changeZIndex(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.zIndex;
    setState(() {
      markers[markerId] = marker.copyWith(
        zIndexParam: current == 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

  void _setMarkerIcon(MarkerId markerId, BitmapDescriptor assetIcon) {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        iconParam: assetIcon,
      );
    });
  }

  Future<BitmapDescriptor> _getMarkerIcon(BuildContext context) async {
    const Size canvasSize = Size(48, 48);
    final ByteData bytes = await createCustomMarkerIconImage(size: canvasSize);
    return BytesMapBitmap(bytes.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final MarkerId? selectedId = selectedMarker;
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
              markers: Set<Marker>.of(markers.values),
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
                onPressed:
                    selectedId == null ? null : () => _changeInfo(selectedId),
                child: const Text('change info'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _changeInfoAnchor(selectedId),
                child: const Text('change info anchor'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _changeAlpha(selectedId),
                child: const Text('change alpha'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _changeAnchor(selectedId),
                child: const Text('change anchor'),
              ),
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () => _toggleDraggable(selectedId),
                child: const Text('toggle draggable'),
              ),
              TextButton(
                onPressed:
                    selectedId == null ? null : () => _toggleFlat(selectedId),
                child: const Text('toggle flat'),
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
                    : () => _changeRotation(selectedId),
                child: const Text('change rotation'),
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
                        _getMarkerIcon(context).then(
                          (BitmapDescriptor icon) {
                            _setMarkerIcon(selectedId, icon);
                          },
                        );
                      },
                child: const Text('set marker icon'),
              ),
            ],
          ),
        ],
      ),
      Visibility(
        visible: markerPosition != null,
        child: Container(
          color: Colors.white70,
          height: 30,
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              if (markerPosition == null)
                Container()
              else
                Expanded(child: Text('lat: ${markerPosition!.latitude}')),
              if (markerPosition == null)
                Container()
              else
                Expanded(child: Text('lng: ${markerPosition!.longitude}')),
            ],
          ),
        ),
      ),
    ]);
  }
}
