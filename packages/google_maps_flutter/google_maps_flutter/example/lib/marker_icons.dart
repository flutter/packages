// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs
// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'custom_marker_icon.dart';
import 'page.dart';

class MarkerIconsPage extends GoogleMapExampleAppPage {
  const MarkerIconsPage({Key? key})
      : super(const Icon(Icons.image), 'Marker icons', key: key);

  @override
  Widget build(BuildContext context) {
    return const MarkerIconsBody();
  }
}

class MarkerIconsBody extends StatefulWidget {
  const MarkerIconsBody({super.key});

  @override
  State<StatefulWidget> createState() => MarkerIconsBodyState();
}

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

enum _MarkerSizeOption { original, size30x30, size60x30, size120x60 }

class MarkerIconsBodyState extends State<MarkerIconsBody> {
  final Size _markerAssetImageSize = const Size(48, 48);
  _MarkerSizeOption _currentSizeOption = _MarkerSizeOption.original;
  Set<Marker> _markers = <Marker>{};
  bool _scalingEnabled = true;
  bool _mipMapsEnabled = true;
  GoogleMapController? controller;
  AssetMapBitmap? _markerIconAsset;
  BytesMapBitmap? _markerIconBytes;
  final int _markersAmountPerType = 15;
  bool get _customSizeEnabled =>
      _currentSizeOption != _MarkerSizeOption.original;

  @override
  Widget build(BuildContext context) {
    _createCustomMarkerIconImages(context);
    final Size size = _getCurrentMarkerSize();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Column(children: <Widget>[
          Center(
            child: SizedBox(
              width: 350.0,
              height: 300.0,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _kMapCenter,
                  zoom: 7.0,
                ),
                markers: _markers,
                onMapCreated: _onMapCreated,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _toggleScaling(context),
            child: Text(_scalingEnabled
                ? 'Disable auto scaling'
                : 'Enable auto scaling'),
          ),
          if (_scalingEnabled) ...<Widget>[
            Container(
              width: size.width,
              height: size.height,
              color: Colors.red,
            ),
            Text(
                'Reference box with size of ${size.width} x ${size.height} in logical pixels.'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Marker size:'),
                const SizedBox(width: 10),
                DropdownButton<_MarkerSizeOption>(
                  value: _currentSizeOption,
                  onChanged: (_MarkerSizeOption? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _currentSizeOption = newValue;
                        _updateMarkerImages(context);
                      });
                    }
                  },
                  items:
                      _MarkerSizeOption.values.map((_MarkerSizeOption option) {
                    return DropdownMenuItem<_MarkerSizeOption>(
                      value: option,
                      child: Text(_getMarkerSizeOptionName(option)),
                    );
                  }).toList(),
                )
              ],
            ),
          ],
          TextButton(
            onPressed: () => _toggleMipMaps(context),
            child: Text(_mipMapsEnabled ? 'Disable mipmaps' : 'Enable mipmaps'),
          ),
        ])
      ],
    );
  }

  String _getMarkerSizeOptionName(_MarkerSizeOption option) {
    switch (option) {
      case _MarkerSizeOption.original:
        return 'Original';
      case _MarkerSizeOption.size30x30:
        return '30x30';
      case _MarkerSizeOption.size60x30:
        return '60x30';
      case _MarkerSizeOption.size120x60:
        return '120x60';
    }
  }

  Size _getCurrentMarkerSize() {
    if (_scalingEnabled) {
      switch (_currentSizeOption) {
        case _MarkerSizeOption.size60x30:
          return const Size(60, 30);
        case _MarkerSizeOption.size30x30:
          return const Size(30, 30);
        case _MarkerSizeOption.size120x60:
          return const Size(120, 60);
        case _MarkerSizeOption.original:
          return _markerAssetImageSize;
      }
    } else {
      return _markerAssetImageSize;
    }
  }

  void _toggleMipMaps(BuildContext context) {
    _mipMapsEnabled = !_mipMapsEnabled;
    _updateMarkerImages(context);
  }

  void _toggleScaling(BuildContext context) {
    _scalingEnabled = !_scalingEnabled;
    _updateMarkerImages(context);
  }

  void _updateMarkerImages(BuildContext context) {
    _updateMarkerAssetImage(context);
    _updateMarkerBytesImage(context);
    _updateMarkers();
  }

  Marker _createAssetMarker(int index) {
    final LatLng position =
        LatLng(_kMapCenter.latitude - (index * 0.5), _kMapCenter.longitude - 1);

    return Marker(
      markerId: MarkerId('marker_asset_$index'),
      position: position,
      icon: _markerIconAsset!,
    );
  }

  Marker _createBytesMarker(int index) {
    final LatLng position =
        LatLng(_kMapCenter.latitude - (index * 0.5), _kMapCenter.longitude + 1);

    return Marker(
      markerId: MarkerId('marker_bytes_$index'),
      position: position,
      icon: _markerIconBytes!,
    );
  }

  void _updateMarkers() {
    final Set<Marker> markers = <Marker>{};
    for (int i = 0; i < _markersAmountPerType; i++) {
      if (_markerIconAsset != null) {
        markers.add(_createAssetMarker(i));
      }
      if (_markerIconBytes != null) {
        markers.add(_createBytesMarker(i));
      }
    }
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _updateMarkerAssetImage(BuildContext context) async {
    // Size is used only for custom size and for a web platform.
    final Size? size = _scalingEnabled && (_customSizeEnabled || kIsWeb)
        ? _getCurrentMarkerSize()
        : null;

    final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
      context,
      size: size,
    );

    AssetMapBitmap assetMapBitmap;
    if (_mipMapsEnabled) {
      assetMapBitmap = await AssetMapBitmap.fromMipmaps(
        imageConfiguration,
        'assets/red_square.png',
        bitmapScaling:
            _scalingEnabled ? BitmapScaling.auto : BitmapScaling.noScaling,
      );
    } else {
      assetMapBitmap = AssetMapBitmap(
        imageConfiguration,
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling:
            _scalingEnabled ? BitmapScaling.auto : BitmapScaling.noScaling,
      );
    }

    _updateAssetBitmap(assetMapBitmap);
  }

  Future<void> _updateMarkerBytesImage(BuildContext context) async {
    final double devicePixelRatio = View.of(context).devicePixelRatio;

    final Size markerSize = _getCurrentMarkerSize();

    final double? imagePixelRatio = _scalingEnabled ? devicePixelRatio : null;

    // Create canvasSize with physical marker size
    final Size canvasSize = Size(markerSize.width * (imagePixelRatio ?? 1.0),
        markerSize.height * (imagePixelRatio ?? 1.0));

    final ByteData bytes = await createCustomMarkerIconImage(size: canvasSize);

    // Size is used only for custom size and for a web platform.
    final Size? size = _scalingEnabled && (_customSizeEnabled || kIsWeb)
        ? _getCurrentMarkerSize()
        : null;

    final BytesMapBitmap bitmap = BytesMapBitmap(bytes.buffer.asUint8List(),
        imagePixelRatio: imagePixelRatio,
        size: size,
        bitmapScaling:
            _scalingEnabled ? BitmapScaling.auto : BitmapScaling.noScaling);

    _updateBytesBitmap(bitmap);
  }

  void _updateAssetBitmap(AssetMapBitmap bitmap) {
    _markerIconAsset = bitmap;
    _updateMarkers();
  }

  void _updateBytesBitmap(BytesMapBitmap bitmap) {
    _markerIconBytes = bitmap;
    _updateMarkers();
  }

  void _createCustomMarkerIconImages(BuildContext context) {
    if (_markerIconAsset == null) {
      _updateMarkerAssetImage(context);
    }

    if (_markerIconBytes == null) {
      _updateMarkerBytesImage(context);
    }
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }
}
