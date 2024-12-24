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

  /// Returns the mapId to use for the GoogleMap
  String? get mapId => null;

  /// Creates a marker to be displayed on the map
  Marker createMarker(
    MarkerId markerId,
    LatLng position,
    BitmapDescriptor icon,
  ) {
    return Marker(
      markerId: markerId,
      position: position,
      icon: icon,
    );
  }
}

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

enum _MarkerSizeOption {
  original,
  width30,
  height40,
  size30x60,
  size120x60,
}

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
    final Size referenceSize = _getMarkerReferenceSize();
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
                markerType: widget.mapId != null
                    ? MarkerType.advancedMarker
                    : MarkerType.marker,
                mapId: widget.mapId,
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
              width: referenceSize.width,
              height: referenceSize.height,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
            ),
            Text(
                'Reference box with size of ${referenceSize.width} x ${referenceSize.height} in logical pixels.'),
            const SizedBox(height: 10),
            Image.asset(
              'assets/red_square.png',
              scale: _mipMapsEnabled ? null : 1.0,
            ),
            const Text('Asset image rendered with flutter'),
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
      case _MarkerSizeOption.width30:
        return 'Width 30';
      case _MarkerSizeOption.height40:
        return 'Height 40';
      case _MarkerSizeOption.size30x60:
        return '30x60';
      case _MarkerSizeOption.size120x60:
        return '120x60';
    }
  }

  (double? width, double? height) _getCurrentMarkerSize() {
    if (_scalingEnabled) {
      switch (_currentSizeOption) {
        case _MarkerSizeOption.width30:
          return (30, null);
        case _MarkerSizeOption.height40:
          return (null, 40);
        case _MarkerSizeOption.size30x60:
          return (30, 60);
        case _MarkerSizeOption.size120x60:
          return (120, 60);
        case _MarkerSizeOption.original:
          return (_markerAssetImageSize.width, _markerAssetImageSize.height);
      }
    } else {
      return (_markerAssetImageSize.width, _markerAssetImageSize.height);
    }
  }

  // Helper method to calculate reference size for custom marker size.
  Size _getMarkerReferenceSize() {
    final (double? width, double? height) = _getCurrentMarkerSize();

    // Calculates reference size using _markerAssetImageSize aspect ration:

    if (width != null && height != null) {
      return Size(width, height);
    } else if (width != null) {
      return Size(width,
          width * _markerAssetImageSize.height / _markerAssetImageSize.width);
    } else if (height != null) {
      return Size(
          height * _markerAssetImageSize.width / _markerAssetImageSize.height,
          height);
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

    return widget.createMarker(
      MarkerId('marker_asset_$index'),
      position,
      _markerIconAsset!,
    );
  }

  Marker _createBytesMarker(int index) {
    final LatLng position =
        LatLng(_kMapCenter.latitude - (index * 0.5), _kMapCenter.longitude + 1);

    return widget.createMarker(
      MarkerId('marker_bytes_$index'),
      position,
      _markerIconBytes!,
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
    // Width and height are used only for custom size.
    final (double? width, double? height) =
        _scalingEnabled && _customSizeEnabled
            ? _getCurrentMarkerSize()
            : (null, null);

    AssetMapBitmap assetMapBitmap;
    if (_mipMapsEnabled) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(
        context,
      );

      assetMapBitmap = await AssetMapBitmap.create(
        imageConfiguration,
        'assets/red_square.png',
        width: width,
        height: height,
        bitmapScaling:
            _scalingEnabled ? MapBitmapScaling.auto : MapBitmapScaling.none,
      );
    } else {
      // Uses hardcoded asset path
      // This bypasses the asset resolving logic and allows to load the asset
      // with precise path.
      assetMapBitmap = AssetMapBitmap(
        'assets/red_square.png',
        width: width,
        height: height,
        bitmapScaling:
            _scalingEnabled ? MapBitmapScaling.auto : MapBitmapScaling.none,
      );
    }

    _updateAssetBitmap(assetMapBitmap);
  }

  Future<void> _updateMarkerBytesImage(BuildContext context) async {
    final double? devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context);

    final Size bitmapLogicalSize = _getMarkerReferenceSize();
    final double? imagePixelRatio = _scalingEnabled ? devicePixelRatio : null;

    // Create canvasSize with physical marker size
    final Size canvasSize = Size(
        bitmapLogicalSize.width * (imagePixelRatio ?? 1.0),
        bitmapLogicalSize.height * (imagePixelRatio ?? 1.0));

    final ByteData bytes = await createCustomMarkerIconImage(size: canvasSize);

    // Width and height are used only for custom size.
    final (double? width, double? height) =
        _scalingEnabled && _customSizeEnabled
            ? _getCurrentMarkerSize()
            : (null, null);

    final BytesMapBitmap bitmap = BytesMapBitmap(bytes.buffer.asUint8List(),
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height,
        bitmapScaling:
            _scalingEnabled ? MapBitmapScaling.auto : MapBitmapScaling.none);

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
